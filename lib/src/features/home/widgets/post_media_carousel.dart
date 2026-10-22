import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Swipeable image carousel for feed + post detail.
class PostMediaCarousel extends HookWidget {
  const PostMediaCarousel({
    super.key,
    required this.urls,
    this.onTapImage,
    this.heroTagPrefix,
    this.aspectRatio = 4 / 4.1,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.initialIndex = 0,
  });

  final List<String> urls;
  final ValueChanged<int>? onTapImage;
  final String? heroTagPrefix;
  final double aspectRatio;
  final BorderRadius borderRadius;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final page = useState(initialIndex.clamp(0, urls.isEmpty ? 0 : urls.length - 1));
    final controller = usePageController(initialPage: page.value);

    if (urls.isEmpty) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: borderRadius,
          ),
          child: Icon(LucideIcons.imageOff, color: colors.onSurfaceVariant),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: controller,
                  itemCount: urls.length,
                  onPageChanged: (i) => page.value = i,
                  itemBuilder: (context, index) {
                    final image = AppCachedNetworkImage(
                      imageUrl: urls[index],
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.zero,
                      errorWidget: ColoredBox(
                        color: colors.surfaceContainerHighest,
                        child: Icon(
                          LucideIcons.imageOff,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    );
                    final tagged = heroTagPrefix == null
                        ? image
                        : Hero(tag: '$heroTagPrefix-$index', child: image);
                    return GestureDetector(
                      onTap: onTapImage == null
                          ? null
                          : () => onTapImage!(index),
                      child: tagged,
                    );
                  },
                ),
                if (urls.length > 1)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          '${page.value + 1}/${urls.length}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (urls.length > 1) ...[
          const GutterSmall(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < urls.length; i++) ...[
                if (i > 0) const Gutter.custom(size: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: page.value == i ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: page.value == i
                        ? AppColors.primary
                        : colors.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
