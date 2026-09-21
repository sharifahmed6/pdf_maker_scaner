import '../models/file_model.dart';

abstract class FileDataSource {
  Future<List<FileModel>> getFiles();
  Future<void> saveFile(FileModel file);
  Future<void> deleteFile(String id);
  Future<FileModel?> getFile(String id);
  Future<String> getAppDirectory();
}
