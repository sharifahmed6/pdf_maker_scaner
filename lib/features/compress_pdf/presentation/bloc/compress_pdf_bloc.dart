import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../../core/services/pdf_processor.dart';
import 'package:path_provider/path_provider.dart';
import 'compress_pdf_event.dart';
import 'compress_pdf_state.dart';

class CompressPdfBloc extends Bloc<CompressPdfEvent, CompressPdfState> {
  final PdfProcessor pdfProcessor;
  

  CompressPdfBloc({required this.pdfProcessor}) : super(CompressPdfInitial()) {
    on<ProcessCompressPdfEvent>(_onProcess);
  }

  Future<void> _onProcess(ProcessCompressPdfEvent event, Emitter<CompressPdfState> emit) async {
    emit(CompressPdfLoading());
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final result = await pdfProcessor.compressPdf(
        inputFile: event.inputFile, 
        outputPath: outputPath,
        level: event.params['level']?.toString(),
      );
      
      result.fold(
        (failure) => emit(CompressPdfFailure(failure.message)),
        (file) => emit(CompressPdfSuccess(file)),
      );} catch (e) {
      emit(CompressPdfFailure(e.toString()));
    }
  }
}
