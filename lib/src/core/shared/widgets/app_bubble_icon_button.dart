import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Icon button with no Material splash — plays a soft bubble + scale pop
/// (YouTube / Instagram style) on tap.
class AppBubbleIconButton extends HookWidget {
  const AppBubbleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.size = 22,
    this.fill = 0,
    this.bubbleColor,
    this.label,
    this.labelColor,
    this.labelStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;
  final double fill;
  final Color? bubbleColor;
  final String? label;
  final Color? labelColor;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 480),
    );

    final scale = useMemoized(
      () => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(
            begin: 1.0,
            end: 0.72,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 18,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 0.72,
            end: 1.32,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 38,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 1.32,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 44,
        ),
      ]).animate(controller),
      [controller],
    );

    final bubbleScale = useMemoized(
      () => Tween<double>(
        begin: 0.35,
        end: 2.05,
      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(controller),
      [controller],
    );

    final bubbleOpacity = useMemoized(
      () => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.4),
          weight: 12,
        ),
        TweenSequenceItem(
          tween: Tween(
            begin: 0.4,
            end: 0.0,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 88,
        ),
      ]).animate(controller),
      [controller],
    );

    void handleTap() {
      onPressed();
      controller.forward(from: 0);
    }

    final resolvedBubble = bubbleColor ?? color;
    final hitExtent = size + 14;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handleTap,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: hitExtent,
              height: hitExtent,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  FadeTransition(
                    opacity: bubbleOpacity,
                    child: ScaleTransition(
                      scale: bubbleScale,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: resolvedBubble.withValues(alpha: 0.38),
                        ),
                        child: SizedBox(width: size, height: size),
                      ),
                    ),
                  ),
                  ScaleTransition(
                    scale: scale,
                    child: Icon(
                      icon,
                      size: size,
                      color: color,
                      fill: fill,
                    ),
                  ),
                ],
              ),
            ),
            if (label != null) ...[
              const Gutter.custom(size: 6),
              Text(
                label!,
                style:
                    labelStyle ??
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
