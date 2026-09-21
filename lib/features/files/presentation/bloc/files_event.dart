import 'package:equatable/equatable.dart';

abstract class FilesEvent extends Equatable {
  const FilesEvent();

  @override
  List<Object> get props => [];
}

class LoadFilesEvent extends FilesEvent {}

class DeleteFileEvent extends FilesEvent {
  final String id;
  const DeleteFileEvent(this.id);

  @override
  List<Object> get props => [id];
}

class RenameFileEvent extends FilesEvent {
  final String id;
  final String newName;
  const RenameFileEvent(this.id, this.newName);

  @override
  List<Object> get props => [id, newName];
}
