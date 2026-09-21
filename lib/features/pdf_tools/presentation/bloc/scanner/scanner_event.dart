import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();
  @override
  List<Object?> get props => [];
}

class ProcessScannerEvent extends ScannerEvent {
  final File? inputFile;
  final Map<String, dynamic> params;
  const ProcessScannerEvent({this.inputFile, this.params = const {}});
  @override
  List<Object?> get props => [inputFile, params];
}
