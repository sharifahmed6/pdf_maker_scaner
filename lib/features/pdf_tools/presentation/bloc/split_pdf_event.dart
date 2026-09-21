import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class SplitPdfEvent extends Equatable {
  const SplitPdfEvent();

  @override
  List<Object?> get props => [];
}

class SelectSplitFileEvent extends SplitPdfEvent {}

class TogglePageSelectionEvent extends SplitPdfEvent {
  final int pageIndex;
  const TogglePageSelectionEvent(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

class ExecuteSplitEvent extends SplitPdfEvent {}
