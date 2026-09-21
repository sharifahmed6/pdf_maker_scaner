import 'package:equatable/equatable.dart';

class FileEntity extends Equatable {
  final String id;
  final String name;
  final String path;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String type; // e.g., 'pdf', 'image'

  const FileEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.createdAt,
    required this.modifiedAt,
    this.type = 'pdf',
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [id, name, path, sizeBytes, createdAt, modifiedAt, type];
}
