import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Single onboarding page content with image
class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.onboardingTitle(context),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 12),
            // Subtitle
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTheme.onboardingSubtitle(context),
            ),
          ],

          const SizedBox(height: 40),

          // Image
          Expanded(flex: 4, child: Image.asset(imagePath, fit: BoxFit.contain)),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
