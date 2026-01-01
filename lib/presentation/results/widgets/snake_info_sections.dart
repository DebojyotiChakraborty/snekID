import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/snake_identification.dart';

/// All snake information sections displayed in a single scrollable view
class SnakeInfoSections extends StatelessWidget {
  final SnakeIdentification result;
  final GlobalKey overviewKey;
  final GlobalKey behaviourKey;
  final GlobalKey dangerKey;
  final GlobalKey moreKey;

  const SnakeInfoSections({
    super.key,
    required this.result,
    required this.overviewKey,
    required this.behaviourKey,
    required this.dangerKey,
    required this.moreKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== OVERVIEW SECTION =====
        Container(
          key: overviewKey,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: AppStrings.overview,
                icon: MingCuteIcons.mgc_eye_line,
                iconColor: AppColors.info,
              ),
              const SizedBox(height: 12),
              
              // Basic Information
              _InfoSection(
                title: AppStrings.basicInformation,
                icon: MingCuteIcons.mgc_information_line,
                iconColor: AppColors.info,
                items: [
                  _InfoRow(AppStrings.commonName, result.species.commonName),
                  _InfoRow(AppStrings.scientificName, result.species.scientificName, isItalic: true),
                  _InfoRow(AppStrings.snakeType, result.species.snakeType),
                  _InfoRow(AppStrings.venomLevel, result.basicInfo.venomLevel),
                  _InfoRow(AppStrings.behavior, result.basicInfo.behavior),
                  _InfoRow(AppStrings.nativeRegions, result.basicInfo.nativeRegions.join(', ')),
                  _InfoRow(AppStrings.activePeriods, result.basicInfo.activePeriods),
                ],
              ),
              const SizedBox(height: 16),
              
              // Characteristics
              _InfoSection(
                title: AppStrings.characteristics,
                icon: MingCuteIcons.mgc_ruler_line,
                iconColor: AppColors.primary,
                items: [
                  _InfoRow(AppStrings.colorDescription, result.physicalCharacteristics.colorDescription),
                  _InfoRow(AppStrings.lengthRange, result.physicalCharacteristics.formattedLengthRange),
                  _InfoRow(AppStrings.bodyPattern, result.physicalCharacteristics.bodyPattern),
                  _InfoRow(AppStrings.scaleTexture, result.physicalCharacteristics.scaleTexture),
                  _InfoRow(AppStrings.headShape, result.physicalCharacteristics.headShape),
                  _InfoRow(AppStrings.pupilShape, result.physicalCharacteristics.pupilShape),
                  _InfoRow(AppStrings.tailType, result.physicalCharacteristics.tailType),
                ],
              ),
              const SizedBox(height: 16),
              
              // Special Features
              _SpecialFeaturesCard(result: result),
              
              const SizedBox(height: 16),
              
              // Additional Information - Expandable sections
              _ExpandableInfoSection(
                title: AppStrings.mythAndFolklore,
                icon: MingCuteIcons.mgc_book_2_line,
                iconColor: AppColors.warning,
                content: result.additionalInfo.mythAndFolklore,
              ),
              const SizedBox(height: 12),
              
              _ExpandableInfoSection(
                title: AppStrings.nameOrigin,
                icon: MingCuteIcons.mgc_translate_line,
                iconColor: AppColors.info,
                content: result.additionalInfo.nameOrigin,
              ),
              const SizedBox(height: 12),
              
              _ExpandableInfoSection(
                title: AppStrings.adaptationStrategies,
                icon: MingCuteIcons.mgc_settings_4_line,
                iconColor: AppColors.primary,
                content: result.additionalInfo.adaptationStrategies,
              ),
              const SizedBox(height: 12),
              
              _ExpandableInfoSection(
                title: AppStrings.ecologicalImportance,
                icon: MingCuteIcons.mgc_leaf_line,
                iconColor: AppColors.success,
                content: result.additionalInfo.ecologicalImportance,
              ),
              const SizedBox(height: 12),
              
              _ExpandableInfoSection(
                title: AppStrings.humanInteractions,
                icon: MingCuteIcons.mgc_group_line,
                iconColor: AppColors.warning,
                content: result.additionalInfo.humanInteractions,
              ),
              
              if (result.additionalInfo.identifyingTips.isNotEmpty) ...[
                const SizedBox(height: 16),
                _InfoSection(
                  title: AppStrings.identifyingTips,
                  icon: MingCuteIcons.mgc_search_line,
                  iconColor: AppColors.info,
                  items: result.additionalInfo.identifyingTips
                      .map((tip) => _BulletItem(tip, bulletColor: AppColors.info))
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ===== BEHAVIOUR SECTION =====
        Container(
          key: behaviourKey,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: AppStrings.behaviour,
                icon: MingCuteIcons.mgc_target_line,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 12),
              
              // Habitat & Lifestyle
              _InfoSection(
                title: AppStrings.habitatAndLifestyle,
                icon: MingCuteIcons.mgc_tree_line,
                iconColor: AppColors.primary,
                items: [
                  _InfoRow(AppStrings.habitat, result.habitatLifestyle.habitat),
                  _InfoRow(AppStrings.lifestyle, result.habitatLifestyle.lifestyle),
                  _InfoRow(AppStrings.geographicRange, result.habitatLifestyle.geographicRange),
                  _InfoRow(AppStrings.preferredEnvironment, result.habitatLifestyle.preferredEnvironment),
                ],
              ),
              const SizedBox(height: 16),
              
              // Diet & Hunting
              _InfoSection(
                title: AppStrings.dietAndHunting,
                icon: MingCuteIcons.mgc_knife_line,
                iconColor: AppColors.warning,
                items: [
                  _InfoRow(AppStrings.huntingStrategy, result.dietInfo.huntingStrategy),
                  _InfoRow(AppStrings.dietType, result.dietInfo.dietType),
                  _InfoRow(AppStrings.feedingFrequency, result.dietInfo.feedingFrequency),
                  if (result.dietInfo.typicalPrey.isNotEmpty)
                    _InfoRow(AppStrings.typicalPrey, result.dietInfo.typicalPrey.join(', ')),
                ],
              ),
              const SizedBox(height: 16),
              
              // Reproduction
              _InfoSection(
                title: AppStrings.reproduction,
                icon: MingCuteIcons.mgc_egg_crack_line,
                iconColor: AppColors.success,
                items: [
                  _InfoRow(AppStrings.reproductionType, result.reproductionInfo.reproductionType),
                  _InfoRow(AppStrings.breedingSeason, result.reproductionInfo.breedingSeason),
                  _InfoRow(AppStrings.clutchSize, result.reproductionInfo.clutchSize),
                  _InfoRow(AppStrings.gestationPeriod, result.reproductionInfo.gestationPeriod),
                  _InfoRow(AppStrings.matingBehavior, result.reproductionInfo.matingBehavior),
                ],
              ),
              
              if (result.specialFeatures.defensiveBehaviors.isNotEmpty) ...[
                const SizedBox(height: 16),
                _InfoSection(
                  title: AppStrings.defensiveBehaviors,
                  icon: MingCuteIcons.mgc_shield_line,
                  iconColor: AppColors.warning,
                  items: result.specialFeatures.defensiveBehaviors
                      .map((b) => _BulletItem(b))
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ===== DANGER SECTION =====
        Container(
          key: dangerKey,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: AppStrings.danger,
                icon: MingCuteIcons.mgc_warning_line,
                iconColor: AppColors.error,
              ),
              const SizedBox(height: 12),
              
              // Danger Level Card
              _DangerLevelCard(dangerLevel: result.dangerSafety.dangerLevel),
              
              if (result.dangerSafety.biteSymptoms.isNotEmpty) ...[
                const SizedBox(height: 16),
                _InfoSection(
                  title: AppStrings.biteSymptoms,
                  icon: MingCuteIcons.mgc_warning_line,
                  iconColor: AppColors.error,
                  items: result.dangerSafety.biteSymptoms
                      .map((s) => _BulletItem(s, bulletColor: AppColors.error))
                      .toList(),
                ),
              ],
              
              if (result.dangerSafety.safetyTips.isNotEmpty) ...[
                const SizedBox(height: 16),
                _InfoSection(
                  title: AppStrings.safetyTips,
                  icon: MingCuteIcons.mgc_safe_shield_2_line,
                  iconColor: AppColors.success,
                  items: result.dangerSafety.safetyTips
                      .map((t) => _BulletItem(t, bulletColor: AppColors.success))
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ===== MORE SECTION =====
        Container(
          key: moreKey,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: AppStrings.more,
                icon: MingCuteIcons.mgc_more_2_line,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 12),
              
              // Common Questions
              if (result.commonQuestions.isNotEmpty) ...[
                _QuestionsSection(questions: result.commonQuestions),
                const SizedBox(height: 16),
              ],
              
              // Possible Alternatives
              if (result.possibleAlternatives.isNotEmpty)
                _AlternativesSection(alternatives: result.possibleAlternatives),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

/// Section header with title and icon
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: context.textPrimaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Information section with title, icon, and items
class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> items;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }
}

/// Expandable info section for long text content
class _ExpandableInfoSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String content;

  const _ExpandableInfoSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
  });

  @override
  State<_ExpandableInfoSection> createState() => _ExpandableInfoSectionState();
}

class _ExpandableInfoSectionState extends State<_ExpandableInfoSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: context.textPrimaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      MingCuteIcons.mgc_down_line,
                      color: context.textTertiaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.content,
                style: TextStyle(
                  color: context.textSecondaryColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

/// Single info row with label and value
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isItalic;

  const _InfoRow(this.label, this.value, {this.isItalic = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: context.textTertiaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: context.textPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bullet point item for lists
class _BulletItem extends StatelessWidget {
  final String text;
  final Color? bulletColor;

  const _BulletItem(this.text, {this.bulletColor});

  @override
  Widget build(BuildContext context) {
    final color = bulletColor ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.textPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Special Features Card with visual indicators
class _SpecialFeaturesCard extends StatelessWidget {
  final SnakeIdentification result;

  const _SpecialFeaturesCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    MingCuteIcons.mgc_sparkles_2_line,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.specialFeatures,
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Features grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _FeatureRow(
                  label: AppStrings.mimicSpecies,
                  value: result.specialFeatures.isMimicSpecies,
                ),
                _FeatureRow(
                  label: AppStrings.usesCamouflage,
                  value: result.specialFeatures.usesCamouflage,
                ),
                _FeatureRow(
                  label: AppStrings.hasRattle,
                  value: result.specialFeatures.hasRattle,
                ),
                _FeatureRow(
                  label: AppStrings.hissingSound,
                  value: result.specialFeatures.hissingSound,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature row with visual indicator
class _FeatureRow extends StatelessWidget {
  final String label;
  final bool value;

  const _FeatureRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.success.withValues(alpha: 0.15)
                  : context.surfaceLightColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value
                    ? AppColors.success.withValues(alpha: 0.3)
                    : context.borderColor,
                width: 1,
              ),
            ),
            child: Icon(
              value ? MingCuteIcons.mgc_check_fill : MingCuteIcons.mgc_close_fill,
              color: value ? AppColors.success : context.textMutedColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: context.textPrimaryColor,
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

/// Danger Level Card with visual emphasis
class _DangerLevelCard extends StatelessWidget {
  final String dangerLevel;

  const _DangerLevelCard({required this.dangerLevel});

  Color get _color {
    final level = dangerLevel.toLowerCase();
    if (level.contains('high') || level.contains('deadly') || level.contains('extreme')) {
      return AppColors.dangerHigh;
    }
    if (level.contains('medium') || level.contains('moderate')) {
      return AppColors.dangerMedium;
    }
    if (level.contains('low') || level.contains('mild')) {
      return AppColors.dangerLow;
    }
    return AppColors.dangerNone;
  }

  IconData get _icon {
    final level = dangerLevel.toLowerCase();
    if (level.contains('high') || level.contains('deadly') || level.contains('extreme')) {
      return MingCuteIcons.mgc_alert_octagon_fill;
    }
    if (level.contains('medium') || level.contains('moderate')) {
      return MingCuteIcons.mgc_warning_fill;
    }
    if (level.contains('low') || level.contains('mild')) {
      return MingCuteIcons.mgc_information_fill;
    }
    return MingCuteIcons.mgc_check_circle_fill;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _color.withValues(alpha: 0.15),
            _color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _color.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _icon,
              color: _color,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.dangerLevel,
                  style: TextStyle(
                    color: context.textTertiaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dangerLevel,
                  style: TextStyle(
                    color: _color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Common Questions Section
class _QuestionsSection extends StatelessWidget {
  final List<CommonQuestion> questions;

  const _QuestionsSection({required this.questions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    MingCuteIcons.mgc_question_line,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.commonQuestions,
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Questions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return Column(
                  children: [
                    if (index > 0)
                      Divider(
                        color: context.borderColor,
                        height: 24,
                      ),
                    _QuestionItem(question: question),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single question item
class _QuestionItem extends StatefulWidget {
  final CommonQuestion question;

  const _QuestionItem({required this.question});

  @override
  State<_QuestionItem> createState() => _QuestionItemState();
}

class _QuestionItemState extends State<_QuestionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                MingCuteIcons.mgc_question_fill,
                color: AppColors.info,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.question.question,
                  style: TextStyle(
                    color: context.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  MingCuteIcons.mgc_down_line,
                  color: context.textTertiaryColor,
                  size: 18,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 28, top: 8),
              child: Text(
                widget.question.answer,
                style: TextStyle(
                  color: context.textSecondaryColor,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

/// Possible Alternatives Section
class _AlternativesSection extends StatelessWidget {
  final List<AlternativeSpecies> alternatives;

  const _AlternativesSection({required this.alternatives});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    MingCuteIcons.mgc_transfer_line,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.possibleAlternatives,
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Alternatives
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: alternatives.asMap().entries.map((entry) {
                final index = entry.key;
                final alternative = entry.value;
                return Column(
                  children: [
                    if (index > 0)
                      Divider(
                        color: context.borderColor,
                        height: 24,
                      ),
                    _AlternativeItem(alternative: alternative),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single alternative species item
class _AlternativeItem extends StatelessWidget {
  final AlternativeSpecies alternative;

  const _AlternativeItem({required this.alternative});

  Color _getDangerColor() {
    final level = alternative.dangerLevel.toLowerCase();
    if (level.contains('high') || level.contains('deadly')) {
      return AppColors.dangerHigh;
    }
    if (level.contains('medium') || level.contains('moderate')) {
      return AppColors.dangerMedium;
    }
    if (level.contains('low') || level.contains('mild')) {
      return AppColors.dangerLow;
    }
    return AppColors.dangerNone;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alternative.commonName,
                    style: TextStyle(
                      color: context.textPrimaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alternative.scientificName,
                    style: TextStyle(
                      color: context.textTertiaryColor,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getDangerColor().withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getDangerColor().withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                alternative.dangerLevel,
                style: TextStyle(
                  color: _getDangerColor(),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (alternative.differentiatingFeatures.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                MingCuteIcons.mgc_arrow_right_line,
                color: context.textTertiaryColor,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  alternative.differentiatingFeatures,
                  style: TextStyle(
                    color: context.textSecondaryColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
