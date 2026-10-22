import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ido_prime/src/core/shared/widgets/app_shimmer.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// True for http(s) URLs; false for local file paths (or empty).
bool isNetworkImageUrl(String url) {
  final trimmed = url.trim();
  return trimmed.startsWith('http://') || trimmed.startsWith('https://');
}

/// Disk cache tuned for feed / avatar images.
///
/// Keeps objects long enough for repeat visits without growing unbounded.
/// [ImageCacheManager] enables on-disk resize via [maxWidthDiskCache] /
/// [maxHeightDiskCache] on [CachedNetworkImage].
class AppImageCacheManager extends CacheManager with ImageCacheManager {
  AppImageCacheManager._()
    : super(
        Config(
          _key,
          stalePeriod: const Duration(days: 14),
          maxNrOfCacheObjects: 300,
        ),
      );

  static const _key = 'idoPrimeImages';

  static final AppImageCacheManager instance = AppImageCacheManager._();
}

/// Network image with disk + memory caching and device-aware decode size.
///
/// Decodes at roughly [display size × devicePixelRatio] (capped) so Flutter
/// never keeps a full-resolution bitmap in [ImageCache] when the widget is
/// smaller on screen. Disk cache stores a moderately resized copy for faster
/// cold starts.
class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 180),
    this.fadeOutDuration = const Duration(milliseconds: 120),

    /// Soft cap for decoded pixels on one axis (physical px).
    this.maxDecodePx = 1440,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final int maxDecodePx;

  @override
  Widget build(BuildContext context) {
    final fallbackError =
        errorWidget ??
        const ColoredBox(
          color: AppColors.surface,
          child: Icon(LucideIcons.imageOff),
        );

    Widget image = LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final screen = MediaQuery.sizeOf(context);

        final logicalW = _resolveLogical(
          explicit: width,
          constraint: constraints.maxWidth,
          fallback: screen.width,
        );
        final logicalH = _resolveLogical(
          explicit: height,
          constraint: constraints.maxHeight,
          fallback: screen.height,
        );

        final memW = _toCachePx(logicalW, dpr, maxDecodePx);
        final memH = _toCachePx(logicalH, dpr, maxDecodePx);

        if (!isNetworkImageUrl(imageUrl)) {
          final path = imageUrl.startsWith('file://')
              ? Uri.parse(imageUrl).toFilePath()
              : imageUrl.trim();
          if (path.isEmpty || !File(path).existsSync()) {
            return fallbackError;
          }
          return Image.file(
            File(path),
            fit: fit,
            width: width,
            height: height,
            alignment: alignment,
            cacheWidth: memW,
            cacheHeight: memH,
            errorBuilder: (_, _, _) => fallbackError,
          );
        }

        return CachedNetworkImage(
          imageUrl: imageUrl,
          cacheManager: AppImageCacheManager.instance,
          fit: fit,
          width: width,
          height: height,
          alignment: alignment,
          memCacheWidth: memW,
          memCacheHeight: memH,
          // Store a phone-friendly copy on disk (not the original 4K file).
          maxWidthDiskCache: memW,
          maxHeightDiskCache: memH,
          fadeInDuration: fadeInDuration,
          fadeOutDuration: fadeOutDuration,
          useOldImageOnUrlChange: true,
          placeholder: (_, _) =>
              placeholder ??
              const SizedBox.expand(child: AppShimmer()),
          errorWidget: (_, _, _) => fallbackError,
        );
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  static double _resolveLogical({
    required double? explicit,
    required double constraint,
    required double fallback,
  }) {
    if (explicit != null && explicit.isFinite && explicit > 0) return explicit;
    if (constraint.isFinite && constraint > 0) return constraint;
    return fallback;
  }

  static int _toCachePx(double logicalPx, double dpr, int maxPx) {
    final px = (logicalPx * dpr).round();
    if (px < 1) return 1;
    return px > maxPx ? maxPx : px;
  }
}

/// Circular avatar backed by the same cache + decode strategy.
///
/// Empty [imageUrl] or load failure shows initials from [fallbackName], or a
/// person icon when no name is available.
class AppCachedAvatar extends StatelessWidget {
  const AppCachedAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 18,
    this.backgroundColor,
    this.fallbackName,
  });

  final String imageUrl;
  final double radius;
  final Color? backgroundColor;
  final String? fallbackName;

  String get _initials {
    final parts = (fallbackName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    String firstChar(String s) => s.isEmpty ? '' : s.substring(0, 1);
    if (parts.length == 1) return firstChar(parts.first).toUpperCase();
    return '${firstChar(parts.first)}${firstChar(parts.last)}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? colors.surfaceContainerHighest;
    final dpr = View.of(context).devicePixelRatio;
    final diameter = radius * 2;
    final cachePx = AppCachedNetworkImage._toCachePx(diameter, dpr, 256);

    Widget fallback() {
      final initials = _initials;
      if (initials.isNotEmpty) {
        return Text(
          initials,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: radius * 0.72,
            color: colors.onSurfaceVariant,
          ),
        );
      }
      return Icon(
        LucideIcons.user,
        size: radius,
        color: colors.onSurfaceVariant,
      );
    }

    if (imageUrl.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: fallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: AppImageCacheManager.instance,
      memCacheWidth: cachePx,
      memCacheHeight: cachePx,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) =>
          AppShimmer.circle(diameter: diameter),
      errorWidget: (context, url, error) =>
          CircleAvatar(radius: radius, backgroundColor: bg, child: fallback()),
    );
  }
}
