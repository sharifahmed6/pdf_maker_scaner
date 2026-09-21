import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class OcrEvent extends Equatable {
  const OcrEvent();
  @override
  List<Object?> get props => [];
}

class ProcessOcrEvent extends OcrEvent {
  final File? inputFile;
  final Map<String, dynamic> params;
  const ProcessOcrEvent({this.inputFile, this.params = const {}});
  @override
  List<Object?> get props => [inputFile, params];
}
