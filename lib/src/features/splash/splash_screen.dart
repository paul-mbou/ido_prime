import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widget_previews.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/generated/assets.gen.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/core/theme/app_theme.dart';
import 'package:ido_prime/src/features/onboarding/providers/onboarding_provider.dart';
import 'package:material_ui/material_ui.dart';

// ── Flutter / Cursor Widget Previewer ───────────────────────────────────────

/// Applies [AppTheme] light/dark based on preview brightness.
final class _SplashPreviewThemeData extends PreviewThemeData {
  const _SplashPreviewThemeData();

  @override
  Widget apply(BuildContext context, Widget child) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return Theme(
      data: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
      child: child,
    );
  }
}

PreviewThemeData splashPreviewTheme() => const _SplashPreviewThemeData();

Widget splashPreviewWrapper(Widget child) => ProviderScope(child: child);

@Preview(
  name: 'Splash · Dark',
  group: 'Splash',
  brightness: Brightness.dark,
  size: Size(390, 844),
  theme: splashPreviewTheme,
  wrapper: splashPreviewWrapper,
)
Widget splashPreviewDark() => const SplashScreen(autoNavigate: false);

@Preview(
  name: 'Splash · Light',
  group: 'Splash',
  brightness: Brightness.light,
  size: Size(390, 844),
  theme: splashPreviewTheme,
  wrapper: splashPreviewWrapper,
)
Widget splashPreviewLight() => const SplashScreen(autoNavigate: false);

/// Brand moment before auth / shell — calm gold on deep purple lifestyle mood.
class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key, this.autoNavigate = true});

  /// When false (widget preview), play entrance motion but skip routing.
  final bool autoNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1600),
    );

    final logoFade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    final logoScale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    final tagFade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    );

    // Splash-only: Fraunces — soft celebration display (app body stays DM Sans).
    final taglineStyle = GoogleFonts.fraunces(
      fontWeight: FontWeight.w500,
      fontSize: 20,
      letterSpacing: 0.15,
      height: 1.25,
      color: AppColors.primary,
      fontStyle: FontStyle.italic,
    );
    final metaStyle = GoogleFonts.fraunces(
      fontWeight: FontWeight.w400,
      fontSize: 12.5,
      letterSpacing: 1.1,
      height: 1.35,
      color: colors.onSurfaceVariant,
    );

    useEffect(() {
      if (reduceMotion) {
        controller.value = 1;
      } else {
        unawaited(controller.forward());
      }

      if (!autoNavigate) return null;

      var cancelled = false;
      Future<void>(() async {
        await Future<void>.delayed(
          Duration(milliseconds: reduceMotion ? 400 : 2300),
        );
        if (cancelled || !context.mounted) return;
        if (GoRouter.maybeOf(context) == null) return;

        var onboardingDone = false;
        try {
          onboardingDone = await ref.read(onboardingCompletedProvider.future);
        } catch (_) {}
        if (cancelled || !context.mounted) return;

        if (!onboardingDone) {
          context.go(AppRoutes.onboarding);
        } else {
          // Guests land on the main feed; auth is optional.
          context.go(AppRoutes.posts);
        }
      });

      return () => cancelled = true;
    }, [autoNavigate]);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _SplashAtmosphere(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.gutter * 1.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: logoFade,
                      child: ScaleTransition(
                        scale: logoScale,
                        child: Assets.svgs.idoLogo.svg(
                          width: context.width * 0.09,
                          height: context.width * 0.09,
                        ),
                      ),
                    ),

                    const Gutter(),
                    FadeTransition(
                      opacity: tagFade,
                      child: Column(
                        children: [
                          Text(
                            'Celebrate beautifully',
                            textAlign: TextAlign.center,
                            style: taglineStyle,
                          ),
                          const GutterTiny(),
                          Text(
                            'Plan · Discover · Inspire · Share',
                            textAlign: TextAlign.center,
                            style: metaStyle,
                          ),
                        ],
                      ),
                    ),
                    const GutterExtraLarge(),
                    FadeTransition(
                      opacity: tagFade,
                      child: const _SplashProgressIndicator(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashAtmosphere extends StatelessWidget {
  const _SplashAtmosphere();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.darkBackground,
                        const Color(0xFF241939),
                        AppColors.darkBackground,
                      ]
                    : [
                        AppColors.lightBackground,
                        AppColors.lightPrimaryContainer.withValues(alpha: 0.55),
                        AppColors.lightBackground,
                      ],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -60,
            child: _Orb(
              size: 220,
              color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.18),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: _Orb(
              size: 260,
              color: colors.secondary.withValues(alpha: isDark ? 0.18 : 0.12),
            ),
          ),
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.35,
            left: -40,
            child: _Orb(
              size: 120,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft gold ring loader — rounded-cap arc that turns continuously.
class _SplashProgressIndicator extends StatefulWidget {
  const _SplashProgressIndicator();

  @override
  State<_SplashProgressIndicator> createState() =>
      _SplashProgressIndicatorState();
}

class _SplashProgressIndicatorState extends State<_SplashProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          strokeCap: StrokeCap.round,
          color: AppColors.primary,
        ),
      );
    }

    return SizedBox(
      width: 30,
      height: 30,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SplashRingPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _SplashRingPainter extends CustomPainter {
  _SplashRingPainter({required this.progress});

  final double progress;

  static const _stroke = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - _stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Arc only — no track / containing ring.
    final arc = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    const sweep = math.pi * 0.65;
    final start = progress * math.pi * 2 - math.pi / 2;
    canvas.drawArc(rect, start, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _SplashRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -math.pi / 12,
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: SizedBox(width: size, height: size),
      ),
    );
  }
}
