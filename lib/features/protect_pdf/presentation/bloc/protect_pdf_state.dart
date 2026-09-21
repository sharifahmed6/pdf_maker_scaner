import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProtectPdfState extends Equatable {
  const ProtectPdfState();
  @override
  List<Object?> get props => [];
}

class ProtectPdfInitial extends ProtectPdfState {}
class ProtectPdfLoading extends ProtectPdfState {}
class ProtectPdfSuccess extends ProtectPdfState {
  final File file;
  const ProtectPdfSuccess(this.file);
  @override
  List<Object?> get props => [file];
}
class ProtectPdfFailure extends ProtectPdfState {
  final String message;
  const ProtectPdfFailure(this.message);
  @override
  List<Object?> get props => [message];
}
