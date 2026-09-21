import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_maker_scanner/core/services/pdf_processor.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final PdfProcessor pdfProcessor;

  ScannerBloc({required this.pdfProcessor}) : super(ScannerInitial()) {
    on<ProcessScannerEvent>(_onProcess);
  }

  Future<void> _onProcess(ProcessScannerEvent event, Emitter<ScannerState> emit) async {
    emit(ScannerLoading());
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/scanned_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final imagePaths = event.params['imagePaths'] as List<String>;
      final images = imagePaths.map((p) => File(p)).toList();
      
      final result = await pdfProcessor.imagesToPdf(
        images: images,
        outputPath: outputPath,
      );
      
      result.fold(
        (failure) => emit(ScannerFailure(failure.message)),
        (file) => emit(ScannerSuccess(file: file)),
      );} catch (e) {
      emit(ScannerFailure(e.toString()));
    }
  }
}
