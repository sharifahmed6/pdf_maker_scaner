import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import '../../../../injection_container.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';
import '../../../../core/presentation/components/tool_error_view.dart';
import '../bloc/ocr_bloc.dart';
import '../bloc/ocr_event.dart';
import '../bloc/ocr_state.dart';

class OcrPageWrapper extends StatelessWidget {
  const OcrPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OcrBloc>(),
      child: const OcrPage(),
    );
  }
}

class OcrPage extends StatefulWidget {
  const OcrPage({super.key});

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
    );
    if (result.isNotEmpty && result.first.path != null) {
      setState(() {
        _selectedFile = File(result.first.path!);
      });
      if (mounted) {
        context.read<OcrBloc>().add(ProcessOcrEvent(
          inputFile: _selectedFile,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Text Recognition'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: BlocBuilder<OcrBloc, OcrState>(
        builder: (context, state) {
          if (state is OcrLoading) {
            return const ToolProcessingView(title: 'Recognizing Text...');
          } else if (state is OcrSuccess) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: state.text),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Extracted text will appear here',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy',
                        onPressed: () {
                          if (state.text != null) {
                            Clipboard.setData(ClipboardData(text: state.text!));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Text copied to clipboard')));
                          }
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFile = null;
                          });
                          context.pop();
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is OcrFailure) {
            return ToolErrorView(
              message: state.message,
              onRetry: _pickFile,
              onCancel: () => context.pop(),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.document_scanner, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'Extract text from images (PNG, JPG).',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select Image'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
