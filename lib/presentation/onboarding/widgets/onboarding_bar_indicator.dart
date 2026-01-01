import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Custom bar indicator for onboarding pages
/// Shows horizontal bars with active state in gold/yellow color
class OnboardingBarIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double barWidth;
  final double barHeight;
  final double spacing;

  const OnboardingBarIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.barWidth = 60,
    this.barHeight = 4,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(barHeight / 2),
            color: isActive
                ? AppColors.onboardingIndicatorActive
                : AppColors.onboardingIndicatorInactive,
          ),
        );
      }),
    );
  }
}
