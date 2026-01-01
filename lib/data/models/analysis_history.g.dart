// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalysisHistoryAdapter extends TypeAdapter<AnalysisHistory> {
  @override
  final int typeId = 0;

  @override
  AnalysisHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisHistory(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      commonName: fields[2] as String,
      scientificName: fields[3] as String,
      snakeType: fields[4] as String,
      venomLevel: fields[5] as String,
      dangerLevel: fields[6] as String,
      confidence: fields[7] as double,
      analyzedAt: fields[8] as DateTime,
      fullResultJson: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisHistory obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.commonName)
      ..writeByte(3)
      ..write(obj.scientificName)
      ..writeByte(4)
      ..write(obj.snakeType)
      ..writeByte(5)
      ..write(obj.venomLevel)
      ..writeByte(6)
      ..write(obj.dangerLevel)
      ..writeByte(7)
      ..write(obj.confidence)
      ..writeByte(8)
      ..write(obj.analyzedAt)
      ..writeByte(9)
      ..write(obj.fullResultJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavoriteSnakeAdapter extends TypeAdapter<FavoriteSnake> {
  @override
  final int typeId = 1;

  @override
  FavoriteSnake read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteSnake(
      id: fields[0] as String,
      commonName: fields[1] as String,
      scientificName: fields[2] as String,
      snakeType: fields[3] as String,
      venomLevel: fields[4] as String,
      dangerLevel: fields[5] as String,
      imagePath: fields[6] as String?,
      addedAt: fields[7] as DateTime,
      fullResultJson: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteSnake obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.commonName)
      ..writeByte(2)
      ..write(obj.scientificName)
      ..writeByte(3)
      ..write(obj.snakeType)
      ..writeByte(4)
      ..write(obj.venomLevel)
      ..writeByte(5)
      ..write(obj.dangerLevel)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.addedAt)
      ..writeByte(8)
      ..write(obj.fullResultJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteSnakeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
