import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/onboarding_provider.dart';
import '../common/widgets/haptic_button.dart';
import '../common/widgets/page_transition.dart';
import 'widgets/onboarding_bar_indicator.dart';
import 'widgets/onboarding_page.dart';

/// Onboarding screen with 3 pages
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  static const int _totalPages = 3;

  // Onboarding image paths
  static const List<String> _imagePaths = [
    'assets/images/onboarding_images/onboarding_image_1.png',
    'assets/images/onboarding_images/onboarding_image_2.png',
    'assets/images/onboarding_images/onboarding_image_3.png',
  ];

  @override
  void initState() {
    super.initState();
    // Keep page view and indicator in sync even if we navigate back into
    // onboarding from somewhere else (e.g. Settings -> View onboarding).
    final initialPage = ref.read(onboardingPageProvider);
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    final currentPage = ref.read(onboardingPageProvider);
    if (currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.capture);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(onboardingPageProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Content
      body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(onboardingPageProvider.notifier).state = index;
                },
                children: [
                  PageTransition(
                    isActive: currentPage == 0,
                    child: OnboardingPage(
                      imagePath: _imagePaths[0],
                      title: AppStrings.onboardingTitle1,
                      subtitle: AppStrings.onboardingSubtitle1,
                    ),
                  ),
                  PageTransition(
                    isActive: currentPage == 1,
                    child: OnboardingPage(
                      imagePath: _imagePaths[1],
                      title: AppStrings.onboardingTitle2,
                      subtitle: AppStrings.onboardingSubtitle2,
                    ),
                  ),
                  PageTransition(
                    isActive: currentPage == 2,
                    child: OnboardingPage(
                      imagePath: _imagePaths[2],
                      title: AppStrings.onboardingTitle3,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // Next/Continue button
                  HapticButton(
                    onPressed: _onNextPressed,
                    backgroundColor: const Color(0xFFFEEA53),
                    showGlow: true,
                    child: Text(
                      currentPage == _totalPages - 1
                          ? AppStrings.continueText
                          : AppStrings.next,
                      style: AppTheme.buttonText,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bar indicators at the bottom
                  OnboardingBarIndicator(
                    currentPage: currentPage,
                    totalPages: _totalPages,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
