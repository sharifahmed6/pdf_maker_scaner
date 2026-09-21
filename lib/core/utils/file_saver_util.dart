import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class FileSaverUtil {
  static Future<String?> saveFile(BuildContext context, File file, String newFileName) async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        // Try to get Downloads directory
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final newPath = '${directory.path}/$newFileName';
        final savedFile = await file.copy(newPath);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to: $newPath')),
          );
        }
        await NotificationService.showDownloadNotification(
          'File Saved',
          'Tap to open $newFileName',
          newPath,
        );
        return newPath;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
    return null;
  }
}
