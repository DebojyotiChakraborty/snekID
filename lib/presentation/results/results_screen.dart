import 'package:flutter/material.dart';
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
import 'widgets/snake_info_tabs.dart';

/// Results screen showing snake identification
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Trigger identification when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startIdentification();
    });
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
    context.pop();
  }

  Future<void> _saveToHistory() async {
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
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved to history'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _toggleFavorite() {
    final image = ref.read(selectedImageProvider);
    final result = ref.read(identificationProvider).valueOrNull;
    
    if (result != null) {
      ref.read(favoritesProvider.notifier).toggleFavorite(
        identification: result,
        imagePath: image?.path,
      );
      
      final isFavorite = ref.read(
        isFavoriteProvider(result.species.commonName),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? 'Removed from favorites' : 'Added to favorites!',
          ),
          backgroundColor: isFavorite ? AppColors.textMuted : AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedImage = ref.watch(selectedImageProvider);
    final identificationState = ref.watch(identificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: identificationState.when(
        loading: () => AnalysisLoading(imageFile: selectedImage),
        error: (error, _) => _buildErrorState(error.toString()),
        data: (result) {
          if (result == null) {
            return AnalysisLoading(imageFile: selectedImage);
          }

          final showWarning = result.confidence < 0.85;
          final isFavorite = ref.watch(
            isFavoriteProvider(result.species.commonName),
          );

          return CustomScrollView(
            slivers: [
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

              // Tabbed content
              SliverToBoxAdapter(
                child: SnakeInfoTabs(
                  result: result,
                  tabController: _tabController,
                ),
              ),

              // Action buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Favorite button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            isFavorite ? MingCuteIcons.mgc_heart_fill : MingCuteIcons.mgc_heart_line,
                            color: isFavorite ? AppColors.error : null,
                          ),
                          label: Text(
                            isFavorite
                                ? AppStrings.removeFromFavorites
                                : AppStrings.addToFavorites,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Save to history button
                      IconButton.outlined(
                        onPressed: _saveToHistory,
                        icon: const Icon(MingCuteIcons.mgc_download_2_line),
                        tooltip: 'Save to history',
                      ),
                    ],
                  ),
                ),
              ),

              // Disclaimer
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Text(
                    AppStrings.disclaimer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
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
              style: const TextStyle(color: AppColors.textSecondary),
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
