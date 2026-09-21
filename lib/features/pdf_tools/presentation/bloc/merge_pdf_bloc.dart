import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/pdf_processor.dart';
import 'merge_pdf_event.dart';
import 'merge_pdf_state.dart';

class MergePdfBloc extends Bloc<MergePdfEvent, MergePdfState> {
  final PdfProcessor pdfProcessor;

  MergePdfBloc({required this.pdfProcessor}) : super(const MergePdfInitial()) {
    on<SelectFilesEvent>(_onSelectFiles);
    on<RemoveFileEvent>(_onRemoveFile);
    on<ReorderFilesEvent>(_onReorderFiles);
    on<MergeFilesEvent>(_onMergeFiles);
  }

  Future<void> _onSelectFiles(SelectFilesEvent event, Emitter<MergePdfState> emit) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result.isNotEmpty) {
        final newFiles = result.where((file) => file.path != null).map((file) => File(file.path!)).toList();
        final updatedFiles = List<File>.from(state.selectedFiles)..addAll(newFiles);
        emit(MergePdfInitial(selectedFiles: updatedFiles));
      }
    } catch (e) {
      emit(MergePdfError(message: 'Failed to pick files: $e', selectedFiles: state.selectedFiles));
    }
  }

  void _onRemoveFile(RemoveFileEvent event, Emitter<MergePdfState> emit) {
    final updatedFiles = List<File>.from(state.selectedFiles);
    if (event.index >= 0 && event.index < updatedFiles.length) {
      updatedFiles.removeAt(event.index);
      emit(MergePdfInitial(selectedFiles: updatedFiles));
    }
  }

  void _onReorderFiles(ReorderFilesEvent event, Emitter<MergePdfState> emit) {
    final updatedFiles = List<File>.from(state.selectedFiles);
    int newIdx = event.newIndex;
    if (event.oldIndex < newIdx) {
      newIdx -= 1;
    }
    final file = updatedFiles.removeAt(event.oldIndex);
    updatedFiles.insert(newIdx, file);
    emit(MergePdfInitial(selectedFiles: updatedFiles));
  }

  Future<void> _onMergeFiles(MergeFilesEvent event, Emitter<MergePdfState> emit) async {
    if (state.selectedFiles.length < 2) {
      emit(MergePdfError(message: 'Please select at least 2 files to merge.', selectedFiles: state.selectedFiles));
      return;
    }

    emit(MergePdfLoading(selectedFiles: state.selectedFiles));

    try {
      final tempDir = await getTemporaryDirectory();
      final uuid = const Uuid().v4();
      final outputPath = '${tempDir.path}/merged_$uuid.pdf';

      final result = await pdfProcessor.mergePdfs(
        inputFiles: state.selectedFiles,
        outputPath: outputPath,
      );

      result.fold(
        (failure) => emit(MergePdfError(message: failure.message, selectedFiles: state.selectedFiles)),
        (mergedFile) => emit(MergePdfSuccess(mergedFile: mergedFile, selectedFiles: const [])),
      );
    } catch (e) {
      emit(MergePdfError(message: 'Merge failed: $e', selectedFiles: state.selectedFiles));
    }
  }
}
