import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_maker_scanner/core/utils/file_saver_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import 'package:pdf_maker_scanner/core/utils/file_size_util.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';
import '../bloc/image_to_pdf_bloc.dart';
import '../bloc/image_to_pdf_event.dart';
import '../bloc/image_to_pdf_state.dart';

class ImageToPdfPage extends StatelessWidget {
  const ImageToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ImageToPdfBloc>(),
      child: const ImageToPdfView(),
    );
  }
}

class ImageToPdfView extends StatelessWidget {
  const ImageToPdfView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to PDF'),
      ),
      body: BlocConsumer<ImageToPdfBloc, ImageToPdfState>(
        listener: (context, state) {
          if (state is ImageToPdfError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ImageToPdfLoading) {
            return const ToolProcessingView(
              title: 'Converting Images...',
              subtitle: 'Creating PDF from your images.',
            );
          }
          
          if (state is ImageToPdfSuccess) {
            final fileSizeStr = state.pdfFile.existsSync() ? formatFileSize(state.pdfFile.lengthSync()) : '';
            return ToolSuccessView(
              title: 'PDF Created Successfully',
              subtitle: 'Your images have been converted to a single PDF document.',
              fileInfoCard: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(state.pdfFile.path.split('/').last),
                  subtitle: Text(fileSizeStr),
                ),
              ),
              onOpen: () {
                OpenFilex.open(state.pdfFile.path);
              },
              onShare: () {
                Share.shareXFiles([XFile(state.pdfFile.path)], text: 'Here is your generated PDF.');
              },
              onSave: () {
                FileSaverUtil.saveFile(context, state.pdfFile, state.pdfFile.path.split('/').last);
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
                if (state.selectedImages.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('No Images selected', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Select images from your gallery to convert them into a single PDF.',
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
                      itemCount: state.selectedImages.length,
                      onReorder: (oldIndex, newIndex) {
                        context.read<ImageToPdfBloc>().add(ReorderImagesEvent(oldIndex, newIndex));
                      },
                      itemBuilder: (context, index) {
                        final file = state.selectedImages[index];
                        return ListTile(
                          key: ValueKey(file.path + index.toString()),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              file,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text('Image \${index + 1}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  context.read<ImageToPdfBloc>().add(RemoveImageEvent(index));
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
                    context.read<ImageToPdfBloc>().add(SelectImagesEvent());
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: state.selectedImages.isNotEmpty
                      ? () {
                          context.read<ImageToPdfBloc>().add(ExecuteImageToPdfEvent());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Convert to PDF'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
