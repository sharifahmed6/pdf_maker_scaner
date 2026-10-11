import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
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
      final file = event.inputFile!;
      String extractedText = '';

      // 1. Universal Multi-Language OCR (Bangla, Arabic, Russian, Chinese, English, All World Languages)
      try {
        final bytes = await file.readAsBytes();
        final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
        
        final response = await http.post(
          Uri.parse('https://api.ocr.space/parse/image'),
          headers: {'apikey': 'helloworld'},
          body: {
            'base64Image': base64Image,
            'OCREngine': '2',
            'isOverlayRequired': 'false',
            'detectOrientation': 'true',
          },
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['ParsedResults'] != null && (data['ParsedResults'] as List).isNotEmpty) {
            extractedText = data['ParsedResults'][0]['ParsedText'] ?? '';
          }
        }
      } catch (_) {}

      // 2. On-Device Fallback via Google ML Kit
      if (extractedText.trim().isEmpty && !kIsWeb) {
        final inputImage = InputImage.fromFilePath(file.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        await textRecognizer.close();
        extractedText = recognizedText.text;
      }

      if (extractedText.trim().isEmpty) {
        extractedText = 'No text detected in the selected image.';
      }

      emit(OcrSuccess(file: file, text: extractedText));
    } catch (e) {
      emit(OcrFailure(e.toString()));
    }
  }
}
