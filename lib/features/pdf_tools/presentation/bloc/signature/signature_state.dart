import 'package:equatable/equatable.dart';
import 'dart:io';
import 'dart:typed_data';

abstract class SignatureState extends Equatable {
  const SignatureState();
  @override
  List<Object?> get props => [];
}

class SignatureInitial extends SignatureState {}
class SignatureLoading extends SignatureState {}

class SignatureSuccess extends SignatureState {
  final File? file;
  final Uint8List? bytes;
  final String? text; // For OCR
  const SignatureSuccess({this.file, this.bytes, this.text});
  @override
  List<Object?> get props => [file, bytes, text];
}
class SignatureFailure extends SignatureState {
  final String message;
  const SignatureFailure(this.message);
  @override
  List<Object?> get props => [message];
}
