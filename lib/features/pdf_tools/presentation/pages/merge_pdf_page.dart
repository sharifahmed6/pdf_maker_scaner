import 'package:flutter/material.dart';
import 'package:pdf_maker_scanner/core/utils/file_saver_util.dart';
import 'package:pdf_maker_scanner/core/utils/file_size_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../injection_container.dart' as di;
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';
import '../bloc/merge_pdf_bloc.dart';
import '../bloc/merge_pdf_event.dart';
import '../bloc/merge_pdf_state.dart';

class MergePdfPage extends StatelessWidget {
  const MergePdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MergePdfBloc>(),
      child: const MergePdfView(),
    );
  }
}

class MergePdfView extends StatelessWidget {
  const MergePdfView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge PDF'),
      ),
      body: BlocConsumer<MergePdfBloc, MergePdfState>(
        listener: (context, state) {
          if (state is MergePdfError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is MergePdfLoading) {
            return const ToolProcessingView(
              title: 'Merging PDFs...',
              subtitle: 'Please wait while we combine your files.',
            );
          }
          
          if (state is MergePdfSuccess) {
            final fileSizeStr = state.mergedFile.existsSync() ? formatFileSize(state.mergedFile.lengthSync()) : '';
            return ToolSuccessView(
              title: 'PDFs Merged Successfully',
              subtitle: 'Your files have been combined into a single PDF.',
              fileInfoCard: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                  title: Text(state.mergedFile.path.split('/').last),
                  subtitle: Text(fileSizeStr),
                ),
              ),
              onOpen: () {
                OpenFilex.open(state.mergedFile.path);
              },
              onShare: () {
                Share.shareXFiles([XFile(state.mergedFile.path)], text: 'Here is your merged PDF.');
              },
              onSave: () {
                FileSaverUtil.saveFile(context, state.mergedFile, state.mergedFile.path.split('/').last);
              },
              onDone: () {
                context.pop();
              },
            );
          }
          
          // Initial state
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.selectedFiles.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_add, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('No PDFs selected', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Select multiple PDF files to combine them into one.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ReorderableListView.builder(
                      itemCount: state.selectedFiles.length,
                      onReorder: (oldIndex, newIndex) {
                        context.read<MergePdfBloc>().add(ReorderFilesEvent(oldIndex, newIndex));
                      },
                      itemBuilder: (context, index) {
                        final file = state.selectedFiles[index];
                        final name = p.basename(file.path);
                        return ListTile(
                          key: ValueKey(file.path + index.toString()),
                          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  context.read<MergePdfBloc>().add(RemoveFileEvent(index));
                                },
                              ),
                              const Icon(Icons.drag_handle),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<MergePdfBloc>().add(SelectFilesEvent());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Files'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: state.selectedFiles.length >= 2
                      ? () {
                          context.read<MergePdfBloc>().add(MergeFilesEvent());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Merge PDFs'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
