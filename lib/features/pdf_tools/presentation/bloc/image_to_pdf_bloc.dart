import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/pdf_processor.dart';
import 'image_to_pdf_event.dart';
import 'image_to_pdf_state.dart';

class ImageToPdfBloc extends Bloc<ImageToPdfEvent, ImageToPdfState> {
  final PdfProcessor pdfProcessor;

  ImageToPdfBloc({required this.pdfProcessor}) : super(const ImageToPdfInitial()) {
    on<SelectImagesEvent>(_onSelectImages);
    on<RemoveImageEvent>(_onRemoveImage);
    on<ReorderImagesEvent>(_onReorderImages);
    on<ExecuteImageToPdfEvent>(_onExecuteConvert);
  }

  Future<void> _onSelectImages(SelectImagesEvent event, Emitter<ImageToPdfState> emit) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (result.isNotEmpty) {
        final newFiles = result.where((file) => file.path != null).map((file) => File(file.path!)).toList();
        final updatedFiles = List<File>.from(state.selectedImages)..addAll(newFiles);
        emit(ImageToPdfInitial(selectedImages: updatedFiles));
      }
    } catch (e) {
      emit(ImageToPdfError(message: 'Failed to pick images: $e', selectedImages: state.selectedImages));
    }
  }

  void _onRemoveImage(RemoveImageEvent event, Emitter<ImageToPdfState> emit) {
    final updatedFiles = List<File>.from(state.selectedImages);
    if (event.index >= 0 && event.index < updatedFiles.length) {
      updatedFiles.removeAt(event.index);
      emit(ImageToPdfInitial(selectedImages: updatedFiles));
    }
  }

  void _onReorderImages(ReorderImagesEvent event, Emitter<ImageToPdfState> emit) {
    final updatedFiles = List<File>.from(state.selectedImages);
    int newIdx = event.newIndex;
    if (event.oldIndex < newIdx) {
      newIdx -= 1;
    }
    final file = updatedFiles.removeAt(event.oldIndex);
    updatedFiles.insert(newIdx, file);
    emit(ImageToPdfInitial(selectedImages: updatedFiles));
  }

  Future<void> _onExecuteConvert(ExecuteImageToPdfEvent event, Emitter<ImageToPdfState> emit) async {
    if (state.selectedImages.isEmpty) {
      emit(ImageToPdfError(message: 'Please select at least 1 image.', selectedImages: state.selectedImages));
      return;
    }

    emit(ImageToPdfLoading(selectedImages: state.selectedImages));

    try {
      final tempDir = await getTemporaryDirectory();
      final uuid = const Uuid().v4();
      final outputPath = '${tempDir.path}/images_to_pdf_$uuid.pdf';

      final result = await pdfProcessor.imagesToPdf(
        images: state.selectedImages,
        outputPath: outputPath,
      );

      result.fold(
        (failure) => emit(ImageToPdfError(message: failure.message, selectedImages: state.selectedImages)),
        (pdfFile) => emit(ImageToPdfSuccess(pdfFile: pdfFile, selectedImages: const [])),
      );
    } catch (e) {
      emit(ImageToPdfError(message: 'Conversion failed: $e', selectedImages: state.selectedImages));
    }
  }
}
