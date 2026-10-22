import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';

/// App bar that is **opaque at rest** and becomes **frosted glass while scrolled**.
///
/// Pass [frosted] from a scroll listener (`pixels > 0`). Pair with
/// [Scaffold.extendBodyBehindAppBar] so content can blur underneath.
class AppFrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppFrostedAppBar({
    super.key,
    this.title,
    this.leading,
    this.leadingWidth,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.titleSpacing,
    this.centerTitle,
    this.bottom,
    this.frosted = false,
    this.blurSigma = 14,

    /// Scaffold-colored glass fill — high enough to read as a bar, low enough
    /// for a soft blur of content underneath (glassmorphism).
    this.tintOpacity = 0.95,
    this.showCircleActions = false,
  });

  final Widget? title;
  final Widget? leading;
  final double? leadingWidth;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final double? titleSpacing;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;

  /// `false` → solid scaffold color; `true` → frosted glass (scroll only).
  final bool frosted;
  final double blurSigma;
  final double tintOpacity;

  /// Wraps default back / trailing icons in circular chips (post detail style).
  final bool showCircleActions;

  static const double _dividerHeight = 1;
  static const _fade = Duration(milliseconds: 0);

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0) + _dividerHeight,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final onSurface = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.colorScheme.outline.withValues(alpha: 0.45);

    // Glass fill: mostly scaffold color + slight light sheen.
    final glassTint = Color.alphaBlend(
      Colors.white.withValues(alpha: isDark ? 0.01 : 0.55),
      bg.withValues(alpha: tintOpacity),
    );

    final divider = Divider(
      height: _dividerHeight,
      thickness: _dividerHeight,
      color: dividerColor,
    );

    return AppBar(
      title: title,
      leading: leading,
      leadingWidth: leadingWidth,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      titleSpacing: titleSpacing,
      centerTitle: centerTitle ?? false,
      clipBehavior: Clip.hardEdge,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          (bottom?.preferredSize.height ?? 0) + _dividerHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [?bottom, divider],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: onSurface,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          // Solid at rest — never fades through empty/transparent.
          AnimatedOpacity(
            duration: _fade,
            opacity: frosted ? 0 : 1,
            child: ColoredBox(color: bg),
          ),
          // Frosted glass while scrolled: blur backdrop + dense tint.
          AnimatedOpacity(
            duration: _fade,
            opacity: frosted ? 1 : 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: ColoredBox(color: glassTint),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular trailing action used on post detail / feed chrome.
class AppCircleIconButton extends StatelessWidget {
  const AppCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.fill = 0,
    this.badgeCount = 0,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double fill;

  /// When > 0, shows a gold unread badge (count, or `9+`).
  final int badgeCount;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final showBadge = badgeCount > 0;
    final label = badgeCount > 9 ? '9+' : '$badgeCount';

    final button = IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: colors.surface.withValues(alpha: 0.9),
        foregroundColor: color ?? colors.onSurface,
      ),
      icon: Icon(icon, size: 20, fill: fill, color: color),
    );

    if (!showBadge) return button;

    return Badge(
      isLabelVisible: true,
      backgroundColor: AppColors.primary,
      textColor: AppColors.onPrimary,
      alignment: AlignmentDirectional.topEnd,
      // Pull inward toward the bell (default Material offset sits too far out).
      offset: const Offset(-2, 4),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      child: button,
    );
  }
}
