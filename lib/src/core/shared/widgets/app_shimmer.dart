import 'package:material_ui/material_ui.dart';

/// Soft shimmer fill used as the default image / avatar loading state.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    this.borderRadius,
    this.width,
    this.height,
  });

  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  /// Circular shimmer matching [AppCachedAvatar] size.
  factory AppShimmer.circle({Key? key, required double diameter}) {
    return AppShimmer(
      key: key,
      width: diameter,
      height: diameter,
      borderRadius: BorderRadius.circular(diameter / 2),
    );
  }

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = colors.surfaceContainerHighest;
    final highlight = Color.lerp(
          base,
          colors.surface,
          0.55,
        ) ??
        colors.surface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: LinearGradient(
                begin: Alignment(-1.2 + t * 2.4, 0),
                end: Alignment(-0.2 + t * 2.4, 0),
                colors: [
                  base,
                  highlight,
                  base,
                ],
                stops: const [0.25, 0.5, 0.75],
              ),
            ),
          ),
        );
      },
    );
  }
}
