import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class CompressPdfState extends Equatable {
  const CompressPdfState();
  @override
  List<Object?> get props => [];
}

class CompressPdfInitial extends CompressPdfState {}
class CompressPdfLoading extends CompressPdfState {}
class CompressPdfSuccess extends CompressPdfState {
  final File file;
  const CompressPdfSuccess(this.file);
  @override
  List<Object?> get props => [file];
}
class CompressPdfFailure extends CompressPdfState {
  final String message;
  const CompressPdfFailure(this.message);
  @override
  List<Object?> get props => [message];
}
