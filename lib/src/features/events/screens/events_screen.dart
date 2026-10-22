import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/shared/widgets/app_root_layout.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/events/widgets/event_card.dart';
import 'package:ido_prime/src/features/events/widgets/event_date_picker_dialog.dart';
import 'package:ido_prime/src/features/events/widgets/events_date_strip.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _EventsScope { mine, aroundMe, publicFeed }

class EventsScreen extends HookConsumerWidget {
  const EventsScreen({super.key});

  static bool _isAroundMe(Event e) {
    final place = e.place.toLowerCase();
    return place.contains('douala') ||
        place.contains('limbe') ||
        place.contains('kribi') ||
        place.contains('yaound');
  }

  static bool _inDateRange(Event e, DateTimeRange range) {
    final d = e.eventDate;
    if (d == null) return false;
    final day = DateTime(d.year, d.month, d.day);
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = useState(_EventsScope.mine);
    final now = DateTime.now();
    final selectedDay = useState(DateTime(now.year, now.month, now.day));
    final dateRange = useState<DateTimeRange?>(null);
    final selectedTypes = useState<Set<EventType>>(<EventType>{});
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final events = ref.watch(eventsProvider);

    final hasDateRange = dateRange.value != null;
    final hasTypeFilter = selectedTypes.value.isNotEmpty;

    final scoped = events
        .where((e) {
          return switch (scope.value) {
            _EventsScope.mine => e.isMine,
            _EventsScope.aroundMe =>
              e.visibility != EventVisibility.private && _isAroundMe(e),
            _EventsScope.publicFeed => e.visibility == EventVisibility.public,
          };
        })
        .toList(growable: false);

    final filtered = scoped
        .where((e) {
          if (hasTypeFilter && !selectedTypes.value.contains(e.type)) {
            return false;
          }
          if (hasDateRange) {
            return _inDateRange(e, dateRange.value!);
          }
          return e.eventDate == null || e.isOnDay(selectedDay.value);
        })
        .toList(growable: false);

    void openCreate() => context.push(AppRoutes.createEvent);

    Future<void> pickDateFilter() async {
      final existing = dateRange.value;
      final result = await showEventDateFilterDialog(
        context,
        initialRange:
            existing ??
            DateTimeRange(start: selectedDay.value, end: selectedDay.value),
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 3, 12, 31),
      );
      if (result == null || !context.mounted) return;
      if (result.cleared) {
        dateRange.value = null;
        selectedDay.value = DateTime(now.year, now.month, now.day);
        return;
      }
      final range = result.range;
      if (range == null) return;
      dateRange.value = range;
      if (result.isSingleDay) {
        selectedDay.value = DateTime(
          range.start.year,
          range.start.month,
          range.start.day,
        );
      }
    }

    Future<void> pickTypes() async {
      final result = await showAppGlassDialog<Set<EventType>>(
        context: context,
        builder: (ctx) =>
            _EventTypeFilterDialog(initiallySelected: selectedTypes.value),
      );
      if (result == null) return;
      selectedTypes.value = result;
    }

    return AppRootLayout(
      extendUnderAppBar: true,
      padding: EdgeInsets.fromLTRB(context.gutter, 0, context.gutter, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Events',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _HeaderFilterIcon(
              icon: LucideIcons.calendarRange,
              tooltip: hasDateRange
                  ? 'Change date filter'
                  : 'Filter by day or date range',
              active: hasDateRange,
              onPressed: pickDateFilter,
              onLongPress: hasDateRange
                  ? () {
                      dateRange.value = null;
                      selectedDay.value = DateTime(
                        now.year,
                        now.month,
                        now.day,
                      );
                    }
                  : null,
            ),
            const Gutter.custom(size: 4),
            _HeaderFilterIcon(
              icon: LucideIcons.listFilter,
              tooltip: hasTypeFilter
                  ? 'Change type filter'
                  : 'Filter by event type',
              active: hasTypeFilter,
              onPressed: pickTypes,
              onLongPress: hasTypeFilter
                  ? () => selectedTypes.value = <EventType>{}
                  : null,
            ),
          ],
        ),
        const GutterTiny(),
        Text(
          'Your plans, nearby celebrations, and public discoveries.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        if (hasDateRange || hasTypeFilter) ...[
          const GutterSmall(),
          _ActiveFiltersBar(
            dateRange: dateRange.value,
            types: selectedTypes.value,
            onClearDate: () {
              dateRange.value = null;
              selectedDay.value = DateTime(now.year, now.month, now.day);
            },
            onClearTypes: () => selectedTypes.value = <EventType>{},
            onClearAll: () {
              dateRange.value = null;
              selectedTypes.value = <EventType>{};
              selectedDay.value = DateTime(now.year, now.month, now.day);
            },
          ),
        ],
        const Gutter(),
        _ScopeChips(
          selected: scope.value,
          onSelected: (value) => scope.value = value,
        ),
        if (!hasDateRange) ...[
          const Gutter(),
          EventsDateStrip(
            selected: selectedDay.value,
            onSelected: (day) {
              selectedDay.value = day;
              dateRange.value = null;
            },
          ),
        ],
        const Gutter(),
        if (filtered.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.gutterLarge * 2),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 40,
                    color: colors.onSurfaceVariant,
                  ),
                  const GutterSmall(),
                  Text(
                    hasDateRange || hasTypeFilter
                        ? 'No events match your filters'
                        : 'No events on this day',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const GutterTiny(),
                  Text(
                    hasDateRange || hasTypeFilter
                        ? 'Widen the dates or clear type filters.'
                        : scope.value == _EventsScope.mine
                        ? 'Plan a celebration or pick another date.'
                        : 'Try another date or switch filters.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (hasDateRange || hasTypeFilter) ...[
                    const Gutter(),
                    OutlinedButton(
                      onPressed: () {
                        dateRange.value = null;
                        selectedTypes.value = <EventType>{};
                        selectedDay.value = DateTime(
                          now.year,
                          now.month,
                          now.day,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Clear filters'),
                    ),
                  ] else if (scope.value == _EventsScope.mine) ...[
                    const Gutter(),
                    FilledButton.icon(
                      onPressed: openCreate,
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text('Plan an event'),
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          for (final event in filtered) ...[
            EventCard(event: event),
            const Gutter(),
          ],
      ],
    );
  }
}

class _HeaderFilterIcon extends StatelessWidget {
  const _HeaderFilterIcon({
    required this.icon,
    required this.onPressed,
    required this.active,
    this.tooltip,
    this.onLongPress,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final bool active;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final child = Material(
      color: active
          ? AppColors.primary.withValues(alpha: 0.18)
          : colors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: active ? AppColors.primary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  const _ActiveFiltersBar({
    required this.dateRange,
    required this.types,
    required this.onClearDate,
    required this.onClearTypes,
    required this.onClearAll,
  });

  final DateTimeRange? dateRange;
  final Set<EventType> types;
  final VoidCallback onClearDate;
  final VoidCallback onClearTypes;
  final VoidCallback onClearAll;

  static final _fmt = DateFormat('MMM d');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (dateRange != null)
          _FilterChip(
            label: isSameCalendarDay(dateRange!.start, dateRange!.end)
                ? _fmt.format(dateRange!.start)
                : '${_fmt.format(dateRange!.start)} – ${_fmt.format(dateRange!.end)}',
            icon: isSameCalendarDay(dateRange!.start, dateRange!.end)
                ? LucideIcons.calendar
                : LucideIcons.calendarRange,
            onClear: onClearDate,
          ),
        if (types.isNotEmpty)
          _FilterChip(
            label: types.length == 1
                ? types.first.label
                : '${types.length} types',
            icon: LucideIcons.listFilter,
            onClear: onClearTypes,
          ),
        TextButton(
          onPressed: onClearAll,
          style: TextButton.styleFrom(
            foregroundColor: colors.onSurfaceVariant,
            visualDensity: VisualDensity.compact,
          ),
          child: Text(
            'Clear',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onClear,
  });

  final String label;
  final IconData icon;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.primary.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onClear,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const Gutter.custom(size: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gutter.custom(size: 4),
              const Icon(LucideIcons.x, size: 14, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventTypeFilterDialog extends StatefulWidget {
  const _EventTypeFilterDialog({required this.initiallySelected});

  final Set<EventType> initiallySelected;

  @override
  State<_EventTypeFilterDialog> createState() => _EventTypeFilterDialogState();
}

class _EventTypeFilterDialogState extends State<_EventTypeFilterDialog> {
  late Set<EventType> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initiallySelected};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppGlassDialog(
      title: const Text('Event type'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, <EventType>{}),
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
          child: const Text('Apply'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select one or more categories. Leave empty to show all types.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const Gutter(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in EventType.values)
                FilterChip(
                  label: Text(type.label),
                  selected: _selected.contains(type),
                  showCheckmark: false,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selected.add(type);
                      } else {
                        _selected.remove(type);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.22),
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _selected.contains(type)
                        ? AppColors.primary
                        : colors.onSurface,
                  ),
                  side: BorderSide(
                    color: _selected.contains(type)
                        ? AppColors.primary
                        : colors.outline.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScopeChips extends StatelessWidget {
  const _ScopeChips({required this.selected, required this.onSelected});

  final _EventsScope selected;
  final ValueChanged<_EventsScope> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in _EventsScope.values) ...[
            if (option != _EventsScope.values.first) const GutterSmall(),
            _Chip(
              label: switch (option) {
                _EventsScope.mine => 'My events',
                _EventsScope.aroundMe => 'Around me',
                _EventsScope.publicFeed => 'Upcoming',
              },
              selected: selected == option,
              onTap: () => onSelected(option),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected ? AppColors.primary : colors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : colors.outline.withValues(alpha: 0.7),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.onPrimary : colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
