import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_maker_scanner/core/services/pdf_processor.dart';
import 'addtext_event.dart';
import 'addtext_state.dart';

class AddTextBloc extends Bloc<AddTextEvent, AddTextState> {
  final PdfProcessor pdfProcessor;

  AddTextBloc({required this.pdfProcessor}) : super(AddTextInitial()) {
    on<ProcessAddTextEvent>(_onProcess);
  }

  Future<void> _onProcess(ProcessAddTextEvent event, Emitter<AddTextState> emit) async {
    emit(AddTextLoading());
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/text_added_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final text = event.params['text'] as String;
      final x = event.params['x'] as double;
      final y = event.params['y'] as double;
      
      final result = await pdfProcessor.addTextToPdf(
        inputFile: event.inputFile!,
        outputPath: outputPath,
        text: text,
        x: x,
        y: y,
      );
      
      result.fold(
        (failure) => emit(AddTextFailure(failure.message)),
        (file) => emit(AddTextSuccess(file: file)),
      );} catch (e) {
      emit(AddTextFailure(e.toString()));
    }
  }
}
