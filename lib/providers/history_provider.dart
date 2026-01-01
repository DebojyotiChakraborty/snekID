import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/analysis_history.dart';
import '../data/models/snake_identification.dart';
import '../data/repositories/storage_repository.dart';

/// Provider for the storage repository
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

/// Provider for analysis history
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<AnalysisHistory>>((ref) {
  final storage = ref.watch(storageRepositoryProvider);
  return HistoryNotifier(storage);
});

/// Notifier for managing analysis history
class HistoryNotifier extends StateNotifier<List<AnalysisHistory>> {
  final StorageRepository _storage;

  HistoryNotifier(this._storage) : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    state = _storage.getHistory();
  }

  /// Add a new analysis to history
  Future<void> addAnalysis({
    required String imagePath,
    required SnakeIdentification identification,
  }) async {
    final entry = AnalysisHistory.fromIdentification(
      imagePath: imagePath,
      identification: identification,
    );
    await _storage.addToHistory(entry);
    _loadHistory();
  }

  /// Delete an analysis from history
  Future<void> deleteAnalysis(String id) async {
    await _storage.deleteFromHistory(id);
    _loadHistory();
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await _storage.clearHistory();
    _loadHistory();
  }
}

/// Provider for favorite snakes
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<FavoriteSnake>>((ref) {
  final storage = ref.watch(storageRepositoryProvider);
  return FavoritesNotifier(storage);
});

/// Notifier for managing favorite snakes
class FavoritesNotifier extends StateNotifier<List<FavoriteSnake>> {
  final StorageRepository _storage;

  FavoritesNotifier(this._storage) : super([]) {
    _loadFavorites();
  }

  void _loadFavorites() {
    state = _storage.getFavorites();
  }

  /// Add a snake to favorites
  Future<void> addFavorite({
    required SnakeIdentification identification,
    String? imagePath,
  }) async {
    final favorite = FavoriteSnake.fromIdentification(
      identification: identification,
      imagePath: imagePath,
    );
    await _storage.addToFavorites(favorite);
    _loadFavorites();
  }

  /// Remove a snake from favorites by ID
  Future<void> removeFavorite(String id) async {
    await _storage.removeFromFavorites(id);
    _loadFavorites();
  }

  /// Check if a snake is in favorites
  bool isFavorite(String commonName) {
    return _storage.isFavorite(commonName);
  }

  /// Toggle favorite status for a snake
  Future<void> toggleFavorite({
    required SnakeIdentification identification,
    String? imagePath,
  }) async {
    final existing = _storage.getFavoriteByName(identification.species.commonName);
    if (existing != null) {
      await removeFavorite(existing.id);
    } else {
      await addFavorite(identification: identification, imagePath: imagePath);
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    await _storage.clearFavorites();
    _loadFavorites();
  }
}

/// Provider to check if a specific snake is favorited
final isFavoriteProvider = Provider.family<bool, String>((ref, commonName) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.any((f) => f.commonName == commonName);
});
