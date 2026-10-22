import 'package:flutter/cupertino.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/shared/widgets/app_keyboard_dismiss.dart';

/// Page shell with a [CustomScrollView] that accepts normal box widgets
/// **or** real slivers — no need to remember [SliverToBoxAdapter].
///
/// ```dart
/// // Simple page
/// AppRootLayout(child: Column(children: [...]))
///
/// // Mix boxes + slivers
/// AppRootLayout(
///   children: [
///     Header(),
///     SliverList(...), // already a sliver → kept as-is
///     Footer(),
///   ],
/// )
///
/// // Push content to fill the viewport (e.g. footer at bottom)
/// AppRootLayout(
///   fillRemaining: true,
///   child: Column(
///     mainAxisAlignment: MainAxisAlignment.spaceBetween,
///     children: [body, footer],
///   ),
/// )
/// ```
///
/// For a custom/third-party sliver that isn't detected, wrap it:
/// `AppRawSliver(MyCustomSliver(...))`.
class AppRootLayout extends StatelessWidget {
  const AppRootLayout({
    super.key,
    this.child,
    this.children,
    this.fillRemaining = false,
    this.physics,
    this.padding,
    this.safeArea = true,
    this.safeAreaTop = true,
    this.unfocusOnTap = true,

    /// When the scaffold uses a frosted [AppBar] with
    /// [Scaffold.extendBodyBehindAppBar], pad content so it starts below the
    /// bar but can scroll underneath it.
    this.extendUnderAppBar = false,
  }) : assert(
         (child != null) ^ (children != null),
         'Provide exactly one of: child, or children.',
       );

  /// Single box (or sliver) body.
  final Widget? child;

  /// Mixed list of box widgets and/or slivers.
  final List<Widget>? children;

  /// Wraps a single [child] in [SliverFillRemaining] so
  /// [MainAxisAlignment.spaceBetween] / bottom footers work.
  final bool fillRemaining;

  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;
  final bool safeAreaTop;
  final bool unfocusOnTap;
  final bool extendUnderAppBar;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveSlivers();
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final resolvedPadding = _resolvePadding(context, viewPadding);

    final content = CustomScrollView(
      physics: physics,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: resolvedPadding,
          sliver: SliverMainAxisGroup(slivers: resolved),
        ),
      ],
    );

    Widget result = content;
    if (unfocusOnTap) {
      result = AppKeyboardDismiss(child: result);
    }
    if (safeArea) {
      result = SafeArea(top: safeAreaTop && !extendUnderAppBar, child: result);
    }
    return result;
  }

  EdgeInsets _resolvePadding(BuildContext context, EdgeInsets viewPadding) {
    final base = padding ?? EdgeInsets.symmetric(horizontal: context.gutter);
    final resolved = base.resolve(Directionality.of(context));
    if (!extendUnderAppBar) return resolved;
    // Status bar + toolbar + divider; prefer viewPadding (padding is often 0
    // under Scaffold.extendBodyBehindAppBar).
    final topInset = viewPadding.top > 0
        ? viewPadding.top
        : MediaQuery.paddingOf(context).top;
    // Flush under frosted app bar (toolbar + thin divider, minimal air).
    return resolved.copyWith(
      top: resolved.top + topInset + kToolbarHeight - 28,
    );
  }

  List<Widget> _resolveSlivers() {
    final items = children ?? [child!];
    if (items.length == 1 && fillRemaining) {
      final only = items.first;
      if (_isSliver(only)) return [only];
      return [SliverFillRemaining(hasScrollBody: false, child: only)];
    }
    return items.map(_asSliver).toList(growable: false);
  }

  static Widget _asSliver(Widget widget) {
    if (widget is AppRawSliver) return widget.sliver;
    if (_isSliver(widget)) return widget;
    return SliverToBoxAdapter(child: widget);
  }

  /// Detects Flutter / Cupertino slivers so they aren't double-wrapped.
  static bool _isSliver(Widget widget) {
    return widget is SliverToBoxAdapter ||
        widget is SliverFillRemaining ||
        widget is SliverList ||
        widget is SliverGrid ||
        widget is SliverFixedExtentList ||
        widget is SliverPrototypeExtentList ||
        widget is SliverAnimatedList ||
        widget is SliverReorderableList ||
        widget is SliverPadding ||
        widget is SliverAppBar ||
        widget is SliverPersistentHeader ||
        widget is SliverSafeArea ||
        widget is SliverOpacity ||
        widget is SliverIgnorePointer ||
        widget is SliverOffstage ||
        widget is SliverVisibility ||
        widget is SliverFadeTransition ||
        widget is SliverAnimatedOpacity ||
        widget is SliverMainAxisGroup ||
        widget is SliverCrossAxisGroup ||
        widget is SliverConstrainedCrossAxis ||
        widget is SliverCrossAxisExpanded ||
        widget is SliverOverlapAbsorber ||
        widget is SliverOverlapInjector ||
        widget is CupertinoSliverRefreshControl ||
        widget is CupertinoSliverNavigationBar ||
        widget is AppRawSliver;
  }
}

/// Escape hatch for custom / third-party slivers not listed in [_isSliver].
class AppRawSliver extends StatelessWidget {
  const AppRawSliver(this.sliver, {super.key});

  final Widget sliver;

  @override
  Widget build(BuildContext context) => sliver;
}
