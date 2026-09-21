import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ImageToPdfState extends Equatable {
  final List<File> selectedImages;
  
  const ImageToPdfState({this.selectedImages = const []});
  
  @override
  List<Object?> get props => [selectedImages];
}

class ImageToPdfInitial extends ImageToPdfState {
  const ImageToPdfInitial({super.selectedImages});
}

class ImageToPdfLoading extends ImageToPdfState {
  const ImageToPdfLoading({super.selectedImages});
}

class ImageToPdfSuccess extends ImageToPdfState {
  final File pdfFile;
  const ImageToPdfSuccess({required this.pdfFile, super.selectedImages});

  @override
  List<Object?> get props => [selectedImages, pdfFile];
}

class ImageToPdfError extends ImageToPdfState {
  final String message;
  const ImageToPdfError({required this.message, super.selectedImages});

  @override
  List<Object?> get props => [selectedImages, message];
}
