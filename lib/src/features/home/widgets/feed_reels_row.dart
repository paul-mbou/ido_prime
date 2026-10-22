import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/home/models/feed_reel.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Horizontal Instagram-style reels / stories row with gradient rings.
class FeedReelsRow extends StatelessWidget {
  const FeedReelsRow({super.key, required this.reels, this.onReelTap});

  final List<FeedReel> reels;
  final ValueChanged<FeedReel>? onReelTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: Text(
            'Reels',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const GutterSmall(),
        SizedBox(
          height: 98,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: context.gutter),
            itemCount: reels.length,
            separatorBuilder: (_, _) => const GutterSmall(),
            itemBuilder: (context, index) {
              final reel = reels[index];
              return _ReelAvatar(
                reel: reel,
                onTap: () => onReelTap?.call(reel),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ReelAvatar extends StatelessWidget {
  const _ReelAvatar({required this.reel, this.onTap});

  final FeedReel reel;
  final VoidCallback? onTap;

  static const _ringColors = [
    AppColors.primary,
    Color(0xFFE8C96A),
    Color(0xFF9B8FB8),
    AppColors.primary,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = reel.isMine ? 'Your story' : reel.authorName;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: reel.hasUnseen && !reel.isMine
                        ? const SweepGradient(colors: _ringColors)
                        : null,
                    border: reel.hasUnseen && !reel.isMine
                        ? null
                        : Border.all(
                            color: reel.isMine
                                ? colors.outline.withValues(alpha: 0.6)
                                : colors.outline.withValues(alpha: 0.85),
                            width: 2,
                          ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      reel.hasUnseen && !reel.isMine ? 2.5 : 0,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: AppCachedAvatar(
                          imageUrl: reel.avatarUrl,
                          radius: 28,
                          fallbackName: reel.authorName,
                        ),
                      ),
                    ),
                  ),
                ),
                if (reel.isMine)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          LucideIcons.plus,
                          size: 12,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const GutterTiny(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
