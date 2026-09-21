import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ReorderPdfState extends Equatable {
  const ReorderPdfState();
  @override
  List<Object?> get props => [];
}

class ReorderPdfInitial extends ReorderPdfState {}
class ReorderPdfLoading extends ReorderPdfState {}
class ReorderPdfSuccess extends ReorderPdfState {
  final File file;
  const ReorderPdfSuccess(this.file);
  @override
  List<Object?> get props => [file];
}
class ReorderPdfFailure extends ReorderPdfState {
  final String message;
  const ReorderPdfFailure(this.message);
  @override
  List<Object?> get props => [message];
}
