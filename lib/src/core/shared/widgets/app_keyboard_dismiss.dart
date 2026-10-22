import 'package:material_ui/material_ui.dart';

/// Tap anywhere (outside focused fields) to dismiss the keyboard.
///
/// Prefer wrapping screen bodies or the [MaterialApp] `builder` child so
/// unfocus works even when the tap lands on empty scaffold space.
class AppKeyboardDismiss extends StatelessWidget {
  const AppKeyboardDismiss({super.key, required this.child});

  final Widget child;

  static void hide(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hide(context),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
