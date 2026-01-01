import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/services/logger_service.dart';
import '../models/snake_identification.dart';
import '../prompts/gemini_prompt.dart';

/// Service for interacting with Google Gemini API
class GeminiService {
  /// Identify a snake from an image file
  Future<SnakeIdentification> identifySnake(File imageFile) async {
    try {
      // Read and encode image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Determine MIME type
      final extension = imageFile.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(extension);

      // Build the request
      final requestBody = _buildRequestBody(base64Image, mimeType);
      
      LoggerService.i('Sending image to Gemini API: ${imageFile.path}');
      LoggerService.d('Model: ${ApiConstants.geminiModel}, Endpoint: ${ApiConstants.geminiEndpoint}');

      // Make API call with API key in header (per official Gemini API docs)
      final response = await http
          .post(
            Uri.parse(ApiConstants.geminiEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': ApiConstants.geminiApiKey,
            },
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConstants.receiveTimeout);

      if (response.statusCode != 200) {
        LoggerService.e(
          'Gemini API request failed',
          'Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw GeminiApiException(
          'API request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
      
      LoggerService.i('Gemini API success. Parsing response...');

      // Parse the response
      return _parseResponse(response.body);
    } catch (e, stackTrace) {
      if (e is! GeminiApiException) {
        LoggerService.e('Unexpected error in identifySnake', e, stackTrace);
      }
      rethrow;
    }
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Map<String, dynamic> _buildRequestBody(String base64Image, String mimeType) {
    return {
      'contents': [
        {
          'parts': [
            {
              'text': GeminiPrompt.snakeIdentification,
            },
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.4,
        'topK': 32,
        'topP': 1,
        'maxOutputTokens': 4096,
        'responseMimeType': 'application/json',
      },
    };
  }

  SnakeIdentification _parseResponse(String responseBody) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;

      // Extract the text content from Gemini response
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw GeminiApiException('No candidates in response');
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      if (content == null) {
        throw GeminiApiException('No content in response');
      }

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw GeminiApiException('No parts in response');
      }

      final text = parts[0]['text'] as String?;
      if (text == null || text.isEmpty) {
        throw GeminiApiException('No text in response');
      }

      // Parse the JSON from the text
      final snakeJson = jsonDecode(text) as Map<String, dynamic>;
      return SnakeIdentification.fromJson(snakeJson);
    } catch (e) {
      if (e is GeminiApiException) rethrow;
      LoggerService.e('Failed to parse Gemini response', e);
      LoggerService.d('Response body was: $responseBody');
      throw GeminiApiException('Failed to parse response: $e');
    }
  }
}

/// Exception for Gemini API errors
class GeminiApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  GeminiApiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() => 'GeminiApiException: $message';
}
