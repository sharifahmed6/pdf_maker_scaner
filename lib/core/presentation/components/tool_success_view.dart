import 'package:flutter/material.dart';

class ToolSuccessView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? fileInfoCard;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback? onDone;
  final String primaryActionLabel;

  const ToolSuccessView({
    super.key,
    required this.title,
    this.subtitle,
    this.fileInfoCard,
    required this.onOpen,
    required this.onShare,
    required this.onSave,
    this.onDone,
    this.primaryActionLabel = 'Open PDF',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          if (fileInfoCard != null) ...[
            const SizedBox(height: 32),
            fileInfoCard!,
          ],
          
          const SizedBox(height: 48),
          
          ElevatedButton(
            onPressed: onOpen,
            child: Text(primaryActionLabel),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
          if (onDone != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onDone,
              child: const Text('Done'),
            ),
          ],
        ],
      ),
    );
  }
}
