import 'dart:io';

import '../models/snake_identification.dart';
import '../services/gemini_service.dart';
import '../services/image_service.dart';

/// Repository for snake identification operations
class GeminiRepository {
  final GeminiService _geminiService;
  final ImageService _imageService;

  GeminiRepository({
    GeminiService? geminiService,
    ImageService? imageService,
  })  : _geminiService = geminiService ?? GeminiService(),
        _imageService = imageService ?? ImageService();

  /// Identify a snake from an image
  Future<SnakeIdentification> identifySnake(File imageFile) async {
    // Process image for optimal API submission
    final processedImage = await _imageService.processImageForUpload(imageFile);

    try {
      // Send to Gemini for identification
      final result = await _geminiService.identifySnake(processedImage);
      return result;
    } finally {
      // Clean up processed image
      try {
        await processedImage.delete();
      } catch (_) {
        // Ignore cleanup errors
      }
    }
  }

  /// Save analysis image for history
  Future<String> saveImageForHistory(File imageFile) {
    return _imageService.saveImageForHistory(imageFile);
  }
}
