import 'package:flutter/material.dart';


class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onSecondaryAction;
  final String secondaryActionText;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'Unable to process this file.',
    required this.onRetry,
    this.onSecondaryAction,
    this.secondaryActionText = 'Choose Another File',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_outlined, size: 48, color: theme.colorScheme.error),
          ),
          const SizedBox(height: 24),
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ),
          if (onSecondaryAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionText),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
