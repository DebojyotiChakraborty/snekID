import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/theme_provider.dart';

/// Settings screen with theme options and other settings
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        leading: IconButton(
          icon: const Icon(MingCuteIcons.mgc_arrow_left_line),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Appearance Section
          _SectionHeader(
            title: AppStrings.appearance,
            isDark: isDark,
          ),
          _SettingsTile(
            icon: MingCuteIcons.mgc_palette_line,
            title: AppStrings.theme,
            subtitle: themeMode.displayName,
            isDark: isDark,
            onTap: () => _showThemeDialog(context, ref, themeMode),
          ),

          const SizedBox(height: 24),

          // General Section
          _SectionHeader(
            title: AppStrings.general,
            isDark: isDark,
          ),
          _SettingsTile(
            icon: MingCuteIcons.mgc_presentation_2_line,
            title: AppStrings.viewOnboarding,
            subtitle: AppStrings.viewOnboardingDescription,
            isDark: isDark,
            onTap: () => _viewOnboarding(context, ref),
          ),

          const SizedBox(height: 24),

          // About Section
          _SectionHeader(
            title: AppStrings.about,
            isDark: isDark,
          ),
          _SettingsTile(
            icon: MingCuteIcons.mgc_information_line,
            title: AppStrings.appName,
            subtitle: AppStrings.appDescription,
            isDark: isDark,
            trailing: Text(
              'v1.0.0',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, AppThemeMode currentMode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(mode.displayName),
              value: mode,
              groupValue: currentMode,
              activeColor: AppColors.primary,
              onChanged: (value) {
                if (value != null) {
                  HapticFeedback.lightImpact();
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewOnboarding(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    // Ensure onboarding opens with indicator/page at index 0.
    ref.read(onboardingPageProvider.notifier).state = 0;
    await ref.read(onboardingControllerProvider.notifier).resetOnboarding();
    if (context.mounted) {
      context.go(AppRoutes.onboarding);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      trailing: trailing ?? Icon(
        MingCuteIcons.mgc_right_line,
        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
