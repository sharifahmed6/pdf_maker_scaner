import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:pdf_maker_scanner/core/services/pdf_processor.dart';
import 'signature_event.dart';
import 'signature_state.dart';

class SignatureBloc extends Bloc<SignatureEvent, SignatureState> {
  final PdfProcessor pdfProcessor;

  SignatureBloc({required this.pdfProcessor}) : super(SignatureInitial()) {
    on<ProcessSignatureEvent>(_onProcess);
  }

  Future<void> _onProcess(ProcessSignatureEvent event, Emitter<SignatureState> emit) async {
    emit(SignatureLoading());
    try {
      final x = (event.params['x'] as double?) ?? 0.0;
      final y = (event.params['y'] as double?) ?? 0.0;
      final pageIndex = (event.params['pageIndex'] as int?) ?? 0;
      final width = (event.params['width'] as double?) ?? 150.0;
      final height = (event.params['height'] as double?) ?? 50.0;
      final rotation = (event.params['rotation'] as double?) ?? 0.0;

      if (kIsWeb) {
        Uint8List? pdfBytes = event.inputFileBytes;
        if (pdfBytes == null && event.inputFile != null) {
          pdfBytes = await event.inputFile!.readAsBytes();
        }

        Uint8List? sigBytes = event.signatureImageBytes;
        if (sigBytes == null && event.params['signatureFile'] != null) {
          sigBytes = await File(event.params['signatureFile'] as String).readAsBytes();
        }

        if (pdfBytes == null || sigBytes == null) {
          emit(const SignatureFailure('Failed to load PDF or signature image bytes.'));
          return;
        }

        final document = sf.PdfDocument(inputBytes: pdfBytes);
        if (document.pages.count > pageIndex) {
          final page = document.pages[pageIndex];
          final image = sf.PdfBitmap(sigBytes);

          page.graphics.save();
          page.graphics.translateTransform(x + width / 2, y + height / 2);

          if (rotation != 0.0) {
            final double degrees = rotation * (180.0 / 3.1415926535897932);
            page.graphics.rotateTransform(degrees);
          }

          page.graphics.drawImage(
            image,
            Rect.fromLTWH(-width / 2, -height / 2, width, height),
          );
          page.graphics.restore();
        }

        final List<int> resultBytes = document.saveSync();
        document.dispose();

        emit(SignatureSuccess(bytes: Uint8List.fromList(resultBytes)));
      } else {
        final tempDir = await getTemporaryDirectory();
        final outputPath = '${tempDir.path}/signed_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final signaturePath = event.params['signatureFile'] as String;

        final result = await pdfProcessor.addSignatureToPdf(
          inputFile: event.inputFile!,
          outputPath: outputPath,
          signatureImage: File(signaturePath),
          x: x,
          y: y,
          pageIndex: pageIndex,
          width: width,
          height: height,
          rotation: rotation,
        );

        result.fold(
          (failure) => emit(SignatureFailure(failure.message)),
          (file) => emit(SignatureSuccess(file: file)),
        );
      }
    } catch (e) {
      emit(SignatureFailure(e.toString()));
    }
  }
}
