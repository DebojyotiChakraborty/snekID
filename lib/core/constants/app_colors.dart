import 'package:flutter/material.dart';

/// App color palette with support for light and dark themes
class AppColors {
  AppColors._();

  // Primary colors (same for both themes)
  static const Color primary = Color(0xFFFEEA53);
  static const Color primaryLight = Color(0xFFFFF176);
  static const Color primaryDark = Color(0xFFF9D71C);

  // Info accent color (restored green for scientific info)
  static const Color infoAccentGreen = Color(0xFF00D26A);

  // Common colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Status colors (same for both themes)
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // Danger level colors (same for both themes)
  static const Color dangerHigh = Color(0xFFF85149);
  static const Color dangerMedium = Color(0xFFD29922);
  static const Color dangerLow = Color(0xFF3FB950);
  static const Color dangerNone = Color(0xFF8B949E);

  // Onboarding colors
  static const Color onboardingGreen = Color(0xFF348833);
  static const Color onboardingIndicatorActive = Color(0xFFFEEA53);
  static const Color onboardingIndicatorInactive = Color(0xFFD9D9D9);

  // ============ DARK THEME COLORS ============
  static const Color backgroundDark = Color(0xFF020202);
  static const Color backgroundSecondaryDark = Color(
    0xFF161B22,
  ); // Can keep or update if needed, but primary bg is requested
  static const Color backgroundTertiaryDark = Color(0xFF21262D);
  static const Color surfaceDark = Color(0xFF404040); // Cards
  static const Color surfaceLightDark = Color(
    0xFF404040,
  ); // Updating to match "Cards" if used interchangeably
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB1BAC4);
  static const Color textTertiaryDark = Color(0xFF8B949E);
  static const Color textMutedDark = Color(0xFF6E7681);
  static const Color borderDark = Color(0xFF30363D);
  static const Color borderLightDark = Color(0xFF21262D);

  // ============ LIGHT THEME COLORS ============
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundSecondaryLight = Color(0xFFF6F8FA);
  static const Color backgroundTertiaryLight = Color(0xFFE8EAED);
  static const Color surfaceLight = Color(0xFFECECEC); // Cards
  static const Color surfaceLightLight = Color(
    0xFFECECEC,
  ); // Updating to match "Cards"
  static const Color textPrimaryLight = Color(0xFF1F2328);
  static const Color textSecondaryLight = Color(0xFF57606A);
  static const Color textTertiaryLight = Color(0xFF6E7781);
  static const Color textMutedLight = Color(0xFF8C959F);
  static const Color borderLight = Color(0xFFD0D7DE);
  static const Color borderLightLight = Color(0xFFE8EAED);

  // ============ LEGACY STATIC COLORS (Dark theme defaults) ============
  // These are kept for backward compatibility
  static const Color background = backgroundDark;
  static const Color backgroundSecondary = backgroundSecondaryDark;
  static const Color backgroundTertiary = backgroundTertiaryDark;
  static const Color surface = surfaceDark;
  static const Color surfaceLightColor = surfaceLightDark;
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textTertiary = textTertiaryDark;
  static const Color textMuted = textMutedDark;
  static const Color border = borderDark;
  static const Color borderLightColor = borderLightDark;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundSecondary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceLightColor, surface],
  );

  /// Onboarding gradient - green at top fading to background
  static LinearGradient onboardingGradient({bool isDark = true}) =>
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [onboardingGreen, isDark ? black : backgroundLight],
        stops: const [0.0, 0.35],
      );

  // Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
}

/// Extension to get theme-aware colors
extension ThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get backgroundSecondaryColor =>
      isDarkMode
          ? AppColors.backgroundSecondaryDark
          : AppColors.backgroundSecondaryLight;
  Color get backgroundTertiaryColor =>
      isDarkMode
          ? AppColors.backgroundTertiaryDark
          : AppColors.backgroundTertiaryLight;
  Color get surfaceColor =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get surfaceLightColor =>
      isDarkMode ? AppColors.surfaceLightDark : AppColors.surfaceLightLight;
  Color get textPrimaryColor =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondaryColor =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiaryColor =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
  Color get textMutedColor =>
      isDarkMode ? AppColors.textMutedDark : AppColors.textMutedLight;
  Color get borderColor =>
      isDarkMode ? AppColors.borderDark : AppColors.borderLight;
  Color get borderLightColor =>
      isDarkMode ? AppColors.borderLightDark : AppColors.borderLightLight;
}
