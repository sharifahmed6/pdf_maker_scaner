import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_maker_scanner/core/utils/file_saver_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../injection_container.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';
import '../../../../core/presentation/components/tool_error_view.dart';
import '../bloc/rotate_pdf_bloc.dart';
import '../bloc/rotate_pdf_event.dart';
import '../bloc/rotate_pdf_state.dart';

class RotatePdfPage extends StatelessWidget {
  const RotatePdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RotatePdfBloc>(),
      child: const RotatePdfView(),
    );
  }
}

class RotatePdfView extends StatefulWidget {
  const RotatePdfView({super.key});

  @override
  State<RotatePdfView> createState() => _RotatePdfViewState();
}

class _RotatePdfViewState extends State<RotatePdfView> {
  File? _selectedFile;
  int _rotationAngle = 90;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.isNotEmpty && result.first.path != null) {
      setState(() {
        _selectedFile = File(result.first.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotate PDF'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedFile != null) {
              setState(() => _selectedFile = null);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: BlocBuilder<RotatePdfBloc, RotatePdfState>(
        builder: (context, state) {
          if (state is RotatePdfLoading) {
            return const ToolProcessingView(
              title: 'Rotating PDF...',
              subtitle: 'Applying rotation to your document.',
            );
          } else if (state is RotatePdfSuccess) {
            return ToolSuccessView(
              title: 'PDF Rotated Successfully',
              fileInfoCard: Card(
                child: ListTile(
                  leading: const Icon(Icons.rotate_right, color: Colors.green),
                  title: const Text('Rotated Document'),
                  subtitle: Text('Rotated by $_rotationAngle degrees'),
                ),
              ),
              onOpen: () { OpenFilex.open(state.file.path); },
              onShare: () {
                Share.shareXFiles([XFile(state.file.path)], text: 'Here is the rotated PDF.');
              },
              onSave: () { FileSaverUtil.saveFile(context, state.file, state.file.path.split('/').last); },
              onDone: () => context.pop(),
            );
          } else if (state is RotatePdfFailure) {
            return ToolErrorView(
              message: state.message,
              onRetry: () => setState(() => _selectedFile = null),
              onCancel: () => context.pop(),
            );
          }
          
          if (_selectedFile == null) {
            return _buildInitialState(theme);
          } else {
            return _buildOptionsState(theme);
          }
        },
      ),
    );
  }

  Widget _buildInitialState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rotate_right, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Rotate PDF pages to the correct orientation.',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('Select PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsState(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedFile!.path.split('/').last, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Selected File', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedFile = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          Text('Rotation Angle', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 90, label: Text('90°')),
              ButtonSegment(value: 180, label: Text('180°')),
              ButtonSegment(value: 270, label: Text('270°')),
            ],
            selected: {_rotationAngle},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() => _rotationAngle = newSelection.first);
            },
          ),
          
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              context.read<RotatePdfBloc>().add(
                ProcessRotatePdfEvent(
                  inputFile: _selectedFile!,
                  params: {'angle': _rotationAngle},
                ),
              );
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Rotate PDF'),
          ),
        ],
      ),
    );
  }
}
