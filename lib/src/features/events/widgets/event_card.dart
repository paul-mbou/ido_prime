import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(AppRoutes.eventDetail(event.id)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(17),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppCachedNetworkImage(
                        imageUrl: event.coverUrl,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.zero,
                        errorWidget: ColoredBox(
                          color: colors.surfaceContainerHighest,
                          child: Icon(
                            LucideIcons.calendar,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _Chip(label: event.statusLabel, filled: true),
                      ),
                      if (event.theme.isNotEmpty)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: _Chip(label: event.theme),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gutter.custom(size: 6),
                    _Meta(
                      icon: LucideIcons.calendarDays,
                      label: event.dateLabel,
                    ),
                    const GutterTiny(),
                    _Meta(icon: LucideIcons.mapPin, label: event.place),
                    const Gutter(),
                    Row(
                      children: [
                        if (event.guestCount > 0) ...[
                          Icon(
                            LucideIcons.users,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const GutterTiny(),
                          Text(
                            '${event.guestCount}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (event.vendorCount > 0) ...[
                          const Gutter(),
                          Icon(
                            LucideIcons.store,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const GutterTiny(),
                          Text(
                            '${event.vendorCount} vendors',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.filled = false});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled
            ? AppColors.primary
            : Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: filled ? AppColors.onPrimary : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceVariant),
        const Gutter.custom(size: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
