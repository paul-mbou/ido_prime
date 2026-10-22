import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Floating stadium bottom nav with a sliding selection pill.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double pillHeight = 64;
  static const double bottomGap = 12;
  static const double sideInset = 20;

  /// Space the FAB / content should clear above the floating nav.
  static double clearance(BuildContext context) =>
      pillHeight + bottomGap + MediaQuery.paddingOf(context).bottom;

  /// Idle = outline; selected = filled / denser Lucide glyph.
  static const _items = <({IconData idle, IconData active, String label})>[
    (idle: LucideIcons.home, active: LucideIcons.house, label: 'Feed'),
    (
      idle: LucideIcons.calendar,
      active: LucideIcons.calendarDays,
      label: 'Events',
    ),
    (
      idle: LucideIcons.store,
      active: LucideIcons.shoppingBag,
      label: 'Vendors',
    ),
    (
      idle: LucideIcons.lightbulb,
      active: LucideIcons.sparkles,
      label: 'Inspiration',
    ),
  ];

  static const _itemCount = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final selected = currentIndex.clamp(0, _itemCount - 1);

    // Equal-width slots → Alignment.x from -1 (first) to 1 (last).
    final indicatorAlign = Alignment(
      _itemCount == 1 ? 0 : -1 + (selected / (_itemCount - 1)) * 2,
      0,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sideInset,
        0,
        sideInset,
        bottomGap + safeBottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: isDark ? 0.78 : 0.88),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: colors.outline.withValues(alpha: isDark ? 0.45 : 0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              height: pillHeight,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      alignment: indicatorAlign,
                      child: FractionallySizedBox(
                        widthFactor: 1 / _itemCount,
                        heightFactor: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colors.primary.withValues(alpha: 0.28),
                                  colors.primary.withValues(alpha: 0.14),
                                ],
                              ),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < _items.length; i++)
                          Expanded(
                            child: _NavItem(
                              idleIcon: _items[i].idle,
                              activeIcon: _items[i].active,
                              label: _items[i].label,
                              selected: selected == i,
                              onTap: () => onTap(i),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.idleIcon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData idleIcon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _iconSize = 26.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final color = selected ? colors.primary : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          splashColor: colors.primary.withValues(alpha: 0.1),
          highlightColor: colors.primary.withValues(alpha: 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.86,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    selected ? activeIcon : idleIcon,
                    key: ValueKey<bool>(selected),
                    color: color,
                    size: _iconSize,
                    fill: selected ? 1 : 0,
                    weight: selected ? 700 : 400,
                  ),
                ),
              ),
              const Gutter.custom(size: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                style: (theme.textTheme.labelSmall ?? const TextStyle())
                    .copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 10,
                      height: 1.1,
                    ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
