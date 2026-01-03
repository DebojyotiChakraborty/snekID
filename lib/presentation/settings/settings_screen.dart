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
import '../common/widgets/animated_dialog.dart';
import '../common/widgets/cupertino_card.dart';

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
          icon: Icon(
            MingCuteIcons.mgc_left_line,
            color: context.textPrimaryColor,
          ),
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
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Developer Section
          _SettingsGroup(
            title: 'DEVELOPER',
            children: const [_DeveloperCard()],
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
  ) {
    final options = AppThemeMode.values.map((m) => m.displayName).toList();
    final selectedIndex = AppThemeMode.values.indexOf(currentMode);

    ThemePickerDialog.show(
      context,
      options: options,
      selectedIndex: selectedIndex,
      onSelected: (index) {
        HapticFeedback.lightImpact();
        ref
            .read(themeModeProvider.notifier)
            .setThemeMode(AppThemeMode.values[index]);
      },
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

  const _SettingsGroup({required this.title, required this.children});

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
        Material(
          color: context.surfaceColor,
          shape: const SquircleBorder(
            radius: BorderRadius.all(Radius.circular(40)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
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

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon without colored box
              Icon(icon, color: context.textPrimaryColor, size: 24),
              const SizedBox(width: 16),

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
                color: context.textTertiaryColor.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Developer card showing app creator info
class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // "Built with" heading
          Text(
            'Built with',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Icons row: love & Flutter in India
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Love icon
              _buildIconWithLabel(
                context,
                'assets/images/ui_illustrations/love.png',
                'love',
              ),
              const SizedBox(width: 20),

              Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  '&',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textTertiaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Flutter logo
              _buildIconWithLabel(
                context,
                'assets/images/ui_illustrations/flutter_logo.png',
                'Flutter',
              ),
              const SizedBox(width: 20),

              Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'in',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textTertiaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // India flag
              _buildIconWithLabel(
                context,
                'assets/images/ui_illustrations/india_flag.png',
                'India',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // "by" text
          Text(
            'by',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),

          // Developer profile image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage(
                  'assets/images/ui_illustrations/dev_profile.png',
                ),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Developer name
          Text(
            'Debojyoti Chakraborty',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 2),

          // Developer handle
          Text(
            '(pseudo_maverick)',
            style: TextStyle(fontSize: 12, color: context.textTertiaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithLabel(
    BuildContext context,
    String assetPath,
    String label,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(assetPath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.textTertiaryColor),
        ),
      ],
    );
  }
}
