import 'package:flutter/material.dart';
import 'package:device_responsive/device_responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/subscription/presentation/bloc/subscription_bloc.dart';
import 'features/subscription/presentation/bloc/subscription_event.dart';
import 'features/files/presentation/bloc/files_bloc.dart';
import 'features/files/presentation/bloc/files_event.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<SubscriptionBloc>(
          create: (_) => di.sl<SubscriptionBloc>()..add(SubscriptionCheckRequested()),
        ),
        BlocProvider<FilesBloc>(
          create: (_) => di.sl<FilesBloc>()..add(LoadFilesEvent()),
        ),
      ],
      child: AutoResponsiveInit(
        designSize: const Size(375, 812),
        builder: (context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'PDF Tools',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
      ),
    );
  }
}
