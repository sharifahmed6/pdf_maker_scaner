import 'package:flutter/material.dart';


class CloudSyncPage extends StatefulWidget {
  const CloudSyncPage({super.key});

  @override
  State<CloudSyncPage> createState() => _CloudSyncPageState();
}

class _CloudSyncPageState extends State<CloudSyncPage> {
  bool _syncAutomatically = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_outlined, color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cloud Storage', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Used: 24 MB', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Toggle
          SwitchListTile(
            title: const Text('Sync files automatically'),
            subtitle: const Text('Keep your PDF files synced with your PDF Tools account.'),
            value: _syncAutomatically,
            onChanged: (val) {
              setState(() {
                _syncAutomatically = val;
              });
            },
            contentPadding: EdgeInsets.zero,
            activeColor: theme.colorScheme.primary,
          ),
          
          const Divider(),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last synced: Today, 10:32 AM',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Sync Now'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
