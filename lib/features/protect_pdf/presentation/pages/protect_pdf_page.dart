import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_maker_scanner/core/utils/file_saver_util.dart';
import 'package:pdf_maker_scanner/core/utils/file_size_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../injection_container.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';
import '../../../../core/presentation/components/tool_error_view.dart';
import '../bloc/protect_pdf_bloc.dart';
import '../bloc/protect_pdf_event.dart';
import '../bloc/protect_pdf_state.dart';

class ProtectPdfPage extends StatelessWidget {
  const ProtectPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProtectPdfBloc>(),
      child: const ProtectPdfView(),
    );
  }
}

class ProtectPdfView extends StatefulWidget {
  const ProtectPdfView({super.key});

  @override
  State<ProtectPdfView> createState() => _ProtectPdfViewState();
}

class _ProtectPdfViewState extends State<ProtectPdfView> {
  File? _selectedFile;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

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
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protect PDF'),
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
      body: BlocBuilder<ProtectPdfBloc, ProtectPdfState>(
        builder: (context, state) {
          if (state is ProtectPdfLoading) {
            return const ToolProcessingView(
              title: 'Encrypting PDF...',
              subtitle: 'Securing your document with a password.',
            );
          } else if (state is ProtectPdfSuccess) {
            final fileSizeStr = state.file.existsSync() ? formatFileSize(state.file.lengthSync()) : '';
            return ToolSuccessView(
              title: 'PDF Protected Successfully',
              fileInfoCard: Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.lock, color: Colors.green),
                  title: Text(state.file.path.split('/').last),
                  subtitle: Text('$fileSizeStr • Requires password to open'),
                ),
              ),
              onOpen: () { OpenFilex.open(state.file.path); },
              onShare: () {
                Share.shareXFiles([XFile(state.file.path)], text: 'Here is the protected PDF.');
              },
              onSave: () { FileSaverUtil.saveFile(context, state.file, state.file.path.split('/').last); },
              onDone: () => context.pop(),
            );
          } else if (state is ProtectPdfFailure) {
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
          Icon(Icons.lock, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Secure your PDF files with a password to prevent unauthorized access.',
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
              border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
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
          
          Text('Set Password', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              if (_passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a password')),
                );
                return;
              }
              if (_passwordController.text != _confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              
              context.read<ProtectPdfBloc>().add(
                ProcessProtectPdfEvent(
                  inputFile: _selectedFile!,
                  params: {'password': _passwordController.text},
                ),
              );
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Protect PDF'),
          ),
        ],
      ),
    );
  }
}
