import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';

class AiOcrPage extends StatefulWidget {
  const AiOcrPage({super.key});

  @override
  State<AiOcrPage> createState() => _AiOcrPageState();
}

enum AiOcrState { initial, options, processing, result }

class _AiOcrPageState extends State<AiOcrPage> {
  AiOcrState _state = AiOcrState.initial;
  bool _preserveFormatting = true;
  bool _extractTables = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI OCR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_state == AiOcrState.options || _state == AiOcrState.result) {
              setState(() => _state = AiOcrState.initial);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    switch (_state) {
      case AiOcrState.initial:
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.document_scanner, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Extract and understand text from scanned documents using AI.',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () => setState(() => _state = AiOcrState.options),
                icon: const Icon(Icons.upload_file),
                label: const Text('Select File'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        );
      case AiOcrState.options:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mock Preview
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: const Center(child: Text('Document Preview')),
              ),
              const SizedBox(height: 32),
              
              Text('AI Extraction Options', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Preserve formatting'),
                subtitle: const Text('Keep paragraphs and layouts intact'),
                value: _preserveFormatting,
                onChanged: (val) => setState(() => _preserveFormatting = val),
              ),
              SwitchListTile(
                title: const Text('Extract tables'),
                subtitle: const Text('Identify and structure tabular data'),
                value: _extractTables,
                onChanged: (val) => setState(() => _extractTables = val),
              ),
              
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _state = AiOcrState.processing);
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) setState(() => _state = AiOcrState.result);
                  });
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Extract with AI'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        );
      case AiOcrState.processing:
        return const ToolProcessingView(
          title: 'Analyzing Document...',
          subtitle: 'AI is recognizing text and formatting results.',
        );
      case AiOcrState.result:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: 'AI successfully extracted and structured this text while preserving formatting.\n\nTables detected: 1'),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
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
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'Share',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.save),
                    tooltip: 'Export',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }
}
