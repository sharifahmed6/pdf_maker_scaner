import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:pdf_maker_scanner/core/utils/file_saver_util.dart';
import 'package:pdf_maker_scanner/core/utils/file_size_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../injection_container.dart';
import '../../../../core/presentation/components/tool_processing_view.dart';
import '../../../../core/presentation/components/tool_success_view.dart';
import '../../../../core/presentation/components/tool_error_view.dart';
import '../bloc/scanner/scanner_bloc.dart';
import '../bloc/scanner/scanner_event.dart';
import '../bloc/scanner/scanner_state.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScannerBloc>(),
      child: const ScannerView(),
    );
  }
}

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  
  Future<void> _startScan() async {
    try {
      List<String> pictures = await CunningDocumentScanner.getPictures(
        androidScannerMode: AndroidScannerMode.base,
      ) ?? [];
      if (pictures.isNotEmpty && mounted) {
        context.read<ScannerBloc>().add(ProcessScannerEvent(
          params: {'imagePaths': pictures},
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error scanning: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
      ),
      body: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, state) {
          if (state is ScannerLoading) {
            return const ToolProcessingView(title: 'Processing Scanned Documents...');
          } else if (state is ScannerSuccess) {
            final fileSizeStr = state.file.existsSync() ? formatFileSize(state.file.lengthSync()) : '';
            return ToolSuccessView(
              title: 'Documents Scanned and Converted to PDF Successfully',
              fileInfoCard: Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.document_scanner, color: Colors.green),
                  title: Text(state.file.path.split('/').last),
                  subtitle: Text(fileSizeStr),
                ),
              ),
              onOpen: () { OpenFilex.open(state.file.path); },
              onShare: () {
                Share.shareXFiles([XFile(state.file.path)], text: 'Here is the scanned document PDF.');
              },
              onSave: () { FileSaverUtil.saveFile(context, state.file, state.file.path.split('/').last); },
              onDone: () => context.pop(),
            );
          } else if (state is ScannerFailure) {
            return ToolErrorView(
              message: state.message,
              onRetry: _startScan,
              onCancel: () => context.pop(),
            );
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.document_scanner, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'Scan physical documents with your camera.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: _startScan,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Start Scanning'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
