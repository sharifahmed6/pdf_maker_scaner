import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:image/image.dart' as img;

import '../errors/failures.dart';
import 'pdf_processor.dart';

class PdfProcessorImpl implements PdfProcessor {
  @override
  Future<Either<Failure, File>> compressPdf({
    required File inputFile,
    required String outputPath,
    bool highQuality = true,
    String? level,
  }) async {
    try {
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: await inputFile.readAsBytes());
      
      sf.PdfCompressionLevel compressionLevel = sf.PdfCompressionLevel.best;
      if (level != null) {
        if (level.contains('highQuality')) {
          compressionLevel = sf.PdfCompressionLevel.normal;
        } else if (level.contains('maxCompression')) {
          compressionLevel = sf.PdfCompressionLevel.best;
        }
      }
      document.compressionLevel = compressionLevel;
      
      final List<int> bytes = document.saveSync();
      document.dispose();
      
      final File outFile = File(outputPath);
      await outFile.writeAsBytes(bytes);
      return Right(outFile);
    } catch (e) {
      return Left(CacheFailure('Compression failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, File>> mergePdfs({
    required List<File> inputFiles,
    required String outputPath,
  }) async {
    try {
      final sf.PdfDocument document = sf.PdfDocument();
      
      for (final file in inputFiles) {
        final sf.PdfDocument tempDoc = sf.PdfDocument(inputBytes: await file.readAsBytes());
        for (int i = 0; i < tempDoc.pages.count; i++) {
          final sf.PdfPage templatePage = tempDoc.pages[i];
          final sf.PdfPage newPage = document.pages.add();
          
          newPage.graphics.drawPdfTemplate(
            templatePage.createTemplate(),
            Offset.zero,
          );
        }
        tempDoc.dispose();
      }
      
      final List<int> bytes = document.saveSync();
      document.dispose();
      
      final File outFile = File(outputPath);
      await outFile.writeAsBytes(bytes);
      return Right(outFile);
    } catch (e) {
      return Left(CacheFailure('Merge failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, File>> splitPdf({
    required File inputFile,
    required String outputPath,
    required List<int> pageNumbers,
  }) async {
    try {
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: await inputFile.readAsBytes());
      final sf.PdfDocument newDocument = sf.PdfDocument();
      
      for (final pageNumber in pageNumbers) {
        if (pageNumber >= 0 && pageNumber < document.pages.count) {
          final sf.PdfPage templatePage = document.pages[pageNumber];
          final sf.PdfPage newPage = newDocument.pages.add();
          newPage.graphics.drawPdfTemplate(
            templatePage.createTemplate(),
            Offset.zero,
          );
        }
      }
      
      final List<int> bytes = newDocument.saveSync();
      document.dispose();
      newDocument.dispose();
      
      final File outFile = File(outputPath);
      await outFile.writeAsBytes(bytes);
      return Right(outFile);
    } catch (e) {
      return Left(CacheFailure('Split failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, File>> imagesToPdf({
    required List<File> images,
    required String outputPath,
  }) async {
    try {
      final pdf = pw.Document();
      
      for (final imageFile in images) {
        final imageBytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);
        
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            },
          ),
        );
      }
      
      final File outFile = File(outputPath);
      await outFile.writeAsBytes(await pdf.save());
      return Right(outFile);
    } catch (e) {
      return Left(CacheFailure('Images to PDF failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<File>>> pdfToImages({
    required File inputFile,
    required String outputDirectory,
  }) async {
    // Requires a native renderer like native_pdf_renderer. Mocking for now.
    return const Left(CacheFailure('PDF to Images requires native rendering implementation'));
  }
  
  @override
  Future<Either<Failure, File>> protectPdf({
    required File inputFile,
    required String outputPath,
    required String password,
  }) async {
    try {
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: await inputFile.readAsBytes());
      
      final sf.PdfSecurity security = document.security;
      security.userPassword = password;
      security.ownerPassword = password; // Set same for now
      security.algorithm = sf.PdfEncryptionAlgorithm.aesx256Bit;
      
      final List<int> bytes = document.saveSync();
      document.dispose();
      
      final File outFile = File(outputPath);
      await outFile.writeAsBytes(bytes);
      return Right(outFile);
    } catch (e) {
      return Left(CacheFailure('Protect PDF failed: ${e.toString()}'));
    }
  }
  @override
  Future<Either<Failure, File>> rotatePdf({
    required File inputFile,
    required String outputPath,
    required int angle,
    List<int>? pageNumbers,
  }) async {
    try {
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: await inputFile.readAsBytes());
      
      sf.PdfPageRotateAngle sfAngle;
      switch (angle) {
        case 90: sfAngle = sf.PdfPageRotateAngle.rotateAngle90; break;
        case 180: sfAngle = sf.PdfPageRotateAngle.rotateAngle180; break;
        case 270: sfAngle = sf.PdfPageRotateAngle.rotateAngle270; break;
        default: sfAngle = sf.PdfPageRotateAngle.rotateAngle0;
      }
      
      final pagesToRotate = pageNumbers ?? List.generate(document.pages.count, (i) => i);
      
      for (final index in pagesToRotate) {
        if (index >= 0 && index < document.pages.count) {
          document.pages[index].rotation = sfAngle;
        }
      }
      
      final List<int> bytes = document.saveSync();
      document.dispose();
      
      final File outFile = File(outputPath);
      await outFile.writeAsBytes(bytes);
      return Right(outFile);
    } catch (e) {
      return Left(CacheFailure('Rotate PDF failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, File>> reorderPdf({
    required File inputFile,
    required String outputPath,
    required List<int> newPageOrder,
  }) async {
    try {
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: await inputFile.readAsBytes());
      final sf.PdfDocument newDocument = sf.PdfDocument();
      
      for (final index in newPageOrder) {
        if (index >= 0 && index < document.pages.count) {
          final sf.PdfPage templatePage = document.pages[index];
          final sf.PdfPage newPage = newDocument.pages.add();
          newPage.graphics.drawPdfTemplate(
            templatePage.createTemplate(),
            Offset.zero,
          );
        }
      }
      
      final List<int> bytes = newDocument.saveSync();
      document.dispose();
      newDocument.dispose();
      
      final File outFile = File(outputPath);
      await outFile.writeAsBytes(bytes);
      return Right(outFile);
    } catch (e) {
      return Left(CacheFailure('Reorder PDF failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, File>> addTextToPdf({
    required File inputFile,
    required String outputPath,
    required String text,
    required double x,
    required double y,
  }) async {
    try {
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: await inputFile.readAsBytes());
      
      if (document.pages.count > 0) {
        final sf.PdfPage page = document.pages[0]; // Adding to first page for now
        page.graphics.drawString(
          text,
          sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 16),
          bounds: Rect.fromLTWH(x, y, 500, 100),
          brush: sf.PdfSolidBrush(sf.PdfColor(0, 0, 0)),
        );
      }
      
      final List<int> bytes = document.saveSync();
      document.dispose();
      
      final File outFile = File(outputPath);
      await outFile.writeAsBytes(bytes);
      return Right(outFile);
    } catch (e) {
      return Left(CacheFailure('Add text failed: ${e.toString()}'));
    }
  }
  @override
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
  }) async {
    try {
      final sf.PdfDocument document = sf.PdfDocument(inputBytes: await inputFile.readAsBytes());
      
      if (document.pages.count > pageIndex) {
        final sf.PdfPage page = document.pages[pageIndex];
        final sf.PdfBitmap image = sf.PdfBitmap(await signatureImage.readAsBytes());
        
        page.graphics.save();
        // Translate to the center of where the image will be drawn
        page.graphics.translateTransform(x + width / 2, y + height / 2);
        
        // Apply rotation (Syncfusion expects degrees)
        if (rotation != 0.0) {
          // Convert radians to degrees
          final double degrees = rotation * (180.0 / 3.1415926535897932);
          page.graphics.rotateTransform(degrees);
        }
        
        // Draw image centered at the origin
        page.graphics.drawImage(
          image,
          Rect.fromLTWH(-width / 2, -height / 2, width, height),
        );
        page.graphics.restore();
      }
      
      final List<int> bytes = document.saveSync();
      document.dispose();
      
      final File outFile = File(outputPath);
      await outFile.writeAsBytes(bytes);
      return Right(outFile);
    } catch (e) {
      return Left(CacheFailure('Add signature failed: ${e.toString()}'));
    }
  }
}
