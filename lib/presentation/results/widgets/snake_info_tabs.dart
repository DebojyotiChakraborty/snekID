import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/snake_identification.dart';

/// Tabbed content for snake information
class SnakeInfoTabs extends StatelessWidget {
  final SnakeIdentification result;
  final TabController tabController;

  const SnakeInfoTabs({
    super.key,
    required this.result,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: AppColors.background,
            unselectedLabelColor: AppColors.textTertiary,
            labelPadding: EdgeInsets.zero,
            padding: const EdgeInsets.all(4),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: AppStrings.overview),
              Tab(text: AppStrings.behaviour),
              Tab(text: AppStrings.danger),
              Tab(text: AppStrings.more),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab content
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: tabController,
            children: [
              _OverviewTab(result: result),
              _BehaviourTab(result: result),
              _DangerTab(result: result),
              _MoreTab(result: result),
            ],
          ),
        ),
      ],
    );
  }
}

/// Overview tab content
class _OverviewTab extends StatelessWidget {
  final SnakeIdentification result;

  const _OverviewTab({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _InfoSection(
            title: AppStrings.basicInformation,
            items: [
              _InfoItem(AppStrings.commonName, result.species.commonName),
              _InfoItem(AppStrings.scientificName, result.species.scientificName),
              _InfoItem(AppStrings.snakeType, result.species.snakeType),
              _InfoItem(AppStrings.venomLevel, result.basicInfo.venomLevel),
              _InfoItem(AppStrings.nativeRegions, result.basicInfo.nativeRegions.join(', ')),
              _InfoItem(AppStrings.activePeriods, result.basicInfo.activePeriods),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: AppStrings.characteristics,
            items: [
              _InfoItem(AppStrings.colorDescription, result.physicalCharacteristics.colorDescription),
              _InfoItem(AppStrings.lengthRange, result.physicalCharacteristics.formattedLengthRange),
              _InfoItem(AppStrings.bodyPattern, result.physicalCharacteristics.bodyPattern),
              _InfoItem(AppStrings.scaleTexture, result.physicalCharacteristics.scaleTexture),
              _InfoItem(AppStrings.headShape, result.physicalCharacteristics.headShape),
              _InfoItem(AppStrings.pupilShape, result.physicalCharacteristics.pupilShape),
            ],
          ),
        ],
      ),
    );
  }
}

/// Behaviour tab content
class _BehaviourTab extends StatelessWidget {
  final SnakeIdentification result;

  const _BehaviourTab({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _InfoSection(
            title: 'Behavior',
            items: [
              _InfoItem(AppStrings.behavior, result.basicInfo.behavior),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: AppStrings.specialFeatures,
            items: [
              _BoolInfoItem(AppStrings.mimicSpecies, result.specialFeatures.isMimicSpecies),
              _BoolInfoItem(AppStrings.usesCamouflage, result.specialFeatures.usesCamouflage),
              _BoolInfoItem(AppStrings.hasRattle, result.specialFeatures.hasRattle),
              _BoolInfoItem(AppStrings.hissingSound, result.specialFeatures.hissingSound),
            ],
          ),
          const SizedBox(height: 16),
          if (result.specialFeatures.defensiveBehaviors.isNotEmpty)
            _InfoSection(
              title: AppStrings.defensiveBehaviors,
              items: result.specialFeatures.defensiveBehaviors
                  .map((b) => _InfoItem('', b))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

/// Danger tab content
class _DangerTab extends StatelessWidget {
  final SnakeIdentification result;

  const _DangerTab({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _InfoSection(
            title: AppStrings.dangerAndSafety,
            items: [
              _InfoItem(AppStrings.dangerLevel, result.dangerSafety.dangerLevel),
            ],
          ),
          const SizedBox(height: 16),
          if (result.dangerSafety.biteSymptoms.isNotEmpty)
            _InfoSection(
              title: AppStrings.biteSymptoms,
              items: result.dangerSafety.biteSymptoms
                  .map((s) => _InfoItem('', s))
                  .toList(),
            ),
          const SizedBox(height: 16),
          if (result.dangerSafety.safetyTips.isNotEmpty)
            _InfoSection(
              title: AppStrings.safetyTips,
              items: result.dangerSafety.safetyTips
                  .map((t) => _InfoItem('', t))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

/// More tab content
class _MoreTab extends StatelessWidget {
  final SnakeIdentification result;

  const _MoreTab({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _InfoSection(
            title: AppStrings.habitatAndLifestyle,
            items: [
              _InfoItem(AppStrings.habitat, result.habitatLifestyle.habitat),
              _InfoItem(AppStrings.diet, result.habitatLifestyle.diet),
              _InfoItem(AppStrings.reproduction, result.habitatLifestyle.reproduction),
              _InfoItem(AppStrings.breedingSeason, result.habitatLifestyle.breedingSeason),
            ],
          ),
        ],
      ),
    );
  }
}

/// Information section with title and items
class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _InfoSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }
}

/// Single info item with label and value
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Boolean info item with check/cross icon
class _BoolInfoItem extends StatelessWidget {
  final String label;
  final bool value;

  const _BoolInfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? AppColors.success : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
