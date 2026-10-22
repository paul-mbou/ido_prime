import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/theme/app_visual_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appVisualStyleProvider =
    NotifierProvider<AppVisualStyleNotifier, AppVisualStyle>(
      AppVisualStyleNotifier.new,
    );

class AppVisualStyleNotifier extends Notifier<AppVisualStyle> {
  static const _prefsKey = 'app_visual_style';

  @override
  AppVisualStyle build() {
    Future.microtask(_hydrate);
    return AppVisualStyle.dark;
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;

    final style = switch (raw) {
      'light' => AppVisualStyle.light,
      // Legacy purple / forest map to dark.
      'dark' || 'purple' || 'forest' => AppVisualStyle.dark,
      _ => null,
    };
    if (style == null || state == style) return;
    state = style;
  } 

  Future<void> setStyle(AppVisualStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, style.name);
  }
}
