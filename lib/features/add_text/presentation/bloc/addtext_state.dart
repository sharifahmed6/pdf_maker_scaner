import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class AddTextState extends Equatable {
  const AddTextState();
  @override
  List<Object?> get props => [];
}

class AddTextInitial extends AddTextState {}
class AddTextLoading extends AddTextState {}
class AddTextSuccess extends AddTextState {
  final File file;
  final String? text; // For OCR
  const AddTextSuccess({required this.file, this.text});
  @override
  List<Object?> get props => [file, text];
}
class AddTextFailure extends AddTextState {
  final String message;
  const AddTextFailure(this.message);
  @override
  List<Object?> get props => [message];
}
