import 'dart:convert';

import 'package:hive/hive.dart';

import 'snake_identification.dart';

part 'analysis_history.g.dart';

/// History entry for a snake analysis
@HiveType(typeId: 0)
class AnalysisHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String commonName;

  @HiveField(3)
  final String scientificName;

  @HiveField(4)
  final String snakeType;

  @HiveField(5)
  final String venomLevel;

  @HiveField(6)
  final String dangerLevel;

  @HiveField(7)
  final double confidence;

  @HiveField(8)
  final DateTime analyzedAt;

  @HiveField(9)
  final String? fullResultJson;

  AnalysisHistory({
    required this.id,
    required this.imagePath,
    required this.commonName,
    required this.scientificName,
    required this.snakeType,
    required this.venomLevel,
    required this.dangerLevel,
    required this.confidence,
    required this.analyzedAt,
    this.fullResultJson,
  });

  /// Create from a SnakeIdentification result
  factory AnalysisHistory.fromIdentification({
    required String imagePath,
    required SnakeIdentification identification,
  }) {
    return AnalysisHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      commonName: identification.species.commonName,
      scientificName: identification.species.scientificName,
      snakeType: identification.species.snakeType,
      venomLevel: identification.basicInfo.venomLevel,
      dangerLevel: identification.dangerSafety.dangerLevel,
      confidence: identification.confidence,
      analyzedAt: DateTime.now(),
      fullResultJson: jsonEncode(identification.toJson()),
    );
  }

  /// Get formatted date string
  String get formattedDate {
    return '${analyzedAt.day}/${analyzedAt.month}/${analyzedAt.year} '
        '${analyzedAt.hour.toString().padLeft(2, '0')}:'
        '${analyzedAt.minute.toString().padLeft(2, '0')}';
  }

  /// Get confidence as percentage string
  String get confidencePercentage => '${(confidence * 100).round()}%';
}

/// Favorite snake entry
@HiveType(typeId: 1)
class FavoriteSnake extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String commonName;

  @HiveField(2)
  final String scientificName;

  @HiveField(3)
  final String snakeType;

  @HiveField(4)
  final String venomLevel;

  @HiveField(5)
  final String dangerLevel;

  @HiveField(6)
  final String? imagePath;

  @HiveField(7)
  final DateTime addedAt;

  @HiveField(8)
  final String? fullResultJson;

  FavoriteSnake({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.snakeType,
    required this.venomLevel,
    required this.dangerLevel,
    this.imagePath,
    required this.addedAt,
    this.fullResultJson,
  });

  /// Create from a SnakeIdentification result
  factory FavoriteSnake.fromIdentification({
    required SnakeIdentification identification,
    String? imagePath,
  }) {
    return FavoriteSnake(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      commonName: identification.species.commonName,
      scientificName: identification.species.scientificName,
      snakeType: identification.species.snakeType,
      venomLevel: identification.basicInfo.venomLevel,
      dangerLevel: identification.dangerSafety.dangerLevel,
      imagePath: imagePath,
      addedAt: DateTime.now(),
      fullResultJson: jsonEncode(identification.toJson()),
    );
  }

  /// Get formatted date string
  String get formattedDate {
    return '${addedAt.day}/${addedAt.month}/${addedAt.year}';
  }
}
