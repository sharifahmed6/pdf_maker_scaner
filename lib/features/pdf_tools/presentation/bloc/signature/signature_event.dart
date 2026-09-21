import 'package:equatable/equatable.dart';
import 'dart:io';
import 'dart:typed_data';

abstract class SignatureEvent extends Equatable {
  const SignatureEvent();
  @override
  List<Object?> get props => [];
}

class ProcessSignatureEvent extends SignatureEvent {
  final File? inputFile;
  final Uint8List? inputFileBytes;
  final Uint8List? signatureImageBytes;
  final Map<String, dynamic> params;

  const ProcessSignatureEvent({
    this.inputFile,
    this.inputFileBytes,
    this.signatureImageBytes,
    this.params = const {},
  });

  @override
  List<Object?> get props => [inputFile, inputFileBytes, signatureImageBytes, params];
}
