import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/logger_service.dart';
import 'data/models/analysis_history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggerService.e('Flutter error', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    LoggerService.e('Platform error', error, stack);
    return true;
  };

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    LoggerService.w('Failed to load .env file. Using defaults or crashing if required keys missing.');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AnalysisHistoryAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(FavoriteSnakeAdapter());
  }

  // Open Hive boxes
  await Hive.openBox<AnalysisHistory>('analysis_history');
  await Hive.openBox<FavoriteSnake>('favorite_snakes');

  runApp(
    const ProviderScope(
      child: SnekIDApp(),
    ),
  );
}
