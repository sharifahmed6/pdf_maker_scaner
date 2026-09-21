import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class AddTextEvent extends Equatable {
  const AddTextEvent();
  @override
  List<Object?> get props => [];
}

class ProcessAddTextEvent extends AddTextEvent {
  final File? inputFile;
  final Map<String, dynamic> params;
  const ProcessAddTextEvent({this.inputFile, this.params = const {}});
  @override
  List<Object?> get props => [inputFile, params];
}
