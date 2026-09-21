import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class RotatePdfState extends Equatable {
  const RotatePdfState();
  @override
  List<Object?> get props => [];
}

class RotatePdfInitial extends RotatePdfState {}
class RotatePdfLoading extends RotatePdfState {}
class RotatePdfSuccess extends RotatePdfState {
  final File file;
  const RotatePdfSuccess(this.file);
  @override
  List<Object?> get props => [file];
}
class RotatePdfFailure extends RotatePdfState {
  final String message;
  const RotatePdfFailure(this.message);
  @override
  List<Object?> get props => [message];
}
