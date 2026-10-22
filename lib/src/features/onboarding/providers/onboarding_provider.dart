import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _onboardingKey = 'ido_onboarding_completed_v1';

/// Whether the first-run product tour has been completed.
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardingKey) ?? false;
});

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingController(ref);
});

class OnboardingController {
  OnboardingController(this._ref);

  final Ref _ref;

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    _ref.invalidate(onboardingCompletedProvider);
  }

  /// Dev / settings helper — show onboarding again on next launch.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    _ref.invalidate(onboardingCompletedProvider);
  }
}
