import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

extension ContextExtension on BuildContext {
  // ── Theme shortcuts ──────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  TextTheme get typography => theme.textTheme;
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ── MediaQuery shortcuts ─────────────────────────────────────────────────
  Size get mediaQuerySize => View.of(this).physicalSize;
  Size get screenSize => mediaQuerySize;
  double get width => mediaQuerySize.width;
  double get height => mediaQuerySize.height;

  /// Safe-area insets for the current view.
  EdgeInsets get safeArea => MediaQuery.paddingOf(this);

  // ── Keyboard ──────────────────────────────────────────────────────────────
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;
  void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  // ── Platform ─────────────────────────────────────────────────────────────
  bool get isIOS => theme.platform == TargetPlatform.iOS;
  bool get isAndroid => theme.platform == TargetPlatform.android;

  // ── Routing ───────────────────────────────────────────────────────────────
  String get location => GoRouterState.of(this).uri.toString();

  /// Safe pop that no-ops when there is nothing to pop.
  void maybePop<T extends Object?>([T? result]) {
    final router = GoRouter.of(this);
    if (router.canPop()) {
      router.pop(result);
    }
  }

  // ── Overlays ─────────────────────────────────────────────────────────────
  void showSnackBar(
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message), action: action, duration: duration),
      );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
        ),
      );
  }

  Future<T?> showAppBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      builder: builder,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
    );
  }

  Future<T?> showAppDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      builder: builder,
      barrierDismissible: barrierDismissible,
    );
  }
}
