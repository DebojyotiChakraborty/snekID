import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/snake_identification.dart';
import '../data/repositories/gemini_repository.dart';

/// Provider for the Gemini repository
final geminiRepositoryProvider = Provider<GeminiRepository>((ref) {
  return GeminiRepository();
});

/// Provider for snake identification state
final identificationProvider = StateNotifierProvider<
    IdentificationNotifier, AsyncValue<SnakeIdentification?>>((ref) {
  return IdentificationNotifier(ref);
});

/// Notifier for managing snake identification state
class IdentificationNotifier
    extends StateNotifier<AsyncValue<SnakeIdentification?>> {
  final Ref _ref;

  IdentificationNotifier(this._ref) : super(const AsyncValue.data(null));

  /// Identify a snake from an image file
  Future<void> identifySnake(File imageFile) async {
    state = const AsyncValue.loading();

    try {
      final repository = _ref.read(geminiRepositoryProvider);
      final result = await repository.identifySnake(imageFile);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reset the identification state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider to get the current identification result
final currentIdentificationProvider = Provider<SnakeIdentification?>((ref) {
  return ref.watch(identificationProvider).valueOrNull;
});

/// Provider to check if identification is in progress
final isIdentifyingProvider = Provider<bool>((ref) {
  return ref.watch(identificationProvider).isLoading;
});
