import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class OcrState extends Equatable {
  const OcrState();
  @override
  List<Object?> get props => [];
}

class OcrInitial extends OcrState {}
class OcrLoading extends OcrState {}
class OcrSuccess extends OcrState {
  final File file;
  final String? text; // For OCR
  const OcrSuccess({required this.file, this.text});
  @override
  List<Object?> get props => [file, text];
}
class OcrFailure extends OcrState {
  final String message;
  const OcrFailure(this.message);
  @override
  List<Object?> get props => [message];
}
