import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AiMatchedVendorsBanner extends StatelessWidget {
  const AiMatchedVendorsBanner({
    super.key,
    this.matchCount = 12,
    this.eventName = 'Summer Wedding',
  });

  final int matchCount;
  final String eventName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colors.primary,
              child: Icon(
                LucideIcons.sparkles,
                size: 20,
                color: colors.onPrimary,
              ),
            ),
            const GutterSmall(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Matched Vendors',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const Gutter.custom(size: 2),
                  Text(
                    'Based on your $eventName event, we found '
                    '$matchCount perfect matches',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
