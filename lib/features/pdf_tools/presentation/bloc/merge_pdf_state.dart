import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class MergePdfState extends Equatable {
  final List<File> selectedFiles;
  
  const MergePdfState({this.selectedFiles = const []});
  
  @override
  List<Object?> get props => [selectedFiles];
}

class MergePdfInitial extends MergePdfState {
  const MergePdfInitial({super.selectedFiles});
}

class MergePdfLoading extends MergePdfState {
  const MergePdfLoading({super.selectedFiles});
}

class MergePdfSuccess extends MergePdfState {
  final File mergedFile;
  const MergePdfSuccess({required this.mergedFile, super.selectedFiles});

  @override
  List<Object?> get props => [selectedFiles, mergedFile];
}

class MergePdfError extends MergePdfState {
  final String message;
  const MergePdfError({required this.message, super.selectedFiles});

  @override
  List<Object?> get props => [selectedFiles, message];
}
