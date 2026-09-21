import 'package:equatable/equatable.dart';

abstract class ImageToPdfEvent extends Equatable {
  const ImageToPdfEvent();

  @override
  List<Object?> get props => [];
}

class SelectImagesEvent extends ImageToPdfEvent {}

class RemoveImageEvent extends ImageToPdfEvent {
  final int index;
  const RemoveImageEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class ReorderImagesEvent extends ImageToPdfEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderImagesEvent(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class ExecuteImageToPdfEvent extends ImageToPdfEvent {}
