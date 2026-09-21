import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ScannerState extends Equatable {
  const ScannerState();
  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}
class ScannerLoading extends ScannerState {}
class ScannerSuccess extends ScannerState {
  final File file;
  final String? text; // For OCR
  const ScannerSuccess({required this.file, this.text});
  @override
  List<Object?> get props => [file, text];
}
class ScannerFailure extends ScannerState {
  final String message;
  const ScannerFailure(this.message);
  @override
  List<Object?> get props => [message];
}
