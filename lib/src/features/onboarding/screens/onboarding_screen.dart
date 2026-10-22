import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/onboarding/models/onboarding_page.dart';
import 'package:ido_prime/src/features/onboarding/providers/onboarding_provider.dart';

/// First-run product tour — cinematic cuts, copy rising from the bottom.
class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  static const _cutDuration = Duration(milliseconds: 720);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final index = useState(0);
    final finishing = useState(false);
    final pages = onboardingPages;
    final isLast = index.value == pages.length - 1;

    Future<void> finish() async {
      if (finishing.value) return;
      finishing.value = true;
      await ref.read(onboardingControllerProvider).complete();
      if (!context.mounted) return;
      context.go(AppRoutes.posts);
    }

    void goNext() {
      if (isLast) {
        finish();
        return;
      }
      index.value = index.value + 1;
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Hard cinematic cut between slides (fade), not a soft page swipe.
          AnimatedSwitcher(
            duration: _cutDuration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _OnboardingSlide(
              key: ValueKey<int>(index.value),
              page: pages[index.value],
              pageIndex: index.value,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.gutter,
                context.gutterSmall,
                context.gutter,
                context.gutter,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: !isLast
                        ? TextButton(
                            onPressed: finish,
                            child: Text(
                              'Skip',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : const SizedBox(height: 48),
                  ),
                  const Spacer(),
                  _PageDots(count: pages.length, index: index.value),
                  const Gutter(),
                  FilledButton(
                    onPressed: finishing.value ? null : goNext,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      finishing.value
                          ? 'Opening…'
                          : isLast
                          ? 'Start celebrating'
                          : 'Continue',
                    ),
                  ),
                  if (isLast) ...[
                    const GutterSmall(),
                    Text(
                      'You can change theme and space anytime in Profile.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends HookWidget {
  const _OnboardingSlide({
    super.key,
    required this.page,
    required this.pageIndex,
  });

  final OnboardingPageData page;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canvas = theme.scaffoldBackgroundColor;
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final longestPx = (math.max(size.width, size.height) * dpr).round();
    final maxDecode = longestPx.clamp(1600, 3200);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 980),
    );

    useEffect(() {
      if (reduceMotion) {
        controller.value = 1;
      } else {
        controller.forward(from: 0);
      }
      return null;
    }, [pageIndex]);

    // Image: slow settle zoom (cinematic).
    final imageScale = Tween<double>(begin: 1.12, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    final imageFade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    // Copy: brutal rise from bottom + smooth fade (staggered).
    final eyebrowFade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.18, 0.55, curve: Curves.easeOut),
    );
    final eyebrowSlide =
        Tween<Offset>(begin: const Offset(0, 0.55), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.18, 0.62, curve: Curves.easeOutCubic),
          ),
        );

    final titleFade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.28, 0.7, curve: Curves.easeOut),
    );
    final titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.62), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.28, 0.78, curve: Curves.easeOutCubic),
          ),
        );

    final bodyFade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.4, 0.88, curve: Curves.easeOut),
    );
    final bodySlide =
        Tween<Offset>(begin: const Offset(0, 0.48), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.4, 0.92, curve: Curves.easeOutCubic),
          ),
        );

    return Stack(
      fit: StackFit.expand,
      children: [
        FadeTransition(
          opacity: imageFade,
          child: ScaleTransition(
            scale: imageScale,
            child: AppCachedNetworkImage(
              imageUrl: page.imageUrlFor(context),
              fit: BoxFit.cover,
              alignment: page.alignment,
              borderRadius: BorderRadius.zero,
              maxDecodePx: maxDecode,
              fadeInDuration: Duration.zero,
              errorWidget: ColoredBox(color: colors.surfaceContainerHighest),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                canvas.withValues(alpha: 0.08),
                canvas.withValues(alpha: 0.35),
                canvas.withValues(alpha: 0.88),
                canvas,
              ],
              stops: const [0.0, 0.28, 0.58, 0.84],
            ),
          ),
        ),
        Positioned(
          left: context.gutter,
          right: context.gutter,
          bottom: 140 + MediaQuery.paddingOf(context).bottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: eyebrowFade,
                child: SlideTransition(
                  position: eyebrowSlide,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(page.icon, size: 16, color: AppColors.primary),
                          const GutterTiny(),
                          Text(
                            page.eyebrow.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Gutter(),
              FadeTransition(
                opacity: titleFade,
                child: SlideTransition(
                  position: titleSlide,
                  child: Text(
                    page.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
              const GutterSmall(),
              FadeTransition(
                opacity: bodyFade,
                child: SlideTransition(
                  position: bodySlide,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: size.width * 0.92),
                    child: Text(
                      page.body,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const GutterTiny(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: i == index ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index
                  ? AppColors.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ],
    );
  }
}
