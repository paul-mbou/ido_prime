import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Compact event card interleaved in the social feed.
class FeedEventCard extends StatelessWidget {
  const FeedEventCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      child: Material(
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
                          child: _StatusChip(status: event.effectiveStatus),
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
                      Row(
                        children: [
                          Icon(
                            LucideIcons.sparkles,
                            size: 14,
                            color: colors.primary,
                          ),
                          const GutterTiny(),
                          Text(
                            'Event',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const GutterTiny(),
                      Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gutter.custom(size: 6),
                      _MetaRow(
                        icon: LucideIcons.calendarDays,
                        label: event.dateLabel,
                      ),
                      const GutterTiny(),
                      _MetaRow(icon: LucideIcons.mapPin, label: event.place),
                      if (event.guestCount > 0) ...[
                        const Gutter(),
                        Row(
                          children: [
                            Text(
                              '${event.guestCount} guests',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'View event',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const GutterTiny(),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 16,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          status == EventStatus.planning
              ? 'Planning'
              : status == EventStatus.upcoming
              ? 'Upcoming'
              : 'Past',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

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
