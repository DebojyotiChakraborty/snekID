import 'package:hive/hive.dart';

import '../models/analysis_history.dart';

/// Repository for local storage operations
class StorageRepository {
  static const String _historyBoxName = 'analysis_history';
  static const String _favoritesBoxName = 'favorite_snakes';

  /// Get history box (already opened in main.dart)
  Box<AnalysisHistory> get _historyBox =>
      Hive.box<AnalysisHistory>(_historyBoxName);

  /// Get favorites box (already opened in main.dart)
  Box<FavoriteSnake> get _favoritesBox =>
      Hive.box<FavoriteSnake>(_favoritesBoxName);

  // ============== History Operations ==============

  /// Get all analysis history entries (sorted by date, newest first)
  List<AnalysisHistory> getHistory() {
    final entries = _historyBox.values.toList();
    entries.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
    return entries;
  }

  /// Add a new history entry (checks for duplicates by common name and recent timestamp)
  Future<void> addToHistory(AnalysisHistory entry) async {
    // Check if the same snake was analyzed very recently (within 10 seconds)
    // This prevents duplicates from widget rebuilds or multiple save attempts
    final now = DateTime.now();
    final recentDuplicate = _historyBox.values.any((e) {
      final timeDiff = now.difference(e.analyzedAt).inSeconds.abs();
      return e.commonName == entry.commonName && timeDiff < 10;
    });

    // Only add if no recent duplicate found
    if (!recentDuplicate) {
      await _historyBox.put(entry.id, entry);
    }
  }

  /// Delete a history entry
  Future<void> deleteFromHistory(String id) async {
    await _historyBox.delete(id);
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  /// Get history entry by ID
  AnalysisHistory? getHistoryById(String id) {
    return _historyBox.get(id);
  }

  // ============== Favorites Operations ==============

  /// Get all favorite snakes (sorted by date, newest first)
  List<FavoriteSnake> getFavorites() {
    final favorites = _favoritesBox.values.toList();
    favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return favorites;
  }

  /// Add a snake to favorites
  Future<void> addToFavorites(FavoriteSnake snake) async {
    await _favoritesBox.put(snake.id, snake);
  }

  /// Remove a snake from favorites
  Future<void> removeFromFavorites(String id) async {
    await _favoritesBox.delete(id);
  }

  /// Check if a snake is in favorites (by common name)
  bool isFavorite(String commonName) {
    return _favoritesBox.values.any((f) => f.commonName == commonName);
  }

  /// Get favorite by common name
  FavoriteSnake? getFavoriteByName(String commonName) {
    try {
      return _favoritesBox.values.firstWhere((f) => f.commonName == commonName);
    } catch (_) {
      return null;
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    await _favoritesBox.clear();
  }

  // ============== Utility ==============

  /// Close all boxes
  Future<void> close() async {
    await _historyBox.close();
    await _favoritesBox.close();
  }
}
