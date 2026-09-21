import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_repository.dart';
import '../datasources/file_datasource.dart';
import '../models/file_model.dart';

class FileRepositoryImpl implements FileRepository {
  final FileDataSource localDataSource;
  final Uuid uuid = const Uuid();

  FileRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<FileEntity>>> getFiles() async {
    try {
      final files = await localDataSource.getFiles();
      return Right(files);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FileEntity>> saveFile({required String originalPath, required String newName}) async {
    try {
      final originalFile = File(originalPath);
      if (!await originalFile.exists()) {
        return const Left(CacheFailure('Original file does not exist'));
      }

      final appDir = await localDataSource.getAppDirectory();
      
      // Ensure safe filename
      String safeName = newName;
      if (!safeName.toLowerCase().endsWith('.pdf')) {
        safeName += '.pdf';
      }
      
      final newPath = p.join(appDir, safeName);
      final newFile = await originalFile.copy(newPath);
      final stat = await newFile.stat();

      final fileModel = FileModel(
        id: uuid.v4(),
        name: safeName,
        path: newPath,
        sizeBytes: stat.size,
        createdAt: stat.changed,
        modifiedAt: stat.modified,
      );

      await localDataSource.saveFile(fileModel);
      return Right(fileModel);
    } catch (e) {
      return Left(CacheFailure('Failed to save file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile(String id) async {
    try {
      final file = await localDataSource.getFile(id);
      if (file != null) {
        final f = File(file.path);
        if (await f.exists()) {
          await f.delete();
        }
        await localDataSource.deleteFile(id);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete file: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FileEntity>> renameFile({required String id, required String newName}) async {
    try {
      final file = await localDataSource.getFile(id);
      if (file == null) {
        return const Left(CacheFailure('File not found in database'));
      }

      String safeName = newName;
      if (!safeName.toLowerCase().endsWith('.pdf')) {
        safeName += '.pdf';
      }

      final appDir = await localDataSource.getAppDirectory();
      final newPath = p.join(appDir, safeName);
      
      final f = File(file.path);
      if (!await f.exists()) {
        return const Left(CacheFailure('File not found on disk'));
      }

      final renamedFile = await f.rename(newPath);
      final stat = await renamedFile.stat();

      final updatedModel = FileModel(
        id: file.id,
        name: safeName,
        path: newPath,
        sizeBytes: stat.size,
        createdAt: file.createdAt,
        modifiedAt: DateTime.now(), // Update modification time
      );

      await localDataSource.saveFile(updatedModel);
      return Right(updatedModel);
    } catch (e) {
      return Left(CacheFailure('Failed to rename file: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, String>> getAppDirectory() async {
    try {
      final dir = await localDataSource.getAppDirectory();
      return Right(dir);
    } catch (e) {
      return Left(CacheFailure('Failed to get app directory'));
    }
  }
}
