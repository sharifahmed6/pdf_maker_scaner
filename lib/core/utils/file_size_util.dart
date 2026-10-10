import 'dart:math';

String formatFileSize(int bytes) {
  if (bytes <= 0) return '0 B';
  if (bytes < 1000) return '$bytes B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  var i = (log(bytes) / log(1000)).floor();
  return '${(bytes / pow(1000, i)).toStringAsFixed(i == 0 ? 0 : 2)} ${suffixes[i]}';
}
