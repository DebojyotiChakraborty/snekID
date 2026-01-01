import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API configuration constants
class ApiConstants {
  ApiConstants._();

  // Gemini API Configuration (loaded from .env file)
  static String get geminiApiKey => 
      dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY_HERE';
  
  // Gemini API Base URL
  static String get geminiBaseUrl => 
      dotenv.env['GEMINI_BASE_URL'] ?? 'https://generativelanguage.googleapis.com/v1beta';
  
  // Model: gemini-2.5-flash is stable, gemini-3-flash-preview for latest
  static String get geminiModel => 
      dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.5-flash';
  
  // Endpoint URL (API key is passed via header, not query param)
  static String get geminiEndpoint => 
      '$geminiBaseUrl/models/$geminiModel:generateContent';

  // API timeouts (loaded from .env with defaults)
  static Duration get connectionTimeout => Duration(
    seconds: int.tryParse(dotenv.env['CONNECTION_TIMEOUT'] ?? '30') ?? 30,
  );
  
  static Duration get receiveTimeout => Duration(
    seconds: int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '60') ?? 60,
  );

  // Confidence threshold
  static const double lowConfidenceThreshold = 0.85;

  // Image settings
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;
}
