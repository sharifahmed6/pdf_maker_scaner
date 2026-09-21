import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pages/main_scaffold.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/files/presentation/pages/files_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/premium/presentation/pages/premium_paywall_page.dart';
import '../../features/pdf_tools/presentation/pages/scanner_page.dart';
import '../../features/pdf_tools/presentation/pages/signature_page.dart';
import '../../features/pdf_tools/presentation/pages/organize_pdf_page.dart';
import '../../features/pdf_tools/presentation/pages/ai_assistant_page.dart';
import '../../features/pdf_tools/presentation/pages/merge_pdf_page.dart';
import '../../features/pdf_tools/presentation/pages/split_pdf_page.dart';
import '../../features/pdf_tools/presentation/pages/image_to_pdf_page.dart';

// New Features
import '../../features/compress_pdf/presentation/pages/compress_pdf_page.dart';
import '../../features/rotate_pdf/presentation/pages/rotate_pdf_page.dart';
import '../../features/organize_pdf/presentation/pages/reorder_pages_page.dart';
import '../../features/add_text/presentation/pages/add_text_page.dart';
import '../../features/protect_pdf/presentation/pages/protect_pdf_page.dart';
import '../../features/ocr/presentation/pages/ocr_page.dart';
import '../../features/pdf_to_word/presentation/pages/pdf_to_word_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_summary_page.dart';
import '../../features/ai_assistant/presentation/pages/chat_with_pdf_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_ocr_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorFilesKey = GlobalKey<NavigatorState>(debugLabel: 'shellFiles');
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorFilesKey,
          routes: [
            GoRoute(
              path: '/files',
              builder: (context, state) => const FilesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/sign-in', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const SignInPage()),
    GoRoute(path: '/sign-up', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const SignUpPage()),
    GoRoute(path: '/forgot-password', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const ForgotPasswordPage()),
    GoRoute(path: '/premium', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const PremiumPaywallPage()),
    GoRoute(path: '/scanner', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const ScannerPage()),
    GoRoute(path: '/signature', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const SignaturePageWrapper()),
    GoRoute(path: '/organize-pdf', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const OrganizePdfPage()),
    GoRoute(path: '/ai-assistant', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const AiAssistantPage()),
    GoRoute(path: '/merge-pdf', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const MergePdfPage()),
    GoRoute(path: '/split-pdf', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const SplitPdfPage()),
    GoRoute(path: '/img-to-pdf', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const ImageToPdfPage()),
    
    // New Routes
    GoRoute(path: '/compress-pdf', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const CompressPdfPage()),
    GoRoute(path: '/rotate-pdf', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const RotatePdfPage()),
    GoRoute(path: '/reorder-pages', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const ReorderPagesPage()),
    GoRoute(path: '/add-text', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const AddTextPage()),
    GoRoute(path: '/protect-pdf', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const ProtectPdfPage()),
    GoRoute(path: '/ocr', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const OcrPageWrapper()),
    GoRoute(path: '/pdf-to-word', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const PdfToWordPage()),
    GoRoute(path: '/ai-summary', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const AiSummaryPage()),
    GoRoute(path: '/chat-with-pdf', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const ChatWithPdfPage()),
    GoRoute(path: '/ai-ocr', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const AiOcrPage()),
  ],
);
