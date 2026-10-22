import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/inspiration/models/inspiration_look.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LookPinTile extends StatelessWidget {
  const LookPinTile({
    super.key,
    required this.look,
    required this.onTap,
    required this.onSave,
    this.saved = false,
    this.showTitle = false,
  });

  final InspirationLook look;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final bool saved;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final height = 160.0 * look.heightFactor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.55),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AppCachedNetworkImage(
                    imageUrl: look.imageUrl,
                    height: height,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
        ),
        const GutterTiny(),
        Row(
          children: [
            Expanded(
              child: Text(
                showTitle ? look.title : look.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!showTitle)
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: onSave,
                icon: Icon(
                  LucideIcons.bookmark,
                  size: 16,
                  color: saved ? AppColors.primary : colors.onSurface,
                  fill: saved ? 1 : 0,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class InspirationMasonry extends StatelessWidget {
  const InspirationMasonry({
    super.key,
    required this.looks,
    required this.onLookTap,
    required this.onSave,
    this.savedIds = const {},
    this.showTitles = false,
  });

  final List<InspirationLook> looks;
  final ValueChanged<InspirationLook> onLookTap;
  final ValueChanged<InspirationLook> onSave;
  final Set<String> savedIds;
  final bool showTitles;

  @override
  Widget build(BuildContext context) {
    final left = <InspirationLook>[];
    final right = <InspirationLook>[];
    for (var i = 0; i < looks.length; i++) {
      (i.isEven ? left : right).add(looks[i]);
    }

    Widget column(List<InspirationLook> items) {
      return Column(
        children: [
          for (final look in items) ...[
            LookPinTile(
              look: look,
              showTitle: showTitles,
              saved: savedIds.contains(look.id),
              onTap: () => onLookTap(look),
              onSave: () => onSave(look),
            ),
            const GutterSmall(),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: column(left)),
        const GutterSmall(),
        Expanded(child: column(right)),
      ],
    );
  }
}
