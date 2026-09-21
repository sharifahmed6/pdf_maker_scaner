import 'package:flutter/material.dart';


class SyncDialog extends StatefulWidget {
  const SyncDialog({super.key});

  @override
  State<SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends State<SyncDialog> {
  bool isSyncing = false;
  bool isDone = false;

  void startSync() {
    setState(() {
      isSyncing = true;
    });
    
    // Mock sync delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isSyncing = false;
          isDone = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSyncing && !isDone) ...[
            Icon(Icons.refresh, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Sync your recent files?',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You have 4 PDF files stored on this device. Would you like to save them to your PDF Tools account?',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: startSync,
                child: const Text('Sync Files'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Keep Local'),
              ),
            ),
          ] else if (isSyncing) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Syncing your files...',
              style: theme.textTheme.titleMedium,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 32, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Files synced successfully',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
