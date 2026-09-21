import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../injection_container.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';
import '../../../../core/presentation/components/tool_error_view.dart';
import '../bloc/addtext_bloc.dart';
import '../bloc/addtext_event.dart';
import '../bloc/addtext_state.dart';
import 'package:pdf_maker_scanner/core/utils/file_saver_util.dart';

class AddTextPage extends StatelessWidget {
  const AddTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddTextBloc>(),
      child: const AddTextView(),
    );
  }
}

class AddTextView extends StatefulWidget {
  const AddTextView({super.key});

  @override
  State<AddTextView> createState() => _AddTextViewState();
}

enum AddTextPageState { initial, edit }

class _AddTextViewState extends State<AddTextView> {
  AddTextPageState _pageState = AddTextPageState.initial;
  String _currentText = "Double tap to edit";
  Offset _textPosition = const Offset(50, 50);
  File? _selectedFile;
  Uint8List? _selectedFileBytes;
  Size _pdfPageSize = const Size(595, 842); // Default A4 size

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
        }
        document.dispose();
      } catch (e) {
        debugPrint("Error reading PDF size: $e");
      }

      setState(() {
        _selectedFileBytes = bytes;
        if (!kIsWeb && picked.path != null) {
          _selectedFile = File(picked.path!);
        }
        _pageState = AddTextPageState.edit;
        _textPosition = const Offset(50, 50); // Reset position
      });
    }
  }

  void _editTextField() {
    TextEditingController controller = TextEditingController(text: _currentText);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Text'),
          content: TextField(
            controller: controller,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentText = controller.text;
                });
                context.pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _processAddText(BuildContext context, BoxConstraints constraints) {
    // Calculate relative coordinates
    double ratioX = _pdfPageSize.width / constraints.maxWidth;
    double ratioY = _pdfPageSize.height / constraints.maxHeight;
    
    double actualX = _textPosition.dx * ratioX;
    double actualY = _textPosition.dy * ratioY;

    context.read<AddTextBloc>().add(ProcessAddTextEvent(
      inputFile: _selectedFile!,
      params: {
        'text': _currentText,
        'x': actualX,
        'y': actualY,
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Text'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_pageState == AddTextPageState.edit) {
              setState(() {
                _pageState = AddTextPageState.initial;
                _selectedFile = null;
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: BlocBuilder<AddTextBloc, AddTextState>(
        builder: (context, state) {
          if (state is AddTextLoading) {
            return const ToolProcessingView(title: 'Adding Text...');
          } else if (state is AddTextSuccess) {
            return ToolSuccessView(
              title: 'Text Added Successfully',
              onOpen: () { OpenFilex.open(state.file.path); },
              onShare: () {
                Share.shareXFiles([XFile(state.file.path)], text: 'Here is the PDF.');
              },
              onSave: () { FileSaverUtil.saveFile(context, state.file, state.file.path.split('/').last); },
              onDone: () => context.pop(),
            );
          } else if (state is AddTextFailure) {
            return ToolErrorView(
              message: state.message,
              onRetry: () => setState(() => _pageState = AddTextPageState.initial),
              onCancel: () => context.pop(),
            );
          }
          
          return _buildBody(theme);
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_pageState == AddTextPageState.initial) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('Select PDF'),
        ),
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Drag the text to position it. Double tap to edit.', style: theme.textTheme.bodyMedium),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 2),
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Ensure the container maintains the exact aspect ratio of the PDF page
                return Center(
                  child: AspectRatio(
                    aspectRatio: _pdfPageSize.width / _pdfPageSize.height,
                    child: LayoutBuilder(
                      builder: (context, innerConstraints) {
                        return Stack(
                          children: [
                            // Render PDF page as background
                            Positioned.fill(
                              child: _selectedFileBytes != null
                                ? SfPdfViewer.memory(
                                    _selectedFileBytes!,
                                    canShowScrollHead: false,
                                    canShowScrollStatus: false,
                                    enableDoubleTapZooming: false,
                                    enableTextSelection: false,
                                  )
                                : (_selectedFile != null
                                  ? SfPdfViewer.file(
                                      _selectedFile!,
                                      canShowScrollHead: false,
                                      canShowScrollStatus: false,
                                      enableDoubleTapZooming: false,
                                      enableTextSelection: false,
                                    )
                                  : const SizedBox()),
                            ),
                            // Draggable Text Overlay
                            Positioned(
                              left: _textPosition.dx,
                              top: _textPosition.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    double newX = _textPosition.dx + details.delta.dx;
                                    double newY = _textPosition.dy + details.delta.dy;
                                    // Constrain within boundaries
                                    if (newX < 0) newX = 0;
                                    if (newY < 0) newY = 0;
                                    if (newX > innerConstraints.maxWidth - 50) newX = innerConstraints.maxWidth - 50;
                                    if (newY > innerConstraints.maxHeight - 30) newY = innerConstraints.maxHeight - 30;
                                    
                                    _textPosition = Offset(newX, newY);
                                  });
                                },
                                onDoubleTap: _editTextField,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.colorScheme.primary, style: BorderStyle.solid, width: 2),
                                    color: Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(_currentText, style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            // Save Button at bottom right
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton(
                                onPressed: () => _processAddText(context, innerConstraints),
                                child: const Icon(Icons.check),
                              ),
                            )
                          ],
                        );
                      }
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ],
    );
  }
}
