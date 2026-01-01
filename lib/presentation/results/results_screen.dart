import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'widgets/analysis_loading.dart';
import 'widgets/image_header.dart';
import 'widgets/warning_banner.dart';
import 'widgets/match_confidence_card.dart';
import 'widgets/snake_overview_header.dart';
import 'widgets/snake_info_sections.dart';

/// Results screen showing snake identification
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  final ImageService _imageService = ImageService();
  final ScrollController _scrollController = ScrollController();
  
  // Keys for each section to track their positions
  final GlobalKey _overviewKey = GlobalKey();
  final GlobalKey _behaviourKey = GlobalKey();
  final GlobalKey _dangerKey = GlobalKey();
  final GlobalKey _moreKey = GlobalKey();
  
  // Current active tab index based on scroll position
  int _activeTabIndex = 0;
  
  // Flag to prevent scroll listener updates when programmatically scrolling
  bool _isScrollingToSection = false;
  
  // Flag to track if history has been saved
  bool _hasSavedToHistory = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Trigger identification when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startIdentification();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isScrollingToSection) return;
    
    // Get the scroll offset
    final scrollOffset = _scrollController.offset;
    
    // Calculate which section is currently in view
    final behaviourOffset = _getWidgetOffset(_behaviourKey);
    final dangerOffset = _getWidgetOffset(_dangerKey);
    final moreOffset = _getWidgetOffset(_moreKey);
    
    // Buffer to determine active section (offset from top)
    const buffer = 200.0;
    
    int newIndex = 0;
    
    if (moreOffset != null && scrollOffset >= moreOffset - buffer) {
      newIndex = 3;
    } else if (dangerOffset != null && scrollOffset >= dangerOffset - buffer) {
      newIndex = 2;
    } else if (behaviourOffset != null && scrollOffset >= behaviourOffset - buffer) {
      newIndex = 1;
    } else {
      newIndex = 0;
    }
    
    if (newIndex != _activeTabIndex) {
      setState(() {
        _activeTabIndex = newIndex;
      });
    }
  }

  double? _getWidgetOffset(GlobalKey key) {
    final RenderObject? renderObject = key.currentContext?.findRenderObject();
    if (renderObject == null) return null;
    
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
    final RevealedOffset offsetToReveal = viewport.getOffsetToReveal(renderObject, 0.0);
    
    return offsetToReveal.offset;
  }

  void _scrollToSection(int index) async {
    GlobalKey targetKey;
    switch (index) {
      case 0:
        targetKey = _overviewKey;
        break;
      case 1:
        targetKey = _behaviourKey;
        break;
      case 2:
        targetKey = _dangerKey;
        break;
      case 3:
        targetKey = _moreKey;
        break;
      default:
        return;
    }
    
    final offset = _getWidgetOffset(targetKey);
    if (offset != null) {
      _isScrollingToSection = true;
      setState(() {
        _activeTabIndex = index;
      });
      
      await _scrollController.animateTo(
        offset - 100, // Offset to account for sticky header
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      _isScrollingToSection = false;
    }
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
        await ref.read(historyProvider.notifier).addAnalysis(
          imagePath: savedPath,
          identification: result,
        );
        
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
      
      ref.read(favoritesProvider.notifier).toggleFavorite(
        identification: result,
        imagePath: image?.path,
      );
      
      final isFavorite = ref.read(
        isFavoriteProvider(result.species.commonName),
      );
      
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? AppStrings.removedFromFavorites : AppStrings.addedToFavorites,
          ),
          backgroundColor: isFavorite ? AppColors.textMuted : AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        loading: () => AnalysisLoading(imageFile: selectedImage),
        error: (error, _) => _buildErrorState(error.toString()),
        data: (result) {
          if (result == null) {
            return AnalysisLoading(imageFile: selectedImage);
          }

          // Auto-save to history when result is available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoSaveToHistory();
          });

          final showWarning = result.confidence < 0.85;
          final isFavorite = ref.watch(
            isFavoriteProvider(result.species.commonName),
          );

          return Stack(
            children: [
              NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    // Image header with close button
                    SliverToBoxAdapter(
                      child: ImageHeader(
                        imageFile: selectedImage,
                        onClose: _onClose,
                      ),
                    ),

                    // Warning banner (if low confidence)
                    if (showWarning)
                      const SliverToBoxAdapter(
                        child: WarningBanner(),
                      ),

                    // Match confidence section
                    SliverToBoxAdapter(
                      child: MatchConfidenceCard(result: result),
                    ),

                    // Snake overview header
                    SliverToBoxAdapter(
                      child: SnakeOverviewHeader(result: result),
                    ),

                    // Sticky Tab bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabBarDelegate(
                        activeIndex: _activeTabIndex,
                        onTabTap: _scrollToSection,
                      ),
                    ),
                  ];
                },
                body: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      // All snake info sections
                      SnakeInfoSections(
                        result: result,
                        overviewKey: _overviewKey,
                        behaviourKey: _behaviourKey,
                        dangerKey: _dangerKey,
                        moreKey: _moreKey,
                      ),

                      const SizedBox(height: 24),

                      // Disclaimer
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        child: Text(
                          AppStrings.disclaimer,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.textMutedColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      // Extra bottom padding for FAB and safe area
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                    ],
                  ),
                ),
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
            TextButton(
              onPressed: _onClose,
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
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
          color: isFavorite ? AppColors.error : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isFavorite ? AppColors.error : AppColors.primary)
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
                ? MingCuteIcons.mgc_heart_fill 
                : MingCuteIcons.mgc_heart_line,
            key: ValueKey(isFavorite),
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

/// Sticky tab bar delegate for pinned header
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final int activeIndex;
  final Function(int) onTabTap;

  _StickyTabBarDelegate({
    required this.activeIndex,
    required this.onTabTap,
  });

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = context.isDarkMode;
    
    return Container(
      color: context.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.surfaceLightColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: overlapsContent ? [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            _TabItem(
              label: AppStrings.overview,
              isActive: activeIndex == 0,
              onTap: () => onTabTap(0),
              isDark: isDark,
            ),
            _TabItem(
              label: AppStrings.behaviour,
              isActive: activeIndex == 1,
              onTap: () => onTabTap(1),
              isDark: isDark,
            ),
            _TabItem(
              label: AppStrings.danger,
              isActive: activeIndex == 2,
              onTap: () => onTabTap(2),
              isDark: isDark,
            ),
            _TabItem(
              label: AppStrings.more,
              isActive: activeIndex == 3,
              onTap: () => onTabTap(3),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return activeIndex != oldDelegate.activeIndex;
  }
}

/// Individual tab item
class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive 
                  ? (isDark ? AppColors.backgroundDark : AppColors.white)
                  : context.textTertiaryColor,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
