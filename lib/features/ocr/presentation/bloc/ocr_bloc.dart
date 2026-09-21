import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_maker_scanner/core/services/pdf_processor.dart';
import 'ocr_event.dart';
import 'ocr_state.dart';

class OcrBloc extends Bloc<OcrEvent, OcrState> {
  final PdfProcessor pdfProcessor;

  OcrBloc({required this.pdfProcessor}) : super(OcrInitial()) {
    on<ProcessOcrEvent>(_onProcess);
  }

  Future<void> _onProcess(ProcessOcrEvent event, Emitter<OcrState> emit) async {
    emit(OcrLoading());
    try {
      // OCR processing
      final file = event.inputFile!;
      final inputImage = InputImage.fromFilePath(file.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      await textRecognizer.close();
      
      emit(OcrSuccess(file: file, text: recognizedText.text));} catch (e) {
      emit(OcrFailure(e.toString()));
    }
  }
}
