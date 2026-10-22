import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Quote-style panel for text-only posts (feed truncated, detail full).
class TextPostPanel extends StatelessWidget {
  const TextPostPanel({
    super.key,
    required this.caption,
    required this.timeAgo,
    this.maxLines,
  });

  final String caption;
  final String timeAgo;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final truncated = maxLines != null;
    final showReadMore = truncated && caption.trim().length > 80;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.16),
              colors.surface.withValues(alpha: 0.95),
              colors.surfaceContainerHighest.withValues(alpha: 0.55),
            ],
            stops: const [0, 0.45, 1],
          ),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ColoredBox(
                color: AppColors.primary,
                child: SizedBox(width: 4),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.quote,
                        size: 18,
                        color: AppColors.primary.withValues(alpha: 0.9),
                      ),
                      const GutterSmall(),
                      Text(
                        caption,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          letterSpacing: -0.15,
                          color: colors.onSurface,
                        ),
                        maxLines: maxLines,
                        overflow: truncated
                            ? TextOverflow.ellipsis
                            : TextOverflow.visible,
                      ),
                      const GutterSmall(),
                      Row(
                        children: [
                          Text(
                            timeAgo,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (showReadMore) ...[
                            const Spacer(),
                            Text(
                              'Read more',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
