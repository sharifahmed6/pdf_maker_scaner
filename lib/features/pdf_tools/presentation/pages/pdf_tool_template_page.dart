import 'package:flutter/material.dart';

import '../../../../core/presentation/components/empty_state.dart';
import '../../../../core/presentation/components/error_state.dart';
import '../../../../core/presentation/components/loading_state.dart';

enum ToolState { selection, processing, success, error }

class PdfToolTemplatePage extends StatefulWidget {
  final String toolName;

  const PdfToolTemplatePage({
    super.key,
    required this.toolName,
  });

  @override
  State<PdfToolTemplatePage> createState() => _PdfToolTemplatePageState();
}

class _PdfToolTemplatePageState extends State<PdfToolTemplatePage> {
  ToolState _currentState = ToolState.selection;

  void _simulateProcessing() {
    setState(() {
      _currentState = ToolState.processing;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          // Randomly show success or error for demo purposes
          _currentState = DateTime.now().second % 2 == 0 ? ToolState.success : ToolState.error;
        });
      }
    });
  }

  void _reset() {
    setState(() {
      _currentState = ToolState.selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.toolName),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentState) {
      case ToolState.selection:
        return _buildSelectionState();
      case ToolState.processing:
        return const LoadingState(message: 'Processing PDF...');
      case ToolState.success:
        return _buildSuccessState();
      case ToolState.error:
        return ErrorState(
          onRetry: _simulateProcessing,
          onSecondaryAction: _reset,
        );
    }
  }

  Widget _buildSelectionState() {
    return EmptyState(
      icon: Icons.note_add_outlined,
      title: 'Select a file',
      description: 'Choose a PDF file from your device to begin.',
      buttonText: 'Choose File',
      onButtonTap: _simulateProcessing,
    );
  }

  Widget _buildSuccessState() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 64, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Success!',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your file has been processed successfully.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 32),
          
          Card(
            child: ListTile(
              leading: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
              title: const Text('Merged_Document.pdf'),
              subtitle: const Text('4.2 MB'),
            ),
          ),
          
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Open'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _reset,
            child: const Text('Create Another'),
          )
        ],
      ),
    );
  }
}
