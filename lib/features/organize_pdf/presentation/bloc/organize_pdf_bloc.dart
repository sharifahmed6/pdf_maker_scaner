import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../../core/services/pdf_processor.dart';
import 'package:path_provider/path_provider.dart';
import 'organize_pdf_event.dart';
import 'organize_pdf_state.dart';

class ReorderPdfBloc extends Bloc<ReorderPdfEvent, ReorderPdfState> {
  final PdfProcessor pdfProcessor;
  

  ReorderPdfBloc({required this.pdfProcessor}) : super(ReorderPdfInitial()) {
    on<ProcessReorderPdfEvent>(_onProcess);
  }

  Future<void> _onProcess(ProcessReorderPdfEvent event, Emitter<ReorderPdfState> emit) async {
    emit(ReorderPdfLoading());
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/reordered_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final newPageOrder = event.params['newPageOrder'] as List<int>? ?? [];
      
      final result = await pdfProcessor.reorderPdf(
        inputFile: event.inputFile, 
        outputPath: outputPath,
        newPageOrder: newPageOrder,
      );
      
      result.fold(
        (failure) => emit(ReorderPdfFailure(failure.message)),
        (file) => emit(ReorderPdfSuccess(file)),
      );} catch (e) {
      emit(ReorderPdfFailure(e.toString()));
    }
  }
}
