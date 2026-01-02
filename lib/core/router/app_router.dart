import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/capture/capture_screen.dart';
import '../../presentation/results/results_screen.dart';
import '../../presentation/results/analysis_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/history/history_screen.dart';
import '../../providers/onboarding_provider.dart';

/// App route paths
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String capture = '/capture';
  static const String analysis = '/analysis';
  static const String results = '/results';
  static const String settings = '/settings';
  static const String history = '/history';
}

/// Reusable page transition builders for consistent animations
class PageTransitions {
  PageTransitions._();

  static const Duration _duration = Duration(milliseconds: 350);
  static const Curve _curve = Curves.easeOutCubic;
  static const Curve _reverseCurve = Curves.easeInCubic;

  /// Fade transition (for main content screens)
  static CustomTransitionPage<T> fade<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Slide from right (for push navigation like settings)
  static CustomTransitionPage<T> slideFromRight<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: _curve,
              reverseCurve: _reverseCurve,
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Slide from left (for screens accessed from left side like history)
  static CustomTransitionPage<T> slideFromLeft<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: _curve,
              reverseCurve: _reverseCurve,
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Slide from bottom (for modal-style screens)
  static CustomTransitionPage<T> slideFromBottom<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: _duration,
      reverseTransitionDuration: _duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutExpo,
              reverseCurve: Curves.easeInExpo,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    initialLocation: onboardingCompleted.maybeWhen(
      data: (completed) => completed ? AppRoutes.capture : AppRoutes.onboarding,
      orElse: () => AppRoutes.onboarding,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder:
            (context, state) => PageTransitions.fade(
              key: state.pageKey,
              child: const OnboardingScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.capture,
        name: 'capture',
        pageBuilder:
            (context, state) => PageTransitions.fade(
              key: state.pageKey,
              child: const CaptureScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.analysis,
        name: 'analysis',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          // Use a custom slower fade for Hero-compatible smooth transition
          return CustomTransitionPage(
            key: state.pageKey,
            child: AnalysisScreen(imageFile: extra?['imageFile']),
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PageTransitions.slideFromBottom(
            key: state.pageKey,
            child: ResultsScreen(
              identification: extra?['identification'],
              imageFile: extra?['imageFile'],
              isNewAnalysis: extra?['isNewAnalysis'] ?? false,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder:
            (context, state) => PageTransitions.slideFromBottom(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        pageBuilder:
            (context, state) => PageTransitions.slideFromBottom(
              key: state.pageKey,
              child: const HistoryScreen(),
            ),
      ),
    ],
    errorPageBuilder:
        (context, state) => MaterialPage(
          child: Scaffold(
            body: Center(child: Text('Page not found: ${state.uri}')),
          ),
        ),
  );
});
