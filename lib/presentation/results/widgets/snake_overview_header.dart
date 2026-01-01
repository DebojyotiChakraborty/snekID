import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/snake_identification.dart';

/// Snake overview header with quick info badges
class SnakeOverviewHeader extends StatelessWidget {
  final SnakeIdentification result;

  const SnakeOverviewHeader({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Snake type badge
          _TypeBadge(
            snakeType: result.species.snakeType,
            isVenomous: result.species.isVenomous,
          ),

          const SizedBox(height: 16),

          // Quick info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.science_outlined,
                label: result.basicInfo.venomLevel,
              ),
              _InfoChip(
                icon: Icons.straighten,
                label: result.physicalCharacteristics.formattedLengthRange,
              ),
              _InfoChip(
                icon: Icons.wb_sunny_outlined,
                label: result.basicInfo.activePeriods,
              ),
              _InfoChip(
                icon: Icons.place_outlined,
                label: result.basicInfo.nativeRegions.isNotEmpty
                    ? result.basicInfo.nativeRegions.first
                    : 'Unknown',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String snakeType;
  final bool isVenomous;

  const _TypeBadge({
    required this.snakeType,
    required this.isVenomous,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVenomous ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVenomous ? Icons.warning_amber : Icons.verified_user,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            snakeType,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceLightColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: context.textTertiaryColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: context.textSecondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
