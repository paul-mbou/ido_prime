import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/profile/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _autoplayKey = 'ido_app_autoplay_videos';
  static const _reduceDataKey = 'ido_app_reduce_data';
  static const _hapticKey = 'ido_app_haptic_feedback';

  @override
  AppSettings build() {
    Future.microtask(_hydrate);
    return const AppSettings();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final next = AppSettings(
      autoplayVideos: prefs.getBool(_autoplayKey) ?? true,
      reduceDataUsage: prefs.getBool(_reduceDataKey) ?? false,
      hapticFeedback: prefs.getBool(_hapticKey) ?? true,
    );
    if (next.autoplayVideos == state.autoplayVideos &&
        next.reduceDataUsage == state.reduceDataUsage &&
        next.hapticFeedback == state.hapticFeedback) {
      return;
    }
    state = next;
  }

  Future<void> setAutoplayVideos(bool value) async {
    state = state.copyWith(autoplayVideos: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoplayKey, value);
  }

  Future<void> setReduceDataUsage(bool value) async {
    state = state.copyWith(reduceDataUsage: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reduceDataKey, value);
  }

  Future<void> setHapticFeedback(bool value) async {
    state = state.copyWith(hapticFeedback: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, value);
  }
}
