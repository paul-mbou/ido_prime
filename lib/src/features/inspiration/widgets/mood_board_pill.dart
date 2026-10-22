import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/features/inspiration/models/mood_board.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MoodBoardPill extends StatelessWidget {
  const MoodBoardPill({super.key, required this.board, required this.onTap});

  final MoodBoard board;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: 112,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 112 / 72,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.7),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: MoodBoardCoverCollage(coverUrls: board.coverUrls),
                ),
              ),
            ),
            const GutterTiny(),
            Text(
              board.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              board.countLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2×2 cover collage that fills its parent (avoids GridView loose constraints
/// collapsing [AppCachedNetworkImage] to zero size).
class MoodBoardCoverCollage extends StatelessWidget {
  const MoodBoardCoverCollage({
    super.key,
    required this.coverUrls,
    this.gap = 2,
  });

  final List<String> coverUrls;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (coverUrls.isEmpty) {
      return ColoredBox(color: colors.surfaceContainerHighest);
    }

    String urlAt(int i) => coverUrls[i % coverUrls.length];

    Widget cell(String url) {
      return AppCachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.zero,
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: cell(urlAt(0))),
              Gutter.custom(size: gap),
              Expanded(child: cell(urlAt(1))),
            ],
          ),
        ),
        Gutter.custom(size: gap),
        Expanded(
          child: Row(
            children: [
              Expanded(child: cell(urlAt(2))),
              Gutter.custom(size: gap),
              Expanded(child: cell(urlAt(3))),
            ],
          ),
        ),
      ],
    );
  }
}

class NewMoodBoardPill extends StatelessWidget {
  const NewMoodBoardPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: 112,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 112 / 72,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.7),
                  ),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.plus,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
            const GutterTiny(),
            Text(
              'New board',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
