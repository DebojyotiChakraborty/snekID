import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/api_constants.dart';

/// Service for image processing and compression
class ImageService {
  /// Compress and resize an image for API submission
  Future<File> processImageForUpload(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw ImageProcessingException('Failed to decode image');
    }

    // Resize if larger than max dimensions
    img.Image processedImage = image;
    if (image.width > ApiConstants.maxImageWidth ||
        image.height > ApiConstants.maxImageHeight) {
      processedImage = img.copyResize(
        image,
        width: image.width > image.height ? ApiConstants.maxImageWidth : null,
        height: image.height >= image.width ? ApiConstants.maxImageHeight : null,
        maintainAspect: true,
      );
    }

    // Encode to JPEG with quality setting
    final compressedBytes = img.encodeJpg(
      processedImage,
      quality: ApiConstants.imageQuality,
    );

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(compressedBytes);

    return tempFile;
  }

  /// Save image to app's documents directory for history
  Future<String> saveImageForHistory(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final historyDir = Directory('${appDir.path}/history');
    
    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }

    final fileName = 'snake_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await imageFile.copy('${historyDir.path}/$fileName');
    
    return savedFile.path;
  }

  /// Delete an image from history
  Future<void> deleteHistoryImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Clear all temporary processed images
  Future<void> clearTempImages() async {
    final tempDir = await getTemporaryDirectory();
    final files = tempDir.listSync();
    
    for (final file in files) {
      if (file is File && file.path.contains('processed_')) {
        await file.delete();
      }
    }
  }
}

/// Exception for image processing errors
class ImageProcessingException implements Exception {
  final String message;
  
  ImageProcessingException(this.message);
  
  @override
  String toString() => 'ImageProcessingException: $message';
}
