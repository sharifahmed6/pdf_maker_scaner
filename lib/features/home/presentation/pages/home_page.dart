import 'package:flutter/material.dart';
import 'package:device_responsive/device_responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/presentation/components/premium_badge.dart';
import '../../../../core/presentation/components/tool_card.dart';
import '../../../../core/presentation/components/premium_locked_card.dart';
import '../../../../core/presentation/components/premium_locked_bottom_sheet.dart';
import '../../../../core/presentation/components/ad_placeholder.dart';
import '../../../../core/presentation/components/file_list_tile.dart';
import '../../../files/presentation/bloc/files_bloc.dart';
import '../../../files/presentation/bloc/files_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Mock state for UI demonstration
  final bool isPremium = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PDF Tools', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Everything you need for your PDF',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: PremiumBadge(
                      isPremium: isPremium,
                      onTap: () {
                        context.push('/premium');
                      },
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary Action
                    ToolCard(
                      icon: Icons.document_scanner_outlined,
                      title: 'Scan Document',
                      subtitle: 'Turn paper documents into PDF',
                      isLarge: true,
                      onTap: () => context.push('/scanner'),
                    ),
                    const SizedBox(height: 24),

                    // PDF Tools Section
                    Text('PDF Tools', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: context.device(m: 3, t: 4, d: 5) ?? 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: context.device(m: 0.95, t: 1.1) ?? 0.95,
                      children: [
                        ToolCard(icon: Icons.merge_type, title: 'Merge', onTap: () => context.push('/merge-pdf')),
                        ToolCard(icon: Icons.call_split, title: 'Split', onTap: () => context.push('/split-pdf')),
                        ToolCard(icon: Icons.compress, title: 'Compress', onTap: () => context.push('/compress-pdf')),
                        ToolCard(icon: Icons.rotate_right, title: 'Rotate', onTap: () => context.push('/rotate-pdf')),
                        ToolCard(icon: Icons.swap_vert, title: 'Reorder', onTap: () => context.push('/reorder-pages')),
                        ToolCard(icon: Icons.lock_outline, title: 'Protect', onTap: () => context.push('/protect-pdf')),
                        ToolCard(icon: Icons.title, title: 'Add Text', onTap: () => context.push('/add-text')),
                        ToolCard(icon: Icons.draw, title: 'Sign', onTap: () => context.push('/signature')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Convert & Extract Section
                    Text('Convert & Extract', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: context.device(m: 3, t: 4, d: 5) ?? 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: context.device(m: 0.95, t: 1.1) ?? 0.95,
                      children: [
                        ToolCard(icon: Icons.image_outlined, title: 'Img to PDF', onTap: () => context.push('/img-to-pdf')),
                        ToolCard(icon: Icons.picture_as_pdf_outlined, title: 'PDF to Img', onTap: () {}),
                        ToolCard(icon: Icons.document_scanner, title: 'OCR', onTap: () => context.push('/ocr')),
                        PremiumLockedCard(icon: Icons.description, title: 'PDF to Word', onTap: () => PremiumLockedBottomSheet.show(context)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // AI Tools Section
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
                        const SizedBox(width: 8),
                        Text('AI Tools', style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: context.device(m: 3, t: 4, d: 5) ?? 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: context.device(m: 0.95, t: 1.1) ?? 0.95,
                      children: [
                        PremiumLockedCard(icon: Icons.summarize, title: 'AI Summary', onTap: () => PremiumLockedBottomSheet.show(context)),
                        PremiumLockedCard(icon: Icons.chat, title: 'Chat with PDF', onTap: () => PremiumLockedBottomSheet.show(context)),
                        PremiumLockedCard(icon: Icons.document_scanner, title: 'AI OCR', onTap: () => PremiumLockedBottomSheet.show(context)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Recent Files Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Files', style: theme.textTheme.titleMedium),
                        TextButton(
                          onPressed: () {
                            // Navigate to files tab
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    BlocBuilder<FilesBloc, FilesState>(
                      builder: (context, state) {
                        if (state is FilesLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is FilesLoaded) {
                          if (state.files.isEmpty) {
                            return _buildEmptyState(context);
                          }
                          
                          // Show only up to 3 recent files
                          final recentFiles = state.files.take(3).toList();
                          
                          return Column(
                            children: recentFiles.map((file) {
                              return FileListTile(
                                fileName: file.name,
                                fileSize: file.formattedSize,
                                date: DateFormat.yMMMd().format(file.modifiedAt),
                                onTap: () {
                                  OpenFilex.open(file.path);
                                },
                                onMoreTap: () {
                                  // Show bottom sheet
                                },
                              );
                            }).toList(),
                          );
                        }
                        return _buildEmptyState(context);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Free User Ad Placeholder
                    if (!isPremium)
                      const AdPlaceholder(label: 'Banner Ad Placeholder'),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.description_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('No recent files', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Your created and processed PDFs will appear here.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Create PDF'),
          ),
        ],
      ),
    );
  }
}
