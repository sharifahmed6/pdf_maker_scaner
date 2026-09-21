import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import '../../../../core/services/pdf_processor.dart';
import 'split_pdf_event.dart';
import 'split_pdf_state.dart';

class SplitPdfBloc extends Bloc<SplitPdfEvent, SplitPdfState> {
  final PdfProcessor pdfProcessor;

  SplitPdfBloc({required this.pdfProcessor}) : super(const SplitPdfInitial()) {
    on<SelectSplitFileEvent>(_onSelectFile);
    on<TogglePageSelectionEvent>(_onTogglePage);
    on<ExecuteSplitEvent>(_onExecuteSplit);
  }

  Future<void> _onSelectFile(SelectSplitFileEvent event, Emitter<SplitPdfState> emit) async {
    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.path != null) {
        final file = File(result.path!);
        
        // Count pages using Syncfusion
        final bytes = await file.readAsBytes();
        final document = sf.PdfDocument(inputBytes: bytes);
        final pageCount = document.pages.count;
        document.dispose();
        
        emit(SplitPdfInitial(
          selectedFile: file,
          totalPages: pageCount,
          selectedPages: const {}, // Reset selection
        ));
      }
    } catch (e) {
      emit(SplitPdfError(message: 'Failed to load PDF: $e'));
    }
  }

  void _onTogglePage(TogglePageSelectionEvent event, Emitter<SplitPdfState> emit) {
    if (state.selectedFile == null) return;
    
    final newSelection = Set<int>.from(state.selectedPages);
    if (newSelection.contains(event.pageIndex)) {
      newSelection.remove(event.pageIndex);
    } else {
      newSelection.add(event.pageIndex);
    }
    
    emit(SplitPdfInitial(
      selectedFile: state.selectedFile,
      totalPages: state.totalPages,
      selectedPages: newSelection,
    ));
  }

  Future<void> _onExecuteSplit(ExecuteSplitEvent event, Emitter<SplitPdfState> emit) async {
    if (state.selectedFile == null) {
      emit(SplitPdfError(message: 'No file selected', selectedFile: state.selectedFile, totalPages: state.totalPages, selectedPages: state.selectedPages));
      return;
    }
    
    if (state.selectedPages.isEmpty) {
      emit(SplitPdfError(message: 'Please select at least one page', selectedFile: state.selectedFile, totalPages: state.totalPages, selectedPages: state.selectedPages));
      return;
    }

    emit(SplitPdfLoading(selectedFile: state.selectedFile, totalPages: state.totalPages, selectedPages: state.selectedPages));

    try {
      final tempDir = await getTemporaryDirectory();
      final uuid = const Uuid().v4();
      final outputPath = '${tempDir.path}/split_$uuid.pdf';

      final result = await pdfProcessor.splitPdf(
        inputFile: state.selectedFile!,
        outputPath: outputPath,
        pageNumbers: state.selectedPages.toList()..sort(), // Pass sorted selected pages
      );

      result.fold(
        (failure) => emit(SplitPdfError(message: failure.message, selectedFile: state.selectedFile, totalPages: state.totalPages, selectedPages: state.selectedPages)),
        (splitFile) => emit(SplitPdfSuccess(
          splitFile: splitFile,
          selectedFile: state.selectedFile,
          totalPages: state.totalPages,
          selectedPages: state.selectedPages,
        )),
      );
    } catch (e) {
      emit(SplitPdfError(message: 'Split failed: $e', selectedFile: state.selectedFile, totalPages: state.totalPages, selectedPages: state.selectedPages));
    }
  }
}
