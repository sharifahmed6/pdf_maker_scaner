import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class CompressPdfEvent extends Equatable {
  const CompressPdfEvent();
  @override
  List<Object?> get props => [];
}
class ProcessCompressPdfEvent extends CompressPdfEvent {
  final File inputFile;
  final Map<String, dynamic> params;
  const ProcessCompressPdfEvent({required this.inputFile, this.params = const {}});
  @override
  List<Object?> get props => [inputFile, params];
}
