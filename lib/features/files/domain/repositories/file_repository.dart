import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/file_entity.dart';

abstract class FileRepository {
  Future<Either<Failure, List<FileEntity>>> getFiles();
  Future<Either<Failure, FileEntity>> saveFile({required String originalPath, required String newName});
  Future<Either<Failure, void>> deleteFile(String id);
  Future<Either<Failure, FileEntity>> renameFile({required String id, required String newName});
  Future<Either<Failure, String>> getAppDirectory();
}
