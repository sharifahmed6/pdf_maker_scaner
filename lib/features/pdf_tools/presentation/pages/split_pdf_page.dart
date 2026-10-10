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
import '../bloc/split_pdf_bloc.dart';
import '../bloc/split_pdf_event.dart';
import '../bloc/split_pdf_state.dart';

class SplitPdfPage extends StatelessWidget {
  const SplitPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<SplitPdfBloc>(),
      child: const SplitPdfView(),
    );
  }
}

class SplitPdfView extends StatelessWidget {
  const SplitPdfView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF'),
      ),
      body: BlocConsumer<SplitPdfBloc, SplitPdfState>(
        listener: (context, state) {
          if (state is SplitPdfError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SplitPdfLoading) {
            return const ToolProcessingView(
              title: 'Splitting PDF...',
              subtitle: 'Extracting selected pages.',
            );
          }
          
          if (state is SplitPdfSuccess) {
            final fileSizeStr = state.splitFile.existsSync() ? formatFileSize(state.splitFile.lengthSync()) : '';
            return ToolSuccessView(
              title: 'PDF Split Successfully',
              subtitle: 'Selected pages extracted into a new PDF.',
              fileInfoCard: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.call_split, color: Colors.orange),
                  title: Text(state.splitFile.path.split('/').last),
                  subtitle: Text(fileSizeStr),
                ),
              ),
              onOpen: () {
                OpenFilex.open(state.splitFile.path);
              },
              onShare: () {
                Share.shareXFiles([XFile(state.splitFile.path)], text: 'Here is your split PDF.');
              },
              onSave: () {
                FileSaverUtil.saveFile(context, state.splitFile, state.splitFile.path.split('/').last);
              },
              onDone: () {
                context.pop();
              },
            );
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.selectedFile == null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call_split, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('Select a PDF to Split', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Choose a document to extract specific pages from.',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'File: ${p.basename(state.selectedFile!.path)}',
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select the pages you want to extract:',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: state.totalPages,
                            itemBuilder: (context, index) {
                              final isSelected = state.selectedPages.contains(index);
                              return InkWell(
                                onTap: () {
                                  context.read<SplitPdfBloc>().add(TogglePageSelectionEvent(index));
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : theme.cardColor,
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          'Page ${index + 1}',
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: theme.colorScheme.primary,
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (state.selectedFile == null)
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<SplitPdfBloc>().add(SelectSplitFileEvent());
                    },
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Select PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                else ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<SplitPdfBloc>().add(SelectSplitFileEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Change File'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: state.selectedPages.isNotEmpty
                        ? () {
                            context.read<SplitPdfBloc>().add(ExecuteSplitEvent());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Extract ${state.selectedPages.length} Pages'),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
