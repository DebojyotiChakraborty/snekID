import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _onboardingKey = 'onboarding_completed';
const String _introPromptKey = 'intro_prompt_shown';

/// Provider to check if onboarding has been completed
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardingKey) ?? false;
});

/// Provider to check if intro prompt has been shown
final introPromptShownProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_introPromptKey) ?? false;
});

/// Provider to mark intro prompt as shown
final introPromptControllerProvider =
    StateNotifierProvider<IntroPromptController, AsyncValue<bool>>((ref) {
      return IntroPromptController();
    });

class IntroPromptController extends StateNotifier<AsyncValue<bool>> {
  IntroPromptController() : super(const AsyncValue.data(false));

  Future<void> markShown() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_introPromptKey, true);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider to manage onboarding state
final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, AsyncValue<bool>>((ref) {
      return OnboardingController(ref);
    });

/// Controller for onboarding state
class OnboardingController extends StateNotifier<AsyncValue<bool>> {
  final Ref _ref;

  OnboardingController(this._ref) : super(const AsyncValue.data(false));

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
      state = const AsyncValue.data(true);
      _ref.invalidate(onboardingCompletedProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reset onboarding (for testing purposes)
  Future<void> resetOnboarding() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, false);
      state = const AsyncValue.data(false);
      _ref.invalidate(onboardingCompletedProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for the current onboarding page index
final onboardingPageProvider = StateProvider<int>((ref) => 0);
