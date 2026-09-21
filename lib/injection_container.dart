import 'package:get_it/get_it.dart';

// Core
import 'core/services/ad_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/pdf_processor.dart';
import 'core/services/pdf_processor_impl.dart';

// Auth
import 'features/auth/data/datasources/supabase_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Subscription
import 'features/subscription/data/datasources/revenue_cat_datasource.dart';
import 'features/subscription/data/repositories/subscription_repository_impl.dart';
import 'features/subscription/domain/repositories/subscription_repository.dart';
import 'features/subscription/domain/usecases/check_premium_access_usecase.dart';
import 'features/subscription/presentation/bloc/subscription_bloc.dart';

// Files
import 'features/files/data/datasources/file_datasource.dart';
import 'features/files/data/datasources/local_file_datasource.dart';
import 'features/files/data/repositories/file_repository_impl.dart';
import 'features/files/domain/repositories/file_repository.dart';
import 'features/files/presentation/bloc/files_bloc.dart';
import 'features/pdf_tools/presentation/bloc/merge_pdf_bloc.dart';
import 'features/pdf_tools/presentation/bloc/split_pdf_bloc.dart';
import 'features/pdf_tools/presentation/bloc/image_to_pdf_bloc.dart';
import 'features/compress_pdf/presentation/bloc/compress_pdf_bloc.dart';
import 'features/protect_pdf/presentation/bloc/protect_pdf_bloc.dart';
import 'features/rotate_pdf/presentation/bloc/rotate_pdf_bloc.dart';
import 'features/organize_pdf/presentation/bloc/organize_pdf_bloc.dart';
import 'features/add_text/presentation/bloc/addtext_bloc.dart';
import 'features/pdf_tools/presentation/bloc/signature/signature_bloc.dart';
import 'features/pdf_tools/presentation/bloc/scanner/scanner_bloc.dart';
import 'features/ocr/presentation/bloc/ocr_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ---------------------------------------------------------------------------
  // CORE SERVICES
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AdService>(() => AdServiceImpl());
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsServiceImpl());
  sl.registerLazySingleton<PdfProcessor>(() => PdfProcessorImpl());

  // ---------------------------------------------------------------------------
  // DATA SOURCES
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<SupabaseAuthDataSource>(() => SupabaseAuthDataSourceImpl());
  sl.registerLazySingleton<RevenueCatDataSource>(() => RevenueCatDataSourceImpl());
  sl.registerLazySingleton<FileDataSource>(() => LocalFileDataSourceImpl());


  // ---------------------------------------------------------------------------
  // REPOSITORIES
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(dataSource: sl()));
  sl.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepositoryImpl(dataSource: sl()));
  sl.registerLazySingleton<FileRepository>(() => FileRepositoryImpl(sl()));


  // ---------------------------------------------------------------------------
  // USE CASES
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(() => CheckPremiumAccessUseCase(sl()));


  // ---------------------------------------------------------------------------
  // BLOCS
  // ---------------------------------------------------------------------------
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => SubscriptionBloc(subscriptionRepository: sl()));
  sl.registerFactory(() => FilesBloc(repository: sl()));
  sl.registerFactory(() => MergePdfBloc(pdfProcessor: sl()));
  sl.registerFactory(() => SplitPdfBloc(pdfProcessor: sl()));
  sl.registerFactory(() => ImageToPdfBloc(pdfProcessor: sl()));
  sl.registerFactory(() => CompressPdfBloc(pdfProcessor: sl()));
  sl.registerFactory(() => ProtectPdfBloc(pdfProcessor: sl()));
  sl.registerFactory(() => RotatePdfBloc(pdfProcessor: sl()));
  sl.registerFactory(() => ReorderPdfBloc(pdfProcessor: sl()));
  sl.registerFactory(() => AddTextBloc(pdfProcessor: sl()));
  sl.registerFactory(() => SignatureBloc(pdfProcessor: sl()));
  sl.registerFactory(() => ScannerBloc(pdfProcessor: sl()));
  sl.registerFactory(() => OcrBloc(pdfProcessor: sl()));
}
