import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/analysis_history.dart';
import '../../data/models/snake_identification.dart';
import '../../providers/history_provider.dart';

/// History screen showing past analyses and favorites
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onClose() {
    context.pop();
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          AppStrings.clearHistory,
          style: TextStyle(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          AppStrings.clearHistoryConfirm,
          style: TextStyle(
            color: context.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: context.textTertiaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearHistory();
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            child: const Text(
              AppStrings.clear,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          AppStrings.clearFavorites,
          style: TextStyle(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          AppStrings.clearFavoritesConfirm,
          style: TextStyle(
            color: context.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: context.textTertiaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(favoritesProvider.notifier).clearFavorites();
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            child: const Text(
              AppStrings.clear,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToResult(String? jsonString, String? imagePath) {
    if (jsonString == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Details not available for this item'),
          backgroundColor: AppColors.textMuted,
        ),
      );
      return;
    }
    
    try {
      final jsonMap = jsonDecode(jsonString);
      final identification = SnakeIdentification.fromJson(jsonMap);
      final imageFile = imagePath != null ? File(imagePath) : null;
      
      context.pushNamed(
        'results',
        extra: {
          'identification': identification,
          'imageFile': imageFile,
        },
      );
    } catch (e) {
      debugPrint('Error parsing history item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error opening details'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            MingCuteIcons.mgc_arrow_left_line,
            color: context.textPrimaryColor,
          ),
          onPressed: _onClose,
        ),
        title: Text(
          AppStrings.history,
          style: TextStyle(
            color: context.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              final isHistoryTab = _tabController.index == 0;
              final hasItems = isHistoryTab ? history.isNotEmpty : favorites.isNotEmpty;
              
              if (!hasItems) return const SizedBox.shrink();
              
              return IconButton(
                icon: Icon(
                  MingCuteIcons.mgc_delete_2_line,
                  color: AppColors.error,
                ),
                onPressed: isHistoryTab ? _clearHistory : _clearFavorites,
                tooltip: isHistoryTab ? AppStrings.clearHistory : AppStrings.clearFavorites,
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.isDarkMode 
                  ? context.surfaceLightColor 
                  : context.backgroundTertiaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: context.textPrimaryColor,
              unselectedLabelColor: context.textTertiaryColor,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(MingCuteIcons.mgc_time_line, size: 18),
                      const SizedBox(width: 6),
                      Text(AppStrings.recentAnalyses),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(MingCuteIcons.mgc_star_line, size: 18),
                      const SizedBox(width: 6),
                      Text(AppStrings.favorites),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // History tab
          _HistoryList(
            history: history,
            onDelete: (id) {
              HapticFeedback.mediumImpact();
              ref.read(historyProvider.notifier).deleteAnalysis(id);
            },
            onTap: (item) => _navigateToResult(item.fullResultJson, item.imagePath),
          ),
          // Favorites tab
          _FavoritesList(
            favorites: favorites,
            onDelete: (id) {
              HapticFeedback.mediumImpact();
              ref.read(favoritesProvider.notifier).removeFavorite(id);
            },
            onTap: (item) => _navigateToResult(item.fullResultJson, item.imagePath),
          ),
        ],
      ),
    );
  }
}

/// History list widget
class _HistoryList extends StatelessWidget {
  final List<AnalysisHistory> history;
  final Function(String) onDelete;
  final Function(AnalysisHistory) onTap;

  const _HistoryList({
    required this.history,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return _EmptyState(
        icon: MingCuteIcons.mgc_time_line,
        title: AppStrings.noHistoryYet,
        subtitle: AppStrings.noHistoryDescription,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HistoryCard(
            item: item,
            onDelete: () => onDelete(item.id),
            onTap: () => onTap(item),
          ),
        );
      },
    );
  }
}

/// Single history card
class _HistoryCard extends StatelessWidget {
  final AnalysisHistory item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.item,
    required this.onDelete,
    required this.onTap,
  });

  Color _getDangerColor() {
    final level = item.dangerLevel.toLowerCase();
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
    return GestureDetector(
      onTap: onTap,
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            MingCuteIcons.mgc_delete_2_line,
            color: AppColors.white,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: _buildImage(),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.commonName,
                        style: TextStyle(
                          color: context.textPrimaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.scientificName,
                        style: TextStyle(
                          color: context.textTertiaryColor,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Danger badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getDangerColor().withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _getDangerColor().withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              item.dangerLevel,
                              style: TextStyle(
                                color: _getDangerColor(),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Confidence
                          Text(
                            item.confidencePercentage,
                            style: TextStyle(
                              color: context.textTertiaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          // Date
                          Text(
                            item.formattedDate,
                            style: TextStyle(
                              color: context.textMutedColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final file = File(item.imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceDark,
      child: const Center(
        child: Icon(
          MingCuteIcons.mgc_pic_line,
          color: AppColors.textMuted,
          size: 32,
        ),
      ),
    );
  }
}

/// Favorites list widget
class _FavoritesList extends StatelessWidget {
  final List<FavoriteSnake> favorites;
  final Function(String) onDelete;
  final Function(FavoriteSnake) onTap;

  const _FavoritesList({
    required this.favorites,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return _EmptyState(
        icon: MingCuteIcons.mgc_star_line,
        title: AppStrings.noFavoritesYet,
        subtitle: AppStrings.noFavoritesDescription,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final item = favorites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FavoriteCard(
            item: item,
            onDelete: () => onDelete(item.id),
            onTap: () => onTap(item),
          ),
        );
      },
    );
  }
}

/// Single favorite card
class _FavoriteCard extends StatelessWidget {
  final FavoriteSnake item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _FavoriteCard({
    required this.item,
    required this.onDelete,
    required this.onTap,
  });

  Color _getDangerColor() {
    final level = item.dangerLevel.toLowerCase();
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
    return GestureDetector(
      onTap: onTap,
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            MingCuteIcons.mgc_delete_2_line,
            color: AppColors.white,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Heart icon with gradient background
              Container(
                width: 90,
                height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.error.withValues(alpha: 0.2),
                    AppColors.error.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: item.imagePath != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      child: _buildImage(item.imagePath!),
                    )
                  : const Center(
                      child: Icon(
                        MingCuteIcons.mgc_star_fill,
                        color: AppColors.error,
                        size: 36,
                      ),
                    ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.commonName,
                      style: TextStyle(
                        color: context.textPrimaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.scientificName,
                      style: TextStyle(
                        color: context.textTertiaryColor,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.snakeType,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Danger badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getDangerColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getDangerColor().withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            item.dangerLevel,
                            style: TextStyle(
                              color: _getDangerColor(),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Date
                        Text(
                          item.formattedDate,
                          style: TextStyle(
                            color: context.textMutedColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildImage(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceDark,
      child: const Center(
        child: Icon(
          MingCuteIcons.mgc_star_fill,
          color: AppColors.error,
          size: 36,
        ),
      ),
    );
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.surfaceLightColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: context.textMutedColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: context.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: context.textTertiaryColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
