import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';

class PdfToWordPage extends StatefulWidget {
  const PdfToWordPage({super.key});

  @override
  State<PdfToWordPage> createState() => _PdfToWordPageState();
}

enum ConvertState { initial, processing, success }

class _PdfToWordPageState extends State<PdfToWordPage> {
  ConvertState _state = ConvertState.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to Word'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_state != ConvertState.initial) {
              setState(() => _state = ConvertState.initial);
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
      case ConvertState.initial:
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Convert your PDF into an editable Word document.',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  // Simulating selection -> processing directly since it's a simple flow
                  setState(() => _state = ConvertState.processing);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _state = ConvertState.success);
                  });
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Select PDF to Convert'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        );
      case ConvertState.processing:
        return const ToolProcessingView(
          title: 'Converting PDF...',
          subtitle: 'Uploading and processing on secure servers.',
        );
      case ConvertState.success:
        return ToolSuccessView(
          title: 'Word Document Ready',
          fileInfoCard: Card(
            child: ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: const Text('Report_2023_converted.docx'),
              subtitle: const Text('2.1 MB'),
            ),
          ),
          onOpen: () {},
          onShare: () {},
          onSave: () {},
          onDone: () => context.pop(),
        );
    }
  }
}
