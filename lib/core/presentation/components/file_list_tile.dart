import 'package:flutter/material.dart';


class FileListTile extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const FileListTile({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.date,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.description_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      title: Text(
        fileName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '$fileSize • $date',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, size: 20),
        onPressed: onMoreTap,
      ),
      onTap: onTap,
    );
  }
}
