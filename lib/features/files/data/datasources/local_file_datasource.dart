import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/file_model.dart';
import 'file_datasource.dart';

class LocalFileDataSourceImpl implements FileDataSource {
  static const String boxName = 'files_box';

  Future<Box<String>> get _box async => await Hive.openBox<String>(boxName);

  @override
  Future<List<FileModel>> getFiles() async {
    final box = await _box;
    final files = box.values.map((e) => FileModel.fromJson(json.decode(e))).toList();
    
    // Sort by modifiedAt descending (newest first)
    files.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    
    // Verify files still exist on disk
    final existingFiles = <FileModel>[];
    for (var file in files) {
      if (await File(file.path).exists()) {
        existingFiles.add(file);
      } else {
        // Clean up orphaned records
        await box.delete(file.id);
      }
    }
    
    return existingFiles;
  }

  @override
  Future<void> saveFile(FileModel file) async {
    final box = await _box;
    await box.put(file.id, json.encode(file.toJson()));
  }

  @override
  Future<void> deleteFile(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Future<FileModel?> getFile(String id) async {
    final box = await _box;
    final data = box.get(id);
    if (data != null) {
      return FileModel.fromJson(json.decode(data));
    }
    return null;
  }
  
  @override
  Future<String> getAppDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${dir.path}/pdfs');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir.path;
  }
}
