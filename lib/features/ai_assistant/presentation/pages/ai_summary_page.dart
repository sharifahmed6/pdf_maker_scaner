import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';

class AiSummaryPage extends StatefulWidget {
  const AiSummaryPage({super.key});

  @override
  State<AiSummaryPage> createState() => _AiSummaryPageState();
}

enum SummaryState { initial, processing, result }

class _AiSummaryPageState extends State<AiSummaryPage> {
  SummaryState _state = SummaryState.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI PDF Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_state == SummaryState.result) {
              setState(() => _state = SummaryState.initial);
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
      case SummaryState.initial:
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Get a quick summary of your document with AI.',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _state = SummaryState.processing);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _state = SummaryState.result);
                  });
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Select PDF & Generate'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        );
      case SummaryState.processing:
        return const ToolProcessingView(
          title: 'Analyzing your PDF...',
          subtitle: 'Our AI is reading the document to generate a summary.',
        );
      case SummaryState.result:
        return _buildSummaryResult(theme);
    }
  }

  Widget _buildSummaryResult(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red),
              const SizedBox(width: 8),
              Text('Report_2023.pdf', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Summary', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _buildSection('Overview', 'This document is the annual financial report for 2023, detailing the company\'s performance, revenue streams, and strategic goals for the upcoming year.', theme),
          _buildSection('Key Points', '• Revenue increased by 15%\n• Expansion into European markets\n• Launch of 3 new product lines', theme),
          _buildSection('Conclusion', 'The company is in a strong financial position to continue its aggressive growth strategy in 2024.', theme),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/chat-with-pdf'),
            icon: const Icon(Icons.chat),
            label: const Text('Ask AI about this PDF'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          Text(content, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
