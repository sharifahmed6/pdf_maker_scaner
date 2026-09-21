import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class SplitPdfState extends Equatable {
  final File? selectedFile;
  final int totalPages;
  final Set<int> selectedPages;
  
  const SplitPdfState({
    this.selectedFile,
    this.totalPages = 0,
    this.selectedPages = const {},
  });
  
  @override
  List<Object?> get props => [selectedFile, totalPages, selectedPages];
}

class SplitPdfInitial extends SplitPdfState {
  const SplitPdfInitial({super.selectedFile, super.totalPages, super.selectedPages});
}

class SplitPdfLoading extends SplitPdfState {
  const SplitPdfLoading({super.selectedFile, super.totalPages, super.selectedPages});
}

class SplitPdfSuccess extends SplitPdfState {
  final File splitFile;
  const SplitPdfSuccess({required this.splitFile, super.selectedFile, super.totalPages, super.selectedPages});

  @override
  List<Object?> get props => [selectedFile, totalPages, selectedPages, splitFile];
}

class SplitPdfError extends SplitPdfState {
  final String message;
  const SplitPdfError({required this.message, super.selectedFile, super.totalPages, super.selectedPages});

  @override
  List<Object?> get props => [selectedFile, totalPages, selectedPages, message];
}
