import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';

/// Shows a dialog with a soft scrim; content should use [AppGlassDialog].
Future<T?> showAppGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Frosted glass panel with primary-colored border for dialogs / modals.
class AppGlassDialog extends StatelessWidget {
  const AppGlassDialog({
    super.key,
    this.title,
    this.child,
    this.actions,
    this.insetPadding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 24,
    ),
  });

  final Widget? title;
  final Widget? child;
  final List<Widget>? actions;
  final EdgeInsets insetPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: insetPadding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: isDark ? 0.72 : 0.82),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.75),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) ...[
                    DefaultTextStyle(
                      style: theme.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      child: title!,
                    ),
                    const Gutter(),
                  ],
                  ?child,
                  if (actions != null && actions!.isNotEmpty) ...[
                    const Gutter(),
                    // Theme CTAs use min width infinity; dialog rows need intrinsic width.
                    FilledButtonTheme(
                      data: FilledButtonThemeData(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(88, 44),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      child: OutlinedButtonTheme(
                        data: OutlinedButtonThemeData(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(88, 44),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            for (var i = 0; i < actions!.length; i++) ...[
                              if (i > 0) const GutterSmall(),
                              Flexible(child: actions![i]),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
