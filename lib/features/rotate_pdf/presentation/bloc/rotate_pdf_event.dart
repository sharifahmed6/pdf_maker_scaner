import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class RotatePdfEvent extends Equatable {
  const RotatePdfEvent();
  @override
  List<Object?> get props => [];
}
class ProcessRotatePdfEvent extends RotatePdfEvent {
  final File inputFile;
  final Map<String, dynamic> params;
  const ProcessRotatePdfEvent({required this.inputFile, this.params = const {}});
  @override
  List<Object?> get props => [inputFile, params];
}
