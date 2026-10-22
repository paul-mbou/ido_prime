import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/vendors/models/vendor.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VendorCard extends HookWidget {
  const VendorCard({
    super.key,
    required this.vendor,
    this.onContact,
    this.onViewProfile,
  });

  final Vendor vendor;
  final VoidCallback? onContact;
  final VoidCallback? onViewProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final favorited = useState(vendor.isFavorite);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VendorImage(
              imageUrl: vendor.imageUrl,
              isAiMatch: vendor.isAiMatch,
              isFavorite: favorited.value,
              onFavoriteToggle: () => favorited.value = !favorited.value,
            ),
            const Gutter(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          vendor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      if (vendor.isVerified) ...[
                        const GutterTiny(),
                        Icon(
                          LucideIcons.badgeCheck,
                          size: 18,
                          color: colors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
                const GutterSmall(),
                _RatingBadge(
                  rating: vendor.rating,
                  reviewCount: vendor.reviewCount,
                ),
              ],
            ),
            const Gutter.custom(size: 4),
            Text(
              vendor.category,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const GutterSmall(),
            Row(
              children: [
                Icon(
                  LucideIcons.mapPin,
                  size: 15,
                  color: colors.onSurfaceVariant,
                ),
                const Gutter.custom(size: 4),
                Text(
                  vendor.location,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Gutter(),
                _PriceLevel(level: vendor.priceLevel),
              ],
            ),
            const Gutter(),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onContact,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Contact'),
                  ),
                ),
                const GutterSmall(),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewProfile,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      backgroundColor: Colors.transparent,
                      foregroundColor: colors.onSurface,
                      side: BorderSide(color: colors.outline),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('View Profile'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorImage extends StatelessWidget {
  const _VendorImage({
    required this.imageUrl,
    required this.isAiMatch,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final String imageUrl;
  final bool isAiMatch;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppCachedNetworkImage(
            imageUrl: imageUrl,
            borderRadius: BorderRadius.circular(14),
            errorWidget: ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Icon(LucideIcons.imageOff, color: colors.onSurfaceVariant),
            ),
          ),
          if (isAiMatch)
            Positioned(
              top: 12,
              left: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.sparkles,
                        size: 13,
                        color: colors.onPrimary,
                      ),
                      const Gutter.custom(size: 4),
                      Text(
                        'AI Match',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onFavoriteToggle,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    LucideIcons.heart,
                    size: 18,
                    color: isFavorite ? AppColors.like : Colors.white,
                    fill: isFavorite ? 1 : 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating, required this.reviewCount});

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.star, size: 15, color: colors.primary, fill: 1),
        const Gutter.custom(size: 4),
        Text(
          rating.toStringAsFixed(1),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const Gutter.custom(size: 4),
        Text(
          '($reviewCount)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PriceLevel extends StatelessWidget {
  const _PriceLevel({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = level.clamp(1, 4);

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 1; i <= 4; i++)
            TextSpan(
              text: '\$',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: i <= active
                    ? colors.onSurface
                    : colors.onSurfaceVariant.withValues(alpha: 0.45),
                letterSpacing: 1,
              ),
            ),
        ],
      ),
    );
  }
}
