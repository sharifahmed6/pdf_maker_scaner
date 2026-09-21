import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProtectPdfEvent extends Equatable {
  const ProtectPdfEvent();
  @override
  List<Object?> get props => [];
}
class ProcessProtectPdfEvent extends ProtectPdfEvent {
  final File inputFile;
  final Map<String, dynamic> params;
  const ProcessProtectPdfEvent({required this.inputFile, this.params = const {}});
  @override
  List<Object?> get props => [inputFile, params];
}
