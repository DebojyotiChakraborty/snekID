/// Complete snake identification result from AI
class SnakeIdentification {
  final Species species;
  final BasicInfo basicInfo;
  final PhysicalCharacteristics physicalCharacteristics;
  final SpecialFeatures specialFeatures;
  final HabitatLifestyle habitatLifestyle;
  final DangerSafety dangerSafety;
  final double confidence;

  const SnakeIdentification({
    required this.species,
    required this.basicInfo,
    required this.physicalCharacteristics,
    required this.specialFeatures,
    required this.habitatLifestyle,
    required this.dangerSafety,
    required this.confidence,
  });

  factory SnakeIdentification.fromJson(Map<String, dynamic> json) {
    return SnakeIdentification(
      species: Species.fromJson(json['species'] as Map<String, dynamic>),
      basicInfo: BasicInfo.fromJson(json['basic_info'] as Map<String, dynamic>),
      physicalCharacteristics: PhysicalCharacteristics.fromJson(
        json['physical_characteristics'] as Map<String, dynamic>,
      ),
      specialFeatures: SpecialFeatures.fromJson(
        json['special_features'] as Map<String, dynamic>,
      ),
      habitatLifestyle: HabitatLifestyle.fromJson(
        json['habitat_lifestyle'] as Map<String, dynamic>,
      ),
      dangerSafety: DangerSafety.fromJson(
        json['danger_safety'] as Map<String, dynamic>,
      ),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'species': species.toJson(),
      'basic_info': basicInfo.toJson(),
      'physical_characteristics': physicalCharacteristics.toJson(),
      'special_features': specialFeatures.toJson(),
      'habitat_lifestyle': habitatLifestyle.toJson(),
      'danger_safety': dangerSafety.toJson(),
      'confidence': confidence,
    };
  }

  /// Check if this is a high confidence identification
  bool get isHighConfidence => confidence >= 0.85;

  /// Get a human-readable confidence percentage
  String get confidencePercentage => '${(confidence * 100).round()}%';

  /// Create a copy with modified fields
  SnakeIdentification copyWith({
    Species? species,
    BasicInfo? basicInfo,
    PhysicalCharacteristics? physicalCharacteristics,
    SpecialFeatures? specialFeatures,
    HabitatLifestyle? habitatLifestyle,
    DangerSafety? dangerSafety,
    double? confidence,
  }) {
    return SnakeIdentification(
      species: species ?? this.species,
      basicInfo: basicInfo ?? this.basicInfo,
      physicalCharacteristics: physicalCharacteristics ?? this.physicalCharacteristics,
      specialFeatures: specialFeatures ?? this.specialFeatures,
      habitatLifestyle: habitatLifestyle ?? this.habitatLifestyle,
      dangerSafety: dangerSafety ?? this.dangerSafety,
      confidence: confidence ?? this.confidence,
    );
  }
}

/// Species identification details
class Species {
  final String commonName;
  final String scientificName;
  final String snakeType;

  const Species({
    required this.commonName,
    required this.scientificName,
    required this.snakeType,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      commonName: json['common_name'] as String? ?? 'Unknown',
      scientificName: json['scientific_name'] as String? ?? 'Unknown',
      snakeType: json['snake_type'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'common_name': commonName,
      'scientific_name': scientificName,
      'snake_type': snakeType,
    };
  }

  /// Check if this is a venomous snake
  bool get isVenomous =>
      snakeType.toLowerCase().contains('venomous') &&
      !snakeType.toLowerCase().contains('non-venomous');
}

/// Basic information about the snake
class BasicInfo {
  final String venomLevel;
  final String behavior;
  final List<String> nativeRegions;
  final String activePeriods;

  const BasicInfo({
    required this.venomLevel,
    required this.behavior,
    required this.nativeRegions,
    required this.activePeriods,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      venomLevel: json['venom_level'] as String? ?? 'Unknown',
      behavior: json['behavior'] as String? ?? 'Unknown',
      nativeRegions: (json['native_regions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      activePeriods: json['active_periods'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'venom_level': venomLevel,
      'behavior': behavior,
      'native_regions': nativeRegions,
      'active_periods': activePeriods,
    };
  }
}

/// Physical characteristics of the snake
class PhysicalCharacteristics {
  final String colorDescription;
  final String lengthRangeCm;
  final String bodyPattern;
  final String scaleTexture;
  final String headShape;
  final String pupilShape;
  final String tailType;

  const PhysicalCharacteristics({
    required this.colorDescription,
    required this.lengthRangeCm,
    required this.bodyPattern,
    required this.scaleTexture,
    required this.headShape,
    required this.pupilShape,
    required this.tailType,
  });

  factory PhysicalCharacteristics.fromJson(Map<String, dynamic> json) {
    return PhysicalCharacteristics(
      colorDescription: json['color_description'] as String? ?? 'Unknown',
      lengthRangeCm: json['length_range_cm'] as String? ?? 'Unknown',
      bodyPattern: json['body_pattern'] as String? ?? 'Unknown',
      scaleTexture: json['scale_texture'] as String? ?? 'Unknown',
      headShape: json['head_shape'] as String? ?? 'Unknown',
      pupilShape: json['pupil_shape'] as String? ?? 'Unknown',
      tailType: json['tail_type'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color_description': colorDescription,
      'length_range_cm': lengthRangeCm,
      'body_pattern': bodyPattern,
      'scale_texture': scaleTexture,
      'head_shape': headShape,
      'pupil_shape': pupilShape,
      'tail_type': tailType,
    };
  }

  /// Get formatted length range
  String get formattedLengthRange => '$lengthRangeCm cm';
}

/// Special features of the snake
class SpecialFeatures {
  final bool isMimicSpecies;
  final bool usesCamouflage;
  final bool hasRattle;
  final bool hissingSound;
  final List<String> defensiveBehaviors;

  const SpecialFeatures({
    required this.isMimicSpecies,
    required this.usesCamouflage,
    required this.hasRattle,
    required this.hissingSound,
    required this.defensiveBehaviors,
  });

  factory SpecialFeatures.fromJson(Map<String, dynamic> json) {
    return SpecialFeatures(
      isMimicSpecies: json['is_mimic_species'] as bool? ?? false,
      usesCamouflage: json['uses_camouflage'] as bool? ?? false,
      hasRattle: json['has_rattle'] as bool? ?? false,
      hissingSound: json['hissing_sound'] as bool? ?? false,
      defensiveBehaviors: (json['defensive_behaviors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_mimic_species': isMimicSpecies,
      'uses_camouflage': usesCamouflage,
      'has_rattle': hasRattle,
      'hissing_sound': hissingSound,
      'defensive_behaviors': defensiveBehaviors,
    };
  }
}

/// Habitat and lifestyle information
class HabitatLifestyle {
  final String habitat;
  final String diet;
  final String reproduction;
  final String breedingSeason;

  const HabitatLifestyle({
    required this.habitat,
    required this.diet,
    required this.reproduction,
    required this.breedingSeason,
  });

  factory HabitatLifestyle.fromJson(Map<String, dynamic> json) {
    return HabitatLifestyle(
      habitat: json['habitat'] as String? ?? 'Unknown',
      diet: json['diet'] as String? ?? 'Unknown',
      reproduction: json['reproduction'] as String? ?? 'Unknown',
      breedingSeason: json['breeding_season'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habitat': habitat,
      'diet': diet,
      'reproduction': reproduction,
      'breeding_season': breedingSeason,
    };
  }
}

/// Danger and safety information
class DangerSafety {
  final String dangerLevel;
  final List<String> biteSymptoms;
  final List<String> safetyTips;

  const DangerSafety({
    required this.dangerLevel,
    required this.biteSymptoms,
    required this.safetyTips,
  });

  factory DangerSafety.fromJson(Map<String, dynamic> json) {
    return DangerSafety(
      dangerLevel: json['danger_level'] as String? ?? 'Unknown',
      biteSymptoms: (json['bite_symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      safetyTips: (json['safety_tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'danger_level': dangerLevel,
      'bite_symptoms': biteSymptoms,
      'safety_tips': safetyTips,
    };
  }

  /// Check if this is a high danger snake
  bool get isHighDanger => dangerLevel.toLowerCase().contains('high');

  /// Check if this is a medium danger snake
  bool get isMediumDanger => dangerLevel.toLowerCase().contains('medium');

  /// Check if this is a low danger snake
  bool get isLowDanger => dangerLevel.toLowerCase().contains('low');
}
