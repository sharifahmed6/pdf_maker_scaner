import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:signature/signature.dart' hide SignatureState;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../injection_container.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';
import '../../../../core/presentation/components/tool_error_view.dart';
import '../bloc/signature/signature_bloc.dart';
import '../bloc/signature/signature_event.dart';
import '../bloc/signature/signature_state.dart';
import 'package:pdf_maker_scanner/core/utils/file_saver_util.dart';
import 'package:pdf_maker_scanner/core/utils/web_saver.dart';

class SignaturePageWrapper extends StatelessWidget {
  const SignaturePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SignatureBloc>(),
      child: const SignaturePage(),
    );
  }
}

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

enum SignaturePhase { drawing, placing }
enum SignatureInputType { draw, type, upload }

class _SignaturePageState extends State<SignaturePage> {
  SignaturePhase _phase = SignaturePhase.drawing;
  SignatureInputType _inputType = SignatureInputType.draw;
  Color _selectedColor = Colors.black;
  late SignatureController _signatureController;

  final TextEditingController _typedSignatureController = TextEditingController();
  int _selectedFontIndex = 0;

  final List<TextStyle Function({Color? color, double? fontSize, FontWeight? fontWeight})> _fontStyles = [
    GoogleFonts.caveat,
    GoogleFonts.greatVibes,
    GoogleFonts.dancingScript,
    GoogleFonts.pacifico,
    GoogleFonts.alexBrush,
    GoogleFonts.sacramento,
    GoogleFonts.satisfy,
    GoogleFonts.yellowtail,
    GoogleFonts.cookie,
    GoogleFonts.kaushanScript,
    GoogleFonts.marckScript,
    GoogleFonts.parisienne,
  ];
  final List<String> _fontNames = [
    'Caveat',
    'Great Vibes',
    'Dancing Script',
    'Pacifico',
    'Alex Brush',
    'Sacramento',
    'Satisfy',
    'Yellowtail',
    'Cookie',
    'Kaushan Script',
    'Marck Script',
    'Parisienne',
  ];
  
  SignatureController _createController({List<Point>? points, Color? color}) {
    return SignatureController(
      penStrokeWidth: 3,
      penColor: color ?? _selectedColor,
      exportBackgroundColor: Colors.transparent,
      points: points,
      onDrawStart: () {
        if (mounted) setState(() {});
      },
      onDrawEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _signatureController = _createController();
  }
  
  File? _selectedFile;
  File? _signatureImageFile;
  // Web support: store bytes since dart:io File doesn't work on web
  Uint8List? _selectedFileBytes;
  Uint8List? _signatureImageBytes;
  String _selectedFileName = '';
  Size _pdfPageSize = const Size(595, 842);
  
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPageIndex = 0;
  int _totalPages = 1;
  
  // Placement State
  Offset _signaturePosition = const Offset(50, 50);
  double _scale = 1.0;
  double _rotation = 0.0;
  bool _isSelected = true;
  
  // Base dimensions of the signature image container
  double _baseWidth = 120.0;
  double _baseHeight = 40.0;

  BoxConstraints? _pdfConstraints;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result.isNotEmpty) {
      final picked = result.first;
      Uint8List? bytes;

      if (kIsWeb) {
        bytes = await picked.readAsBytes();
      } else if (picked.path != null) {
        bytes = await File(picked.path!).readAsBytes();
      }

      if (bytes == null) return;

      try {
        final document = sf.PdfDocument(inputBytes: bytes);
        if (document.pages.count > 0) {
          _pdfPageSize = document.pages[0].size;
          _totalPages = document.pages.count;
          _currentPageIndex = 0;
        }
        document.dispose();
      } catch (e) {
        debugPrint("Error reading PDF size: $e");
      }

      setState(() {
        _selectedFileBytes = bytes;
        _selectedFileName = picked.name;
        if (!kIsWeb && picked.path != null) {
          _selectedFile = File(picked.path!);
        }
      });
    }
  }
  
  Future<void> _uploadImageSignature() async {
    if (_selectedFile == null && _selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a PDF first')));
      return;
    }
    
    final result = await FilePicker.pickFiles(
      type: FileType.image,
    );
    
    if (result.isNotEmpty) {
      final picked = result.first;
      Uint8List? imgBytes;

      if (kIsWeb) {
        imgBytes = await picked.readAsBytes();
      } else if (picked.path != null) {
        imgBytes = await File(picked.path!).readAsBytes();
        _signatureImageFile = File(picked.path!);
      }

      if (imgBytes == null) return;

      final imgSize = await _getImageSize(imgBytes);
      double aspect = (imgSize.height > 0) ? imgSize.width / imgSize.height : 3.0;
      double targetW = (_pdfConstraints != null) ? _pdfConstraints!.maxWidth * 0.28 : 120.0;
      double targetH = targetW / aspect;

      setState(() {
        _baseWidth = targetW;
        _baseHeight = targetH;
        _signatureImageBytes = imgBytes;
        if (!kIsWeb && picked.path != null) {
          _signatureImageFile = File(picked.path!);
        }
        _phase = SignaturePhase.placing;
        _scale = 1.0;
        _rotation = 0.0;
        _isSelected = true;
        double initX = ((_pdfConstraints?.maxWidth ?? 300) - targetW) / 2;
        double initY = ((_pdfConstraints?.maxHeight ?? 400) - targetH) * 0.7;
        _signaturePosition = Offset(initX.clamp(0.0, double.infinity), initY.clamp(0.0, double.infinity));
      });
    }
  }


  Future<ui.Size> _getImageSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final size = ui.Size(frame.image.width.toDouble(), frame.image.height.toDouble());
      frame.image.dispose();
      return size;
    } catch (e) {
      return const ui.Size(120, 40);
    }
  }

  Future<Uint8List> _textToSignatureImage(String text, TextStyle textStyle) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    const paddingHorizontal = 30.0;
    const paddingVertical = 20.0;
    final width = textPainter.width + (paddingHorizontal * 2);
    final height = textPainter.height + (paddingVertical * 2);

    textPainter.paint(canvas, const Offset(paddingHorizontal, paddingVertical));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.ceil(), height.ceil());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    return byteData!.buffer.asUint8List();
  }

  Future<void> _proceedToPlacing() async {
    if (_selectedFile == null && _selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a PDF first')));
      return;
    }

    Uint8List? imageBytes;

    if (_inputType == SignatureInputType.draw) {
      if (_signatureController.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please draw your signature first')));
        return;
      }
      imageBytes = await _signatureController.toPngBytes();
    } else if (_inputType == SignatureInputType.type) {
      final text = _typedSignatureController.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please type your signature')));
        return;
      }
      final fontFunc = _fontStyles[_selectedFontIndex];
      final textStyle = fontFunc(color: _selectedColor, fontSize: 48);
      imageBytes = await _textToSignatureImage(text, textStyle);
    } else if (_inputType == SignatureInputType.upload) {
      if (_signatureImageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload a signature image first')));
        return;
      }
      imageBytes = _signatureImageBytes;
    }

    if (imageBytes != null) {
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        final sigFile = File('${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
        await sigFile.writeAsBytes(imageBytes);
        _signatureImageFile = sigFile;
      }

      final imgSize = await _getImageSize(imageBytes);
      double aspect = (imgSize.height > 0) ? imgSize.width / imgSize.height : 3.0;
      double targetW = (_pdfConstraints != null) ? _pdfConstraints!.maxWidth * 0.28 : 120.0;
      double targetH = targetW / aspect;

      setState(() {
        _baseWidth = targetW;
        _baseHeight = targetH;
        _signatureImageBytes = imageBytes;
        _phase = SignaturePhase.placing;
        _scale = 1.0;
        _rotation = 0.0;
        _isSelected = true;
        double initX = ((_pdfConstraints?.maxWidth ?? 300) - targetW) / 2;
        double initY = ((_pdfConstraints?.maxHeight ?? 400) - targetH) * 0.7;
        _signaturePosition = Offset(initX.clamp(0.0, double.infinity), initY.clamp(0.0, double.infinity));
      });
    }
  }
  
  void _saveFinalSignature(BuildContext context) {
    if ((_selectedFile == null && _selectedFileBytes == null) || (_signatureImageFile == null && _signatureImageBytes == null) || _pdfConstraints == null) return;
    
    // Calculate relative coordinates
    double ratioX = _pdfPageSize.width / _pdfConstraints!.maxWidth;
    double ratioY = _pdfPageSize.height / _pdfConstraints!.maxHeight;
    
    double actualX = _signaturePosition.dx * ratioX;
    double actualY = _signaturePosition.dy * ratioY;
    
    // Apply ratio to the scaled width/height
    double currentWidth = _baseWidth * _scale;
    double currentHeight = _baseHeight * _scale;
    
    double actualWidth = currentWidth * ratioX;
    double actualHeight = currentHeight * ratioY;

    context.read<SignatureBloc>().add(ProcessSignatureEvent(
      inputFile: _selectedFile,
      inputFileBytes: _selectedFileBytes,
      signatureImageBytes: _signatureImageBytes,
      params: {
        'signatureFile': _signatureImageFile?.path,
        'x': actualX,
        'y': actualY,
        'width': actualWidth,
        'height': actualHeight,
        'rotation': _rotation,
        'pageIndex': _currentPageIndex,
      }
    ));
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _typedSignatureController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Signature'),
        actions: [
          if (_phase == SignaturePhase.drawing)
            TextButton(
              onPressed: _proceedToPlacing,
              child: const Text('Next'),
            ),
        ],
      ),
      body: BlocBuilder<SignatureBloc, SignatureState>(
        builder: (context, state) {
          if (state is SignatureLoading) {
            return const ToolProcessingView(title: 'Applying Signature...');
          } else if (state is SignatureSuccess) {
            return ToolSuccessView(
              title: 'Signature Added Successfully',
              onOpen: () {
                if (kIsWeb && state.bytes != null) {
                  openBytesInNewTabOnWeb(state.bytes!);
                } else if (state.file != null) {
                  OpenFilex.open(state.file!.path);
                }
              },
              onShare: () {
                if (kIsWeb && state.bytes != null) {
                  Share.shareXFiles([
                    XFile.fromData(
                      state.bytes!,
                      mimeType: 'application/pdf',
                      name: 'signed_signature.pdf',
                    )
                  ], text: 'Here is the signed PDF.');
                } else if (state.file != null) {
                  Share.shareXFiles([XFile(state.file!.path)], text: 'Here is the signed PDF.');
                }
              },
              onSave: () {
                if (kIsWeb && state.bytes != null) {
                  downloadBytesOnWeb(state.bytes!, 'signed_signature.pdf');
                } else if (state.file != null) {
                  FileSaverUtil.saveFile(context, state.file!, state.file!.path.split('/').last);
                }
              },
              onDone: () => context.pop(),
            );
          } else if (state is SignatureFailure) {
            return ToolErrorView(
              message: state.message,
              onRetry: () => context.pop(),
              onCancel: () => context.pop(),
            );
          }
          
          if (_phase == SignaturePhase.drawing) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SegmentedButton<SignatureInputType>(
                      segments: const [
                        ButtonSegment(value: SignatureInputType.draw, label: Text('Draw'), icon: Icon(Icons.gesture)),
                        ButtonSegment(value: SignatureInputType.type, label: Text('Type'), icon: Icon(Icons.text_fields)),
                        ButtonSegment(value: SignatureInputType.upload, label: Text('Upload'), icon: Icon(Icons.upload_file)),
                      ],
                      selected: {_inputType},
                      onSelectionChanged: (Set<SignatureInputType> selection) {
                        setState(() {
                          _inputType = selection.first;
                        });
                      },
                    ),
                  ),
                  Container(
                    height: _inputType == SignatureInputType.type ? 280 : 240,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                    ),
                    child: _buildSignatureInputBody(theme),
                  ),
                  if (_inputType == SignatureInputType.draw || _inputType == SignatureInputType.type)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Color: '),
                          const SizedBox(width: 8),
                          _buildColorOption(Colors.black),
                          const SizedBox(width: 16),
                          _buildColorOption(Colors.blue),
                          const SizedBox(width: 16),
                          _buildColorOption(Colors.red),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _showColorPicker,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const SweepGradient(
                                  colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red],
                                ),
                                border: Border.all(color: Theme.of(context).colorScheme.primary, width: _selectedColor != Colors.black && _selectedColor != Colors.blue && _selectedColor != Colors.red ? 3 : 1),
                              ),
                              child: const Icon(Icons.colorize, size: 20, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: (_selectedFile == null && _selectedFileBytes == null) ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                          const SizedBox(height: 12),
                          Text('Select a PDF to place your signature', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _pickFile, child: const Text('Choose PDF')),
                        ],
                      ) : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 48, color: Colors.green),
                          const SizedBox(height: 12),
                          Text('PDF Selected: $_selectedFileName'),
                          const SizedBox(height: 12),
                          OutlinedButton(onPressed: _pickFile, child: const Text('Change PDF')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Placing Phase
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Drag, pinch to zoom, and rotate your signature.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      if (_totalPages > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _pdfViewerController.previousPage(),
                                child: const Icon(Icons.arrow_back_ios, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text('${_currentPageIndex + 1} / $_totalPages', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _pdfViewerController.nextPage(),
                                child: const Icon(Icons.arrow_forward_ios, size: 24),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double pdfWidth = _pdfPageSize.width > 0 ? _pdfPageSize.width : 595.0;
                        double pdfHeight = _pdfPageSize.height > 0 ? _pdfPageSize.height : 842.0;
                        double pdfAspect = pdfWidth / pdfHeight;
                        double containerAspect = constraints.maxWidth / constraints.maxHeight;

                        double renderedWidth;
                        double renderedHeight;

                        if (containerAspect > pdfAspect) {
                          renderedHeight = constraints.maxHeight;
                          renderedWidth = renderedHeight * pdfAspect;
                        } else {
                          renderedWidth = constraints.maxWidth;
                          renderedHeight = renderedWidth / pdfAspect;
                        }

                        _pdfConstraints = BoxConstraints.tight(Size(renderedWidth, renderedHeight));

                        return Center(
                          child: Container(
                            width: renderedWidth,
                            height: renderedHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.4), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // PDF Viewer Layer (Bottom)
                                Positioned.fill(
                                  child: _selectedFileBytes != null
                                              ? SfPdfViewer.memory(
                                                  _selectedFileBytes!,
                                                  key: ValueKey('pdf_${_selectedFileBytes.hashCode}'),
                                                  controller: _pdfViewerController,
                                                  pageLayoutMode: PdfPageLayoutMode.single,
                                                  canShowScrollHead: false,
                                                  canShowScrollStatus: false,
                                                  enableDoubleTapZooming: false,
                                                  enableTextSelection: false,
                                                  onPageChanged: (PdfPageChangedDetails details) {
                                                    setState(() {
                                                      _currentPageIndex = details.newPageNumber - 1;
                                                    });
                                                  },
                                                )
                                              : (_selectedFile != null
                                                ? SfPdfViewer.file(
                                                    _selectedFile!,
                                                    key: ValueKey('pdf_file_${_selectedFile!.path}'),
                                                    controller: _pdfViewerController,
                                                    pageLayoutMode: PdfPageLayoutMode.single,
                                                    canShowScrollHead: false,
                                                    canShowScrollStatus: false,
                                                    enableDoubleTapZooming: false,
                                                    enableTextSelection: false,
                                                    onPageChanged: (PdfPageChangedDetails details) {
                                                      setState(() {
                                                        _currentPageIndex = details.newPageNumber - 1;
                                                      });
                                                    },
                                                  )
                                                : const SizedBox()),
                                ),
                                // Overlay Layer with Selection Control
                                StatefulBuilder(
                                  builder: (context, setOverlayState) {
                                    double sigWidth = _baseWidth * _scale;
                                    double sigHeight = _baseHeight * _scale;
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Transparent Deselect Layer (Middle)
                                        Positioned.fill(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              setOverlayState(() {
                                                _isSelected = false;
                                              });
                                            },
                                            child: const SizedBox.expand(),
                                          ),
                                        ),
                                        // Signature Item
                                        Positioned(
                                          left: _signaturePosition.dx - 16.0,
                                          top: _signaturePosition.dy - 16.0,
                                          child: Transform.rotate(
                                            angle: _rotation,
                                            child: SizedBox(
                                              width: sigWidth + 32.0,
                                              height: sigHeight + 32.0,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  // Main Container (The Signature Box)
                                                  Positioned(
                                                    left: 16.0,
                                                    top: 16.0,
                                                    width: sigWidth,
                                                    height: sigHeight,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setOverlayState(() {
                                                          _isSelected = true;
                                                        });
                                                      },
                                                      onPanStart: (_) {
                                                        setOverlayState(() {
                                                          _isSelected = true;
                                                        });
                                                      },
                                                      onPanUpdate: (details) {
                                                        setOverlayState(() {
                                                          _isSelected = true;
                                                          double newX = _signaturePosition.dx + details.delta.dx;
                                                          double newY = _signaturePosition.dy + details.delta.dy;
                                                          if (_pdfConstraints != null) {
                                                            double minX = -sigWidth + 30.0;
                                                            double maxX = _pdfConstraints!.maxWidth - 30.0;
                                                            double minY = -sigHeight + 30.0;
                                                            double maxY = _pdfConstraints!.maxHeight - 30.0;
                                                            newX = newX.clamp(minX, maxX);
                                                            newY = newY.clamp(minY, maxY);
                                                          }
                                                          _signaturePosition = Offset(newX, newY);
                                                        });
                                                      },
                                                      child: Container(
                                                        width: sigWidth,
                                                        height: sigHeight,
                                                        decoration: BoxDecoration(
                                                          border: _isSelected
                                                            ? Border.all(color: theme.colorScheme.primary, width: 2, style: BorderStyle.solid)
                                                            : null,
                                                          color: _isSelected
                                                            ? Colors.white.withValues(alpha: 0.2)
                                                            : Colors.transparent,
                                                        ),
                                                        child: _signatureImageBytes != null
                                                          ? Image.memory(
                                                              _signatureImageBytes!,
                                                              fit: BoxFit.contain,
                                                            )
                                                          : Image.file(
                                                              _signatureImageFile!,
                                                              fit: BoxFit.contain,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Bottom Right: Scale Handle
                                                  if (_isSelected)
                                                    Positioned(
                                                      right: 1,
                                                      bottom: 1,
                                                      child: GestureDetector(
                                                        onPanUpdate: (details) {
                                                          setOverlayState(() {
                                                            double delta = details.delta.dx + details.delta.dy;
                                                            _scale = (_scale + delta * 0.01).clamp(0.2, 5.0);
                                                            sigWidth = _baseWidth * _scale;
                                                            sigHeight = _baseHeight * _scale;
                                                            if (_pdfConstraints != null) {
                                                              double minX = -sigWidth + 30.0;
                                                              double maxX = _pdfConstraints!.maxWidth - 30.0;
                                                              double minY = -sigHeight + 30.0;
                                                              double maxY = _pdfConstraints!.maxHeight - 30.0;
                                                              _signaturePosition = Offset(
                                                                _signaturePosition.dx.clamp(minX, maxX),
                                                                _signaturePosition.dy.clamp(minY, maxY),
                                                              );
                                                            }
                                                          });
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(6),
                                                          decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                                                          child: const Icon(Icons.zoom_out_map, color: Colors.white, size: 18),
                                                        ),
                                                      ),
                                                    ),
                                                  // Top Left: Rotate Handle
                                                  if (_isSelected)
                                                    Positioned(
                                                      left: 1,
                                                      top: 1,
                                                      child: GestureDetector(
                                                        onPanUpdate: (details) {
                                                          setOverlayState(() {
                                                            _rotation += (details.delta.dx + details.delta.dy) * 0.015;
                                                          });
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(6),
                                                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                                          child: const Icon(Icons.rotate_right, color: Colors.white, size: 18),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, right: 24.0, left: 24.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton.extended(
                      onPressed: () => _saveFinalSignature(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Save Signature'),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }


  Widget _buildSignatureInputBody(ThemeData theme) {
    if (_inputType == SignatureInputType.draw) {
      return Stack(
        children: [
          if (_signatureController.isEmpty)
            Center(
              child: Text(
                'Draw your signature here',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              ),
            ),
          Signature(
            controller: _signatureController,
            height: double.infinity,
            backgroundColor: Colors.transparent,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _signatureController.clear(),
              tooltip: 'Clear',
            ),
          ),
        ],
      );
    } else if (_inputType == SignatureInputType.type) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _typedSignatureController,
              decoration: const InputDecoration(
                labelText: 'Type your signature',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_fontNames.length, (index) {
                  final isSelected = _selectedFontIndex == index;
                  final fontFunc = _fontStyles[index];
                  final userText = _typedSignatureController.text.trim();
                  final displayText = userText.isEmpty ? 'Signature' : userText;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFontIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _fontNames[index],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayText,
                            style: fontFunc(
                              color: isSelected ? theme.colorScheme.onPrimaryContainer : _selectedColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 75,
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _typedSignatureController.text.isEmpty ? 'Signature Preview' : _typedSignatureController.text,
                style: _fontStyles[_selectedFontIndex](
                  color: _selectedColor,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_signatureImageBytes != null) ...[
              Container(
                height: 120,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.memory(_signatureImageBytes!),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _uploadImageSignature,
              icon: const Icon(Icons.upload_file),
              label: Text(_signatureImageBytes != null ? 'Change Image Signature' : 'Upload Image Signature'),
            ),
          ],
        ),
      );
    }
  }

  void _showColorPicker() {
    Color tempColor = _selectedColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                tempColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() {
                  _selectedColor = tempColor;
                  final currentPoints = _signatureController.points;
                  _signatureController.dispose();
                  _signatureController = _createController(points: currentPoints, color: _selectedColor);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorOption(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
          final currentPoints = _signatureController.points;
          _signatureController.dispose();
          _signatureController = _createController(points: currentPoints, color: _selectedColor);
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
