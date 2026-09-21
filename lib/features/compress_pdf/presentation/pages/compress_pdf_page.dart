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
import '../bloc/compress_pdf_bloc.dart';
import '../bloc/compress_pdf_event.dart';
import '../bloc/compress_pdf_state.dart';

class CompressPdfPage extends StatelessWidget {
  const CompressPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CompressPdfBloc>(),
      child: const CompressPdfView(),
    );
  }
}

class CompressPdfView extends StatefulWidget {
  const CompressPdfView({super.key});

  @override
  State<CompressPdfView> createState() => _CompressPdfViewState();
}

enum CompressLevel { highQuality, recommended, maxCompression }

class _CompressPdfViewState extends State<CompressPdfView> {
  CompressLevel _selectedLevel = CompressLevel.recommended;
  File? _selectedFile;

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
        title: const Text('Compress PDF'),
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
      body: BlocBuilder<CompressPdfBloc, CompressPdfState>(
        builder: (context, state) {
          if (state is CompressPdfLoading) {
            return const ToolProcessingView(
              title: 'Compressing PDF...',
              subtitle: 'Please wait while we reduce the file size.',
            );
          } else if (state is CompressPdfSuccess) {
            return ToolSuccessView(
              title: 'PDF Compressed Successfully',
              fileInfoCard: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Original', '... MB', theme),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      _buildStatItem('Compressed', '... MB', theme),
                      const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              ),
              onOpen: () {
                // Open file logic
              },
              onShare: () {
                Share.shareXFiles([XFile(state.file.path)], text: 'Here is the compressed PDF.');
              },
              onSave: () {
                // Save logic
              },
              onDone: () => context.pop(),
            );
          } else if (state is CompressPdfFailure) {
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

  Widget _buildStatItem(String label, String value, ThemeData theme, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value, 
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compress, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Reduce PDF file size while keeping your document readable.',
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
          
          Text('Compression Level', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _buildOptionCard(
            level: CompressLevel.highQuality,
            title: 'High Quality',
            subtitle: 'Smaller reduction with better visual quality.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            level: CompressLevel.recommended,
            title: 'Recommended',
            subtitle: 'Balanced file size and quality.',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            level: CompressLevel.maxCompression,
            title: 'Maximum Compression',
            subtitle: 'Smallest possible file size.',
            theme: theme,
          ),
          
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              context.read<CompressPdfBloc>().add(
                ProcessCompressPdfEvent(
                  inputFile: _selectedFile!,
                  params: {'level': _selectedLevel.toString()},
                ),
              );
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Compress PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required CompressLevel level,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    final isSelected = _selectedLevel == level;
    return InkWell(
      onTap: () => setState(() => _selectedLevel = level),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Radio<CompressLevel>(
              value: level,
              groupValue: _selectedLevel,
              onChanged: (val) => setState(() => _selectedLevel = val!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
