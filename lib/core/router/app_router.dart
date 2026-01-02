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
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.capture,
        name: 'capture',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CaptureScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.analysis,
        name: 'analysis',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AnalysisScreen(
              imageFile: extra?['imageFile'],
            ),
            // Fade transition allows Hero to fly visually
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResultsScreen(
              identification: extra?['identification'],
              imageFile: extra?['imageFile'],
              isNewAnalysis: extra?['isNewAnalysis'] ?? false,
            ),
            // Fade transition allows Hero to fly visually from Analysis to Results Header
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HistoryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri}'),
        ),
      ),
    ),
  );
});
