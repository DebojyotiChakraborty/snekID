import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/snake_identification.dart';

/// Card showing match confidence
class MatchConfidenceCard extends StatelessWidget {
  final SnakeIdentification result;

  const MatchConfidenceCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                AppStrings.mostLikelyMatch,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Species name
          Text(
            result.species.commonName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Scientific name
          Text(
            result.species.scientificName,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 16),

          // Confidence and danger badges
          Row(
            children: [
              // Confidence badge
              _ConfidenceBadge(confidence: result.confidence),
              const SizedBox(width: 12),
              // Danger badge
              _DangerBadge(dangerLevel: result.dangerSafety.dangerLevel),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).round();
    final color = confidence >= 0.85
        ? AppColors.success
        : confidence >= 0.7
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_graph,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$percentage% ${AppStrings.confidence}',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerBadge extends StatelessWidget {
  final String dangerLevel;

  const _DangerBadge({required this.dangerLevel});

  Color get _color {
    final level = dangerLevel.toLowerCase();
    if (level.contains('high')) return AppColors.dangerHigh;
    if (level.contains('medium')) return AppColors.dangerMedium;
    if (level.contains('low')) return AppColors.dangerLow;
    return AppColors.dangerNone;
  }

  IconData get _icon {
    final level = dangerLevel.toLowerCase();
    if (level.contains('high')) return Icons.dangerous;
    if (level.contains('medium')) return Icons.warning;
    if (level.contains('low')) return Icons.shield;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            color: _color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            dangerLevel,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
