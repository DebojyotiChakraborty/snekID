import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/capture_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/identification_provider.dart';
import '../../data/services/image_service.dart';
import '../../data/models/snake_identification.dart';
// import 'widgets/analysis_loading.dart';
import '../common/widgets/custom_tab_bar.dart';
import '../common/widgets/drops.dart';
import 'widgets/warning_banner.dart';

/// Results screen showing snake identification
class ResultsScreen extends ConsumerStatefulWidget {
  final SnakeIdentification? identification;
  final bool isNewAnalysis;
  final File? imageFile;

  const ResultsScreen({
    super.key,
    this.identification,
    this.isNewAnalysis = false,
    this.imageFile,
  });

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen>
    with SingleTickerProviderStateMixin {
  final ImageService _imageService = ImageService();
  late TabController _tabController;

  // Flag to track if history has been saved
  bool _hasSavedToHistory = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Check if we have pre-loaded data
    if (widget.identification != null) {
      if (!widget.isNewAnalysis) {
        _hasSavedToHistory = true; // Already saved/historic if NOT new
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.imageFile != null) {
          ref.read(selectedImageProvider.notifier).state = widget.imageFile;
        }
        ref
            .read(identificationProvider.notifier)
            .setResult(widget.identification!);
      });
    } else {
      // Trigger identification when screen loads
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startIdentification();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startIdentification() {
    final image = ref.read(selectedImageProvider);
    if (image != null) {
      ref.read(identificationProvider.notifier).identifySnake(image);
    }
  }

  void _onClose() {
    // Clear the selected image
    ref.read(selectedImageProvider.notifier).state = null;
    // Reset identification state
    ref.read(identificationProvider.notifier).reset();
    // Reset history save flag
    _hasSavedToHistory = false;
    context.pop();
  }

  /// Automatically save to history when identification is complete
  Future<void> _autoSaveToHistory() async {
    if (_hasSavedToHistory) return;

    final image = ref.read(selectedImageProvider);
    final result = ref.read(identificationProvider).valueOrNull;

    if (image != null && result != null) {
      try {
        // Save image for history
        final savedPath = await _imageService.saveImageForHistory(image);

        // Add to history
        await ref
            .read(historyProvider.notifier)
            .addAnalysis(imagePath: savedPath, identification: result);

        _hasSavedToHistory = true;
      } catch (e) {
        // Silently fail - don't interrupt user experience
        debugPrint('Failed to auto-save to history: $e');
      }
    }
  }

  void _toggleFavorite() {
    final image = ref.read(selectedImageProvider);
    final result = ref.read(identificationProvider).valueOrNull;

    if (result != null) {
      // Trigger haptic feedback
      HapticFeedback.mediumImpact();

      ref
          .read(favoritesProvider.notifier)
          .toggleFavorite(identification: result, imagePath: image?.path);

      final isFavorite = ref.read(
        isFavoriteProvider(result.species.commonName),
      );

      Drops.show(
        context,
        title:
            isFavorite
                ? AppStrings.removedFromFavorites
                : AppStrings.addedToFavorites,
        backgroundColor: isFavorite ? AppColors.textMuted : AppColors.success,
        position: DropPosition.bottom,
        icon:
            isFavorite
                ? MingCuteIcons.mgc_star_line
                : MingCuteIcons.mgc_star_fill,
        iconColor: AppColors.white,
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedImage = ref.watch(selectedImageProvider);
    final identificationState = ref.watch(identificationProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: identificationState.when(
        loading:
            () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.infoAccentGreen,
                ),
              ),
            ),
        error: (error, _) => _buildErrorState(error.toString()),
        data: (result) {
          if (result == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Auto-save to history when result is available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoSaveToHistory();
          });

          final showWarning = result.confidence < 0.85;
          final isFavorite = ref.watch(
            isFavoriteProvider(result.species.commonName),
          );

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 400.0,
                  pinned: true,
                  backgroundColor: context.backgroundColor,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        MingCuteIcons.mgc_left_line,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _onClose,
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          MingCuteIcons.mgc_more_2_fill,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        // TODO: Show menu
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        selectedImage != null
                            ? Hero(
                              tag: 'snake_image',
                              child: Image.file(
                                selectedImage,
                                fit: BoxFit.cover,
                              ),
                            )
                            : Container(
                              color: context.surfaceLightColor,
                              child: Icon(
                                MingCuteIcons.mgc_pic_line,
                                size: 64,
                                color: context.textMutedColor,
                              ),
                            ),

                        // Gradient Overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  // Top scrim for status bar/buttons
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                  // Bottom fade to background
                                  context.backgroundColor.withOpacity(0.0),
                                  context.backgroundColor,
                                ],
                                stops: const [0.0, 0.2, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Snake Info Overlay
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.species.commonName,
                                style: TextStyle(
                                  color: context.textPrimaryColor,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result.species.scientificName,
                                style: TextStyle(
                                  color: context.textSecondaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Badges
                      _SnakeBadges(result: result),

                      // Warning Banner
                      if (showWarning) const WarningBanner(),

                      // Match Confidence (Simplified or kept as is if informative)
                      // We can keep it but maybe we don't need the header parts inside it?
                      // For now, let's keep it as is, but it might be redundant.
                      // Let's hide it if it's too redundant, but it has the percentage.
                      // Maybe we can create a simpler version or just keep it.
                      // MatchConfidenceCard(result: result),
                      // Actually, the user's screenshot doesn't seem to show the confidence card in the middle.
                      // I will omit it for now to match "this layout" closer, or maybe it's below?
                      // The prompt says "entire page should be scrollable... not just the card part".
                      // The previous card part was likely the MatchConfidenceCard.
                      // I'll leave it out as the header now contains the main info.
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    CustomTabBar(
                      controller: _tabController,
                      tabs: const [
                        AppStrings.overview,
                        AppStrings.behaviour,
                        AppStrings.danger,
                        AppStrings.more,
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(result: result),
                    _BehaviourTab(result: result),
                    _DangerTab(result: result),
                    _MoreTab(result: result),
                  ],
                ),

                // Floating Action Button for favorites
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                  right: 24,
                  child: _FavoriteFloatingButton(
                    isFavorite: isFavorite,
                    onTap: _toggleFavorite,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              MingCuteIcons.mgc_warning_line,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.errorAnalysis,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: context.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startIdentification,
              child: const Text(AppStrings.tryAgain),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _onClose, child: const Text('Go Back')),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _tabBarWidget;

  _SliverAppBarDelegate(this._tabBarWidget);

  @override
  double get minExtent => 56; // TabBar height + padding
  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: context.backgroundColor, child: _tabBarWidget);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

/// Floating button for adding/removing favorites with haptic feedback
class _FavoriteFloatingButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteFloatingButton({
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isFavorite ? AppColors.error : AppColors.infoAccentGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isFavorite ? AppColors.error : AppColors.infoAccentGreen)
                  .withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            isFavorite
                ? MingCuteIcons.mgc_star_fill
                : MingCuteIcons.mgc_star_line,
            key: ValueKey(isFavorite),
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

/// Snake badges section
class _SnakeBadges extends StatelessWidget {
  final SnakeIdentification result;

  const _SnakeBadges({required this.result});

  Color _getVenomColor() {
    final level = result.basicInfo.venomLevel.toLowerCase();
    if (level.contains('mildly')) {
      return AppColors.warning;
    } else if (level.contains('highly') || level.contains('deadly')) {
      return AppColors.error;
    } else if (level.contains('non') || level.contains('not')) {
      return AppColors.success;
    }
    return AppColors.info;
  }

  Color _getDangerColor() {
    final level = result.dangerSafety.dangerLevel.toLowerCase();
    if (level.contains('high') ||
        level.contains('deadly') ||
        level.contains('extreme')) {
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: [
          _Badge(
            icon: MingCuteIcons.mgc_flask_line,
            label: result.basicInfo.venomLevel,
            color: _getVenomColor(),
          ),
          _Badge(
            icon: MingCuteIcons.mgc_ruler_line,
            label: result.physicalCharacteristics.formattedLengthRange,
            color: AppColors.infoAccentGreen,
          ),
          _Badge(
            icon: MingCuteIcons.mgc_warning_line,
            label: result.dangerSafety.dangerLevel,
            color: _getDangerColor(),
          ),
        ],
      ),
    );
  }
}

/// Individual badge
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
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

/// Overview tab content
class _OverviewTab extends StatelessWidget {
  final SnakeIdentification result;

  const _OverviewTab({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(AppStrings.basicInformation),
          const SizedBox(height: 12),
          _InfoCard(
            items: [
              _InfoRow(AppStrings.commonName, result.species.commonName),
              _InfoRow(
                AppStrings.scientificName,
                result.species.scientificName,
              ),
              _InfoRow(AppStrings.snakeType, result.species.snakeType),
              _InfoRow(AppStrings.venomLevel, result.basicInfo.venomLevel),
              _InfoRow(AppStrings.behavior, result.basicInfo.behavior),
              _InfoRow(
                AppStrings.nativeRegions,
                result.basicInfo.nativeRegions.join(', '),
              ),
              _InfoRow(
                AppStrings.activePeriods,
                result.basicInfo.activePeriods,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(AppStrings.characteristics),
          const SizedBox(height: 12),
          _InfoCard(
            items: [
              _InfoRow(
                AppStrings.colorDescription,
                result.physicalCharacteristics.colorDescription,
              ),
              _InfoRow(
                AppStrings.lengthRange,
                result.physicalCharacteristics.formattedLengthRange,
              ),
              _InfoRow(
                AppStrings.bodyPattern,
                result.physicalCharacteristics.bodyPattern,
              ),
              _InfoRow(
                AppStrings.scaleTexture,
                result.physicalCharacteristics.scaleTexture,
              ),
              _InfoRow(
                AppStrings.headShape,
                result.physicalCharacteristics.headShape,
              ),
              _InfoRow(
                AppStrings.pupilShape,
                result.physicalCharacteristics.pupilShape,
              ),
              _InfoRow(
                AppStrings.tailType,
                result.physicalCharacteristics.tailType,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.disclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textMutedColor, fontSize: 11),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(AppStrings.habitatAndLifestyle),
          const SizedBox(height: 12),
          _InfoCard(
            items: [
              _InfoRow(AppStrings.habitat, result.habitatLifestyle.habitat),
              _InfoRow(AppStrings.lifestyle, result.habitatLifestyle.lifestyle),
              _InfoRow(
                AppStrings.geographicRange,
                result.habitatLifestyle.geographicRange,
              ),
              _InfoRow(
                AppStrings.preferredEnvironment,
                result.habitatLifestyle.preferredEnvironment,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(AppStrings.dietAndHunting),
          const SizedBox(height: 12),
          _InfoCard(
            items: [
              _InfoRow(
                AppStrings.huntingStrategy,
                result.dietInfo.huntingStrategy,
              ),
              _InfoRow(AppStrings.dietType, result.dietInfo.dietType),
              _InfoRow(
                AppStrings.feedingFrequency,
                result.dietInfo.feedingFrequency,
              ),
              if (result.dietInfo.typicalPrey.isNotEmpty)
                _InfoRow(
                  AppStrings.typicalPrey,
                  result.dietInfo.typicalPrey.join(', '),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(AppStrings.reproduction),
          const SizedBox(height: 12),
          _InfoCard(
            items: [
              _InfoRow(
                AppStrings.reproductionType,
                result.reproductionInfo.reproductionType,
              ),
              _InfoRow(
                AppStrings.breedingSeason,
                result.reproductionInfo.breedingSeason,
              ),
              _InfoRow(
                AppStrings.clutchSize,
                result.reproductionInfo.clutchSize,
              ),
              _InfoRow(
                AppStrings.gestationPeriod,
                result.reproductionInfo.gestationPeriod,
              ),
              _InfoRow(
                AppStrings.matingBehavior,
                result.reproductionInfo.matingBehavior,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.disclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textMutedColor, fontSize: 11),
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

  Color _getDangerColor() {
    final level = result.dangerSafety.dangerLevel.toLowerCase();
    if (level.contains('high') ||
        level.contains('deadly') ||
        level.contains('extreme')) {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(AppStrings.dangerLevel),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getDangerColor().withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getDangerColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    MingCuteIcons.mgc_warning_fill,
                    color: _getDangerColor(),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Level',
                        style: TextStyle(
                          color: context.textTertiaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.dangerSafety.dangerLevel,
                        style: TextStyle(
                          color: _getDangerColor(),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (result.dangerSafety.biteSymptoms.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionTitle(AppStrings.biteSymptoms),
            const SizedBox(height: 12),
            _InfoCard(
              items:
                  result.dangerSafety.biteSymptoms
                      .map((s) => _BulletItem(s))
                      .toList(),
            ),
          ],
          if (result.dangerSafety.safetyTips.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionTitle(AppStrings.safetyTips),
            const SizedBox(height: 12),
            _InfoCard(
              items:
                  result.dangerSafety.safetyTips
                      .map((t) => _BulletItem(t))
                      .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            AppStrings.disclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textMutedColor, fontSize: 11),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.commonQuestions.isNotEmpty) ...[
            _SectionTitle(AppStrings.commonQuestions),
            const SizedBox(height: 12),
            ...result.commonQuestions.map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _QuestionCard(question: q),
              ),
            ),
          ],
          if (result.possibleAlternatives.isNotEmpty) ...[
            const SizedBox(height: 8),
            _SectionTitle(AppStrings.possibleAlternatives),
            const SizedBox(height: 12),
            ...result.possibleAlternatives.map(
              (alt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AlternativeCard(alternative: alt),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            AppStrings.disclaimer,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textMutedColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Section title
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.textPrimaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}

/// Clean info card without shadows
class _InfoCard extends StatelessWidget {
  final List<Widget> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: items),
    );
  }
}

/// Info row with label and value
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                color: context.textSecondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: context.textPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bullet item for lists
class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: context.textTertiaryColor,
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
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Question card
class _QuestionCard extends StatefulWidget {
  final CommonQuestion question;

  const _QuestionCard({required this.question});

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  Expanded(
                    child: Text(
                      widget.question.question,
                      style: TextStyle(
                        color: context.textPrimaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? MingCuteIcons.mgc_up_line
                        : MingCuteIcons.mgc_down_line,
                    color: context.textTertiaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.question.answer,
                style: TextStyle(
                  color: context.textSecondaryColor,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Alternative species card
class _AlternativeCard extends StatelessWidget {
  final AlternativeSpecies alternative;

  const _AlternativeCard({required this.alternative});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
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
            ],
          ),
          if (alternative.differentiatingFeatures.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              alternative.differentiatingFeatures,
              style: TextStyle(
                color: context.textSecondaryColor,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
