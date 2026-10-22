import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Full-screen image viewer with pinch-to-zoom and optional carousel swipe.
class FullscreenImageScreen extends HookWidget {
  const FullscreenImageScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final start = imageUrls.isEmpty
        ? 0
        : initialIndex.clamp(0, imageUrls.length - 1);
    final page = useState(start);
    final zoomed = useState(false);
    final controller = usePageController(initialPage: start);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppFrostedAppBar(
        frosted: true,
        tintOpacity: 0.35,
        title: imageUrls.length > 1
            ? Text(
                '${page.value + 1} / ${imageUrls.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
        actions: [
          AppCircleIconButton(
            icon: LucideIcons.x,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const GutterSmall(),
        ],
      ),
      body: imageUrls.isEmpty
          ? Center(
              child: Icon(
                LucideIcons.imageOff,
                color: colors.onSurfaceVariant,
                size: 48,
              ),
            )
          : PageView.builder(
              controller: controller,
              itemCount: imageUrls.length,
              physics: zoomed.value
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              onPageChanged: (i) {
                page.value = i;
                zoomed.value = false;
              },
              itemBuilder: (context, index) {
                return _ZoomableImage(
                  imageUrl: imageUrls[index],
                  onScaleChanged: (scale) {
                    final next = scale > 1.05;
                    if (next != zoomed.value) zoomed.value = next;
                  },
                );
              },
            ),
    );
  }
}

class _ZoomableImage extends HookWidget {
  const _ZoomableImage({required this.imageUrl, required this.onScaleChanged});

  final String imageUrl;
  final ValueChanged<double> onScaleChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final transform = useTransformationController();

    useEffect(() {
      void listener() {
        onScaleChanged(transform.value.getMaxScaleOnAxis());
      }

      transform.addListener(listener);
      return () => transform.removeListener(listener);
    }, [transform]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return InteractiveViewer(
          transformationController: transform,
          minScale: 1,
          maxScale: 5,
          panEnabled: true,
          scaleEnabled: true,
          clipBehavior: Clip.none,
          boundaryMargin: const EdgeInsets.all(80),
          child: SizedBox(
            width: w,
            height: h,
            child: AppCachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              width: w,
              height: h,
              borderRadius: BorderRadius.zero,
              maxDecodePx: 2560,
              errorWidget: Icon(
                LucideIcons.imageOff,
                color: colors.onSurfaceVariant,
                size: 48,
              ),
            ),
          ),
        );
      },
    );
  }
}
