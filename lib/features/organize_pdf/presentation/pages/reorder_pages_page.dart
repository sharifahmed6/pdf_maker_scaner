import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_maker_scanner/core/utils/file_saver_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import '../../../../injection_container.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';
import '../../../../core/presentation/components/tool_error_view.dart';
import '../bloc/organize_pdf_bloc.dart';
import '../bloc/organize_pdf_event.dart';
import '../bloc/organize_pdf_state.dart';

class ReorderPagesPage extends StatelessWidget {
  const ReorderPagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReorderPdfBloc>(),
      child: const ReorderPagesView(),
    );
  }
}

class ReorderPagesView extends StatefulWidget {
  const ReorderPagesView({super.key});

  @override
  State<ReorderPagesView> createState() => _ReorderPagesViewState();
}

class _ReorderPagesViewState extends State<ReorderPagesView> {
  File? _selectedFile;
  List<int> _pages = [];

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.isNotEmpty && result.first.path != null) {
      final file = File(result.first.path!);
      try {
        final document = sf.PdfDocument(inputBytes: await file.readAsBytes());
        final pageCount = document.pages.count;
        document.dispose();
        
        setState(() {
          _selectedFile = file;
          _pages = List.generate(pageCount, (index) => index);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reading PDF: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder Pages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedFile != null) {
              setState(() {
                _selectedFile = null;
                _pages.clear();
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: BlocBuilder<ReorderPdfBloc, ReorderPdfState>(
        builder: (context, state) {
          if (state is ReorderPdfLoading) {
            return const ToolProcessingView(title: 'Reordering Pages...');
          } else if (state is ReorderPdfSuccess) {
            return ToolSuccessView(
              title: 'Pages Reordered Successfully',
              onOpen: () { OpenFilex.open(state.file.path); },
              onShare: () {
                Share.shareXFiles([XFile(state.file.path)], text: 'Here is the organized PDF.');
              },
              onSave: () { FileSaverUtil.saveFile(context, state.file, state.file.path.split('/').last); },
              onDone: () => context.pop(),
            );
          } else if (state is ReorderPdfFailure) {
            return ToolErrorView(
              message: state.message,
              onRetry: () => setState(() => _selectedFile = null),
              onCancel: () => context.pop(),
            );
          }
          
          if (_selectedFile == null) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select PDF to Reorder'),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ReorderableListView.builder(
                itemCount: _pages.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _pages.removeAt(oldIndex);
                    _pages.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final originalPageNum = _pages[index] + 1;
                  return Card(
                    key: ValueKey(_pages[index].toString() + '_' + index.toString()),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        child: Center(child: Text('Pg $originalPageNum')),
                      ),
                      title: Text('Original Page $originalPageNum'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              if (_pages.length > 1) {
                                setState(() {
                                  _pages.removeAt(index);
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cannot remove the last page')),
                                );
                              }
                            },
                          ),
                          const Icon(Icons.drag_handle),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      bottomNavigationBar: _selectedFile != null ? _buildBottomBar(context) : null,
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            context.read<ReorderPdfBloc>().add(
              ProcessReorderPdfEvent(
                inputFile: _selectedFile!,
                params: {'newPageOrder': _pages},
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Save Changes'),
        ),
      ),
    );
  }
}
