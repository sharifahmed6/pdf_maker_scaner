import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/file_repository.dart';
import 'files_event.dart';
import 'files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final FileRepository repository;

  FilesBloc({required this.repository}) : super(FilesInitial()) {
    on<LoadFilesEvent>(_onLoadFiles);
    on<DeleteFileEvent>(_onDeleteFile);
    on<RenameFileEvent>(_onRenameFile);
  }

  Future<void> _onLoadFiles(LoadFilesEvent event, Emitter<FilesState> emit) async {
    emit(FilesLoading());
    final result = await repository.getFiles();
    result.fold(
      (failure) => emit(FilesError(failure.message)),
      (files) => emit(FilesLoaded(files)),
    );
  }

  Future<void> _onDeleteFile(DeleteFileEvent event, Emitter<FilesState> emit) async {
    final result = await repository.deleteFile(event.id);
    result.fold(
      (failure) => emit(FilesError(failure.message)),
      (_) {
        // Reload files after successful deletion
        add(LoadFilesEvent());
      },
    );
  }

  Future<void> _onRenameFile(RenameFileEvent event, Emitter<FilesState> emit) async {
    final result = await repository.renameFile(id: event.id, newName: event.newName);
    result.fold(
      (failure) => emit(FilesError(failure.message)),
      (_) {
        // Reload files after successful rename
        add(LoadFilesEvent());
      },
    );
  }
}
