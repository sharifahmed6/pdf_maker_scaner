import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/pdf_processor.dart';
import 'package:path_provider/path_provider.dart';
import 'rotate_pdf_event.dart';
import 'rotate_pdf_state.dart';

class RotatePdfBloc extends Bloc<RotatePdfEvent, RotatePdfState> {
  final PdfProcessor pdfProcessor;
  

  RotatePdfBloc({required this.pdfProcessor}) : super(RotatePdfInitial()) {
    on<ProcessRotatePdfEvent>(_onProcess);
  }

  Future<void> _onProcess(ProcessRotatePdfEvent event, Emitter<RotatePdfState> emit) async {
    emit(RotatePdfLoading());
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final angle = event.params['angle'] as int? ?? 90;
      final pageNumbers = event.params['pageNumbers'] as List<int>?;
      
      final result = await pdfProcessor.rotatePdf(
        inputFile: event.inputFile, 
        outputPath: outputPath,
        angle: angle,
        pageNumbers: pageNumbers,
      );
      
      result.fold(
        (failure) => emit(RotatePdfFailure(failure.message)),
        (file) => emit(RotatePdfSuccess(file)),
      );} catch (e) {
      emit(RotatePdfFailure(e.toString()));
    }
  }
}
