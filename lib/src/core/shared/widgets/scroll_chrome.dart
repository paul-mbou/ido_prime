import 'package:material_ui/material_ui.dart';

/// Shared hide-on-scroll-down / show-on-scroll-up chrome behavior.
bool updateScrollChromeVisibility(
  ScrollNotification notification, {
  required bool visible,
  required ValueChanged<bool> onVisibilityChanged,
  double hideThreshold = 8,
  double showThreshold = 4,
}) {
  if (notification.metrics.axis != Axis.vertical) return false;
  if (notification is! ScrollUpdateNotification) return false;

  final delta = notification.scrollDelta;
  if (delta == null || delta == 0) return false;

  final pixels = notification.metrics.pixels;
  if (pixels <= 0) {
    if (!visible) onVisibilityChanged(true);
    return false;
  }

  if (delta > hideThreshold && visible) {
    onVisibilityChanged(false);
  } else if (delta < -showThreshold && !visible) {
    onVisibilityChanged(true);
  }
  return false;
}

enum ScrollChromeEdge { top, bottom }

/// Slides [child] off-screen when [visible] is false.
class ScrollChromeSlide extends StatelessWidget {
  const ScrollChromeSlide({
    super.key,
    required this.visible,
    required this.edge,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
  });

  final bool visible;
  final ScrollChromeEdge edge;
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final hiddenOffset = switch (edge) {
      ScrollChromeEdge.top => const Offset(0, -1),
      ScrollChromeEdge.bottom => const Offset(0, 1),
    };

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: duration,
        curve: curve,
        offset: visible ? Offset.zero : hiddenOffset,
        child: AnimatedOpacity(
          duration: duration,
          curve: curve,
          opacity: visible ? 1 : 0,
          child: child,
        ),
      ),
    );
  }
}
