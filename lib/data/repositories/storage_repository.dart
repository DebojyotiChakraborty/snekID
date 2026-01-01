import 'package:hive/hive.dart';

import '../models/analysis_history.dart';

/// Repository for local storage operations
class StorageRepository {
  static const String _historyBoxName = 'analysis_history';
  static const String _favoritesBoxName = 'favorite_snakes';

  Box<AnalysisHistory>? _historyBox;
  Box<FavoriteSnake>? _favoritesBox;

  /// Initialize storage (call once at app start)
  Future<void> initialize() async {
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AnalysisHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FavoriteSnakeAdapter());
    }

    // Open boxes
    _historyBox = await Hive.openBox<AnalysisHistory>(_historyBoxName);
    _favoritesBox = await Hive.openBox<FavoriteSnake>(_favoritesBoxName);
  }

  // ============== History Operations ==============

  /// Get all analysis history entries (sorted by date, newest first)
  List<AnalysisHistory> getHistory() {
    final entries = _historyBox?.values.toList() ?? [];
    entries.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
    return entries;
  }

  /// Add a new history entry
  Future<void> addToHistory(AnalysisHistory entry) async {
    await _historyBox?.put(entry.id, entry);
  }

  /// Delete a history entry
  Future<void> deleteFromHistory(String id) async {
    await _historyBox?.delete(id);
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await _historyBox?.clear();
  }

  /// Get history entry by ID
  AnalysisHistory? getHistoryById(String id) {
    return _historyBox?.get(id);
  }

  // ============== Favorites Operations ==============

  /// Get all favorite snakes (sorted by date, newest first)
  List<FavoriteSnake> getFavorites() {
    final favorites = _favoritesBox?.values.toList() ?? [];
    favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return favorites;
  }

  /// Add a snake to favorites
  Future<void> addToFavorites(FavoriteSnake snake) async {
    await _favoritesBox?.put(snake.id, snake);
  }

  /// Remove a snake from favorites
  Future<void> removeFromFavorites(String id) async {
    await _favoritesBox?.delete(id);
  }

  /// Check if a snake is in favorites (by common name)
  bool isFavorite(String commonName) {
    return _favoritesBox?.values
            .any((f) => f.commonName == commonName) ??
        false;
  }

  /// Get favorite by common name
  FavoriteSnake? getFavoriteByName(String commonName) {
    try {
      return _favoritesBox?.values
          .firstWhere((f) => f.commonName == commonName);
    } catch (_) {
      return null;
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    await _favoritesBox?.clear();
  }

  // ============== Utility ==============

  /// Close all boxes
  Future<void> close() async {
    await _historyBox?.close();
    await _favoritesBox?.close();
  }
}
