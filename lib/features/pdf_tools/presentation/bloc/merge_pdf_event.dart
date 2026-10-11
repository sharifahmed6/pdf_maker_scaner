import 'package:equatable/equatable.dart';

abstract class MergePdfEvent extends Equatable {
  const MergePdfEvent();

  @override
  List<Object?> get props => [];
}

class SelectFilesEvent extends MergePdfEvent {}

class RemoveFileEvent extends MergePdfEvent {
  final int index;
  const RemoveFileEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ReorderFilesEvent extends MergePdfEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderFilesEvent(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class MergeFilesEvent extends MergePdfEvent {}
