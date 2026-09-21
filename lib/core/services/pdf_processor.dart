import 'dart:io';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class PdfProcessor {
  /// Compresses a PDF file and saves it to [outputPath].
  Future<Either<Failure, File>> compressPdf({
    required File inputFile,
    required String outputPath,
    bool highQuality = true,
  });

  /// Merges multiple PDF files into one.
  Future<Either<Failure, File>> mergePdfs({
    required List<File> inputFiles,
    required String outputPath,
  });

  /// Splits a PDF file into multiple files or extracts specific pages.
  Future<Either<Failure, File>> splitPdf({
    required File inputFile,
    required String outputPath,
    required List<int> pageNumbers,
  });

  /// Converts images to a single PDF.
  Future<Either<Failure, File>> imagesToPdf({
    required List<File> images,
    required String outputPath,
  });

  /// Converts a PDF to a list of images.
  Future<Either<Failure, List<File>>> pdfToImages({
    required File inputFile,
    required String outputDirectory,
  });
  
  /// Secures a PDF with a password.
  Future<Either<Failure, File>> protectPdf({
    required File inputFile,
    required String outputPath,
    required String password,
  });

  /// Rotates pages in a PDF.
  Future<Either<Failure, File>> rotatePdf({
    required File inputFile,
    required String outputPath,
    required int angle,
    List<int>? pageNumbers,
  });

  /// Reorders pages in a PDF.
  Future<Either<Failure, File>> reorderPdf({
    required File inputFile,
    required String outputPath,
    required List<int> newPageOrder,
  });

  /// Adds text to a PDF.
  Future<Either<Failure, File>> addTextToPdf({
    required File inputFile,
    required String outputPath,
    required String text,
    required double x,
    required double y,
  });

  /// Adds a signature image to a PDF.
  Future<Either<Failure, File>> addSignatureToPdf({
    required File inputFile,
    required String outputPath,
    required File signatureImage,
    required double x,
    required double y,
    int pageIndex = 0,
    double width = 150,
    double height = 50,
    double rotation = 0.0,
  });
}
