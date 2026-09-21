import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ReorderPdfEvent extends Equatable {
  const ReorderPdfEvent();
  @override
  List<Object?> get props => [];
}
class ProcessReorderPdfEvent extends ReorderPdfEvent {
  final File inputFile;
  final Map<String, dynamic> params;
  const ProcessReorderPdfEvent({required this.inputFile, this.params = const {}});
  @override
  List<Object?> get props => [inputFile, params];
}
