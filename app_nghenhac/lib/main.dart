import 'package:app_nghenhac/core/configs/theme/app_theme.dart';
import 'package:app_nghenhac/firebase_options.dart';
import 'package:app_nghenhac/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:app_nghenhac/presentation/splash/pages/splash.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize storage with error handling
    try {
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getApplicationDocumentsDirectory(),
      );
    } catch (e) {
      print('HydratedBloc storage initialization failed: $e');
      // Continue without hydrated storage if it fails
    }
    
    // Initialize Firebase with error handling
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization failed: $e');
      // Continue without Firebase if it fails
    }

    // Initialize dependencies
    try {
      // Clear existing dependencies to ensure fresh start
      await sl.reset();
      
      await initializeDependencies();
      print('Dependencies initialized successfully');
    } catch (e) {
      print('Dependencies initialization failed: $e');
    }

    runApp(MyApp());
  } catch (e) {
    print('App initialization failed: $e');
    // Still try to run the app with minimal setup
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('App initialization error: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit())
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const SplashPage(),
        ),
      ),
    );
  }
}