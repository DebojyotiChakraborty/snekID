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

/// Settings screen with iOS-style design
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.settings,
          style: TextStyle(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(MingCuteIcons.mgc_arrow_left_line, color: context.textPrimaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _SettingsGroup(
            title: AppStrings.appearance.toUpperCase(),
            children: [
              _SettingsTile(
                icon: MingCuteIcons.mgc_palette_line,
                title: AppStrings.theme,
                value: themeMode.displayName,
                onTap: () => _showThemeDialog(context, ref, themeMode),
                isFirst: true,
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // General Section
          _SettingsGroup(
            title: AppStrings.general.toUpperCase(),
            children: [
              _SettingsTile(
                icon: MingCuteIcons.mgc_presentation_2_line,
                title: AppStrings.viewOnboarding,
                onTap: () => _viewOnboarding(context, ref),
                isFirst: true,
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _SettingsGroup(
            title: AppStrings.about.toUpperCase(),
            children: [
              _SettingsTile(
                icon: MingCuteIcons.mgc_information_line,
                title: AppStrings.appName,
                value: 'v1.0.0',
                isFirst: true,
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, AppThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppStrings.theme,
          style: TextStyle(color: context.textPrimaryColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(
                mode.displayName,
                style: TextStyle(color: context.textPrimaryColor),
              ),
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
              style: TextStyle(color: context.textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewOnboarding(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    ref.read(onboardingPageProvider.notifier).state = 0;
    await ref.read(onboardingControllerProvider.notifier).resetOnboarding();
    if (context.mounted) {
      context.go(AppRoutes.onboarding);
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.textSecondaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(10) : Radius.zero,
          bottom: isLast ? const Radius.circular(10) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimaryColor,
                  ),
                ),
              ),
              
              // Value
              if (value != null) ...[
                Text(
                  value!,
                  style: TextStyle(
                    fontSize: 15,
                    color: context.textTertiaryColor,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              
              // Chevron
              Icon(
                MingCuteIcons.mgc_right_line,
                color: context.textTertiaryColor.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
