import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:durgapuja_manager/core/config/app_environment.dart';
import 'package:durgapuja_manager/core/constants/app_constants.dart';
import 'package:durgapuja_manager/core/router/app_router.dart';
import 'package:durgapuja_manager/core/theme/app_theme.dart';
import 'package:durgapuja_manager/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final options = DefaultFirebaseOptions.currentPlatform;
  developer.log(
    'Initializing Firebase in ${AppEnvironment.name} environment with Project ID: ${options.projectId}',
    name: 'AppEnvironment',
  );

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: options);
  }
  
  runApp(const ProviderScope(child: DurgaPujaManagerApp()));
}

class DurgaPujaManagerApp extends ConsumerWidget {
  const DurgaPujaManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        if (AppEnvironment.isDev && child != null) {
          return Banner(
            message: 'DEV',
            location: BannerLocation.topStart,
            color: Colors.deepOrange,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.0,
              color: Colors.white,
            ),
            child: child,
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
