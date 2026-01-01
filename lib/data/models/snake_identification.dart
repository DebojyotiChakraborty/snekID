/// Complete snake identification result from AI
class SnakeIdentification {
  final Species species;
  final BasicInfo basicInfo;
  final PhysicalCharacteristics physicalCharacteristics;
  final SpecialFeatures specialFeatures;
  final AdditionalInfo additionalInfo;
  final HabitatLifestyle habitatLifestyle;
  final DietInfo dietInfo;
  final ReproductionInfo reproductionInfo;
  final DangerSafety dangerSafety;
  final List<CommonQuestion> commonQuestions;
  final List<AlternativeSpecies> possibleAlternatives;
  final double confidence;

  const SnakeIdentification({
    required this.species,
    required this.basicInfo,
    required this.physicalCharacteristics,
    required this.specialFeatures,
    required this.additionalInfo,
    required this.habitatLifestyle,
    required this.dietInfo,
    required this.reproductionInfo,
    required this.dangerSafety,
    required this.commonQuestions,
    required this.possibleAlternatives,
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
      additionalInfo: AdditionalInfo.fromJson(
        json['additional_info'] as Map<String, dynamic>? ?? {},
      ),
      habitatLifestyle: HabitatLifestyle.fromJson(
        json['habitat_lifestyle'] as Map<String, dynamic>,
      ),
      dietInfo: DietInfo.fromJson(
        json['diet_info'] as Map<String, dynamic>? ?? {},
      ),
      reproductionInfo: ReproductionInfo.fromJson(
        json['reproduction_info'] as Map<String, dynamic>? ?? {},
      ),
      dangerSafety: DangerSafety.fromJson(
        json['danger_safety'] as Map<String, dynamic>,
      ),
      commonQuestions: (json['common_questions'] as List<dynamic>?)
              ?.map((e) => CommonQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      possibleAlternatives: (json['possible_alternatives'] as List<dynamic>?)
              ?.map((e) => AlternativeSpecies.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'species': species.toJson(),
      'basic_info': basicInfo.toJson(),
      'physical_characteristics': physicalCharacteristics.toJson(),
      'special_features': specialFeatures.toJson(),
      'additional_info': additionalInfo.toJson(),
      'habitat_lifestyle': habitatLifestyle.toJson(),
      'diet_info': dietInfo.toJson(),
      'reproduction_info': reproductionInfo.toJson(),
      'danger_safety': dangerSafety.toJson(),
      'common_questions': commonQuestions.map((e) => e.toJson()).toList(),
      'possible_alternatives': possibleAlternatives.map((e) => e.toJson()).toList(),
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
    AdditionalInfo? additionalInfo,
    HabitatLifestyle? habitatLifestyle,
    DietInfo? dietInfo,
    ReproductionInfo? reproductionInfo,
    DangerSafety? dangerSafety,
    List<CommonQuestion>? commonQuestions,
    List<AlternativeSpecies>? possibleAlternatives,
    double? confidence,
  }) {
    return SnakeIdentification(
      species: species ?? this.species,
      basicInfo: basicInfo ?? this.basicInfo,
      physicalCharacteristics: physicalCharacteristics ?? this.physicalCharacteristics,
      specialFeatures: specialFeatures ?? this.specialFeatures,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      habitatLifestyle: habitatLifestyle ?? this.habitatLifestyle,
      dietInfo: dietInfo ?? this.dietInfo,
      reproductionInfo: reproductionInfo ?? this.reproductionInfo,
      dangerSafety: dangerSafety ?? this.dangerSafety,
      commonQuestions: commonQuestions ?? this.commonQuestions,
      possibleAlternatives: possibleAlternatives ?? this.possibleAlternatives,
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

/// Additional information about the snake
class AdditionalInfo {
  final String mythAndFolklore;
  final String nameOrigin;
  final String adaptationStrategies;
  final String ecologicalImportance;
  final String humanInteractions;
  final List<String> identifyingTips;

  const AdditionalInfo({
    required this.mythAndFolklore,
    required this.nameOrigin,
    required this.adaptationStrategies,
    required this.ecologicalImportance,
    required this.humanInteractions,
    required this.identifyingTips,
  });

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    return AdditionalInfo(
      mythAndFolklore: json['myth_and_folklore'] as String? ?? 'No information available',
      nameOrigin: json['name_origin'] as String? ?? 'No information available',
      adaptationStrategies: json['adaptation_strategies'] as String? ?? 'No information available',
      ecologicalImportance: json['ecological_importance'] as String? ?? 'No information available',
      humanInteractions: json['human_interactions'] as String? ?? 'No information available',
      identifyingTips: (json['identifying_tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'myth_and_folklore': mythAndFolklore,
      'name_origin': nameOrigin,
      'adaptation_strategies': adaptationStrategies,
      'ecological_importance': ecologicalImportance,
      'human_interactions': humanInteractions,
      'identifying_tips': identifyingTips,
    };
  }
}

/// Habitat and lifestyle information
class HabitatLifestyle {
  final String habitat;
  final String lifestyle;
  final String geographicRange;
  final String preferredEnvironment;

  const HabitatLifestyle({
    required this.habitat,
    required this.lifestyle,
    required this.geographicRange,
    required this.preferredEnvironment,
  });

  factory HabitatLifestyle.fromJson(Map<String, dynamic> json) {
    return HabitatLifestyle(
      habitat: json['habitat'] as String? ?? 'Unknown',
      lifestyle: json['lifestyle'] as String? ?? 'Unknown',
      geographicRange: json['geographic_range'] as String? ?? 'Unknown',
      preferredEnvironment: json['preferred_environment'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habitat': habitat,
      'lifestyle': lifestyle,
      'geographic_range': geographicRange,
      'preferred_environment': preferredEnvironment,
    };
  }
}

/// Diet information including hunting strategy
class DietInfo {
  final String huntingStrategy;
  final List<String> typicalPrey;
  final String feedingFrequency;
  final String dietType;

  const DietInfo({
    required this.huntingStrategy,
    required this.typicalPrey,
    required this.feedingFrequency,
    required this.dietType,
  });

  factory DietInfo.fromJson(Map<String, dynamic> json) {
    return DietInfo(
      huntingStrategy: json['hunting_strategy'] as String? ?? 'Unknown',
      typicalPrey: (json['typical_prey'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      feedingFrequency: json['feeding_frequency'] as String? ?? 'Unknown',
      dietType: json['diet_type'] as String? ?? 'Carnivore',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hunting_strategy': huntingStrategy,
      'typical_prey': typicalPrey,
      'feeding_frequency': feedingFrequency,
      'diet_type': dietType,
    };
  }
}

/// Reproduction information
class ReproductionInfo {
  final String reproductionType;
  final String breedingSeason;
  final String clutchSize;
  final String gestationPeriod;
  final String matingBehavior;

  const ReproductionInfo({
    required this.reproductionType,
    required this.breedingSeason,
    required this.clutchSize,
    required this.gestationPeriod,
    required this.matingBehavior,
  });

  factory ReproductionInfo.fromJson(Map<String, dynamic> json) {
    return ReproductionInfo(
      reproductionType: json['reproduction_type'] as String? ?? 'Unknown',
      breedingSeason: json['breeding_season'] as String? ?? 'Unknown',
      clutchSize: json['clutch_size'] as String? ?? 'Unknown',
      gestationPeriod: json['gestation_period'] as String? ?? 'Unknown',
      matingBehavior: json['mating_behavior'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reproduction_type': reproductionType,
      'breeding_season': breedingSeason,
      'clutch_size': clutchSize,
      'gestation_period': gestationPeriod,
      'mating_behavior': matingBehavior,
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

/// Common question about the snake
class CommonQuestion {
  final String question;
  final String answer;

  const CommonQuestion({
    required this.question,
    required this.answer,
  });

  factory CommonQuestion.fromJson(Map<String, dynamic> json) {
    return CommonQuestion(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}

/// Alternative species that might be confused with this snake
class AlternativeSpecies {
  final String commonName;
  final String scientificName;
  final String differentiatingFeatures;
  final String dangerLevel;

  const AlternativeSpecies({
    required this.commonName,
    required this.scientificName,
    required this.differentiatingFeatures,
    required this.dangerLevel,
  });

  factory AlternativeSpecies.fromJson(Map<String, dynamic> json) {
    return AlternativeSpecies(
      commonName: json['common_name'] as String? ?? 'Unknown',
      scientificName: json['scientific_name'] as String? ?? 'Unknown',
      differentiatingFeatures: json['differentiating_features'] as String? ?? '',
      dangerLevel: json['danger_level'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'common_name': commonName,
      'scientific_name': scientificName,
      'differentiating_features': differentiatingFeatures,
      'danger_level': dangerLevel,
    };
  }
}
