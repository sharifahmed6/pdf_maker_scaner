import 'package:equatable/equatable.dart';
import '../../domain/entities/file_entity.dart';

abstract class FilesState extends Equatable {
  const FilesState();
  
  @override
  List<Object> get props => [];
}

class FilesInitial extends FilesState {}

class FilesLoading extends FilesState {}

class FilesLoaded extends FilesState {
  final List<FileEntity> files;
  const FilesLoaded(this.files);

  @override
  List<Object> get props => [files];
}

class FilesError extends FilesState {
  final String message;
  const FilesError(this.message);

  @override
  List<Object> get props => [message];
}
