import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventContextChip extends StatelessWidget {
  const EventContextChip({
    super.key,
    required this.label,
    this.onTap,
    this.icon = LucideIcons.sparkles,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.primary.withValues(alpha: 0.14),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const GutterTiny(),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InspirationCategoryChips extends StatelessWidget {
  const InspirationCategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const GutterSmall(),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          final theme = Theme.of(context);
          final colors = theme.colorScheme;
          return Material(
            color: isSelected ? colors.primary : colors.surface,
            shape: StadiumBorder(
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(color: colors.outline.withValues(alpha: 0.8)),
            ),
            child: InkWell(
              onTap: () => onSelected(category),
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  category,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected ? colors.onPrimary : colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
