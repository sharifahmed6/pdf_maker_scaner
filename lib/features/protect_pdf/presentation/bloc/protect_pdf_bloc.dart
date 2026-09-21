import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../../core/services/pdf_processor.dart';
import 'package:path_provider/path_provider.dart';
import 'protect_pdf_event.dart';
import 'protect_pdf_state.dart';

class ProtectPdfBloc extends Bloc<ProtectPdfEvent, ProtectPdfState> {
  final PdfProcessor pdfProcessor;
  

  ProtectPdfBloc({required this.pdfProcessor}) : super(ProtectPdfInitial()) {
    on<ProcessProtectPdfEvent>(_onProcess);
  }

  Future<void> _onProcess(ProcessProtectPdfEvent event, Emitter<ProtectPdfState> emit) async {
    emit(ProtectPdfLoading());
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/protected_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final password = event.params['password'] as String? ?? '';
      
      final result = await pdfProcessor.protectPdf(
        inputFile: event.inputFile, 
        outputPath: outputPath,
        password: password,
      );
      
      result.fold(
        (failure) => emit(ProtectPdfFailure(failure.message)),
        (file) => emit(ProtectPdfSuccess(file)),
      );} catch (e) {
      emit(ProtectPdfFailure(e.toString()));
    }
  }
}
