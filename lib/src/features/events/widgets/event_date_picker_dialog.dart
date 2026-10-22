import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Theme-aware month calendar in a glass dialog.
///
/// By default only [today] and future dates are selectable.
Future<DateTime?> showEventDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final resolvedFirst = firstDate == null
      ? today
      : DateTime(firstDate.year, firstDate.month, firstDate.day);
  final resolvedLast = lastDate ?? DateTime(now.year + 3, 12, 31);
  final rawInitial = initialDate ?? today;
  final dayOnly = DateTime(rawInitial.year, rawInitial.month, rawInitial.day);
  final initial = dayOnly.isBefore(resolvedFirst)
      ? resolvedFirst
      : (dayOnly.isAfter(resolvedLast) ? resolvedLast : dayOnly);

  return showAppGlassDialog<DateTime>(
    context: context,
    builder: (ctx) => _EventDatePickerDialog(
      initialDate: initial,
      firstDate: resolvedFirst,
      lastDate: resolvedLast,
    ),
  );
}

/// Result of [showEventDateFilterDialog].
class EventDateFilterResult {
  const EventDateFilterResult._({this.range, this.cleared = false});

  const EventDateFilterResult.cleared() : this._(cleared: true);

  const EventDateFilterResult.applied(DateTimeRange range)
    : this._(range: range);

  final DateTimeRange? range;
  final bool cleared;

  bool get isSingleDay {
    final r = range;
    if (r == null) return false;
    return isSameCalendarDay(r.start, r.end);
  }
}

/// Filter calendar: **one day** or a **date range**, with clear guidance.
Future<EventDateFilterResult?> showEventDateFilterDialog(
  BuildContext context, {
  DateTimeRange? initialRange,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final resolvedFirst = firstDate == null
      ? DateTime(now.year - 1)
      : DateTime(firstDate.year, firstDate.month, firstDate.day);
  final resolvedLast = lastDate ?? DateTime(now.year + 3, 12, 31);

  return showAppGlassDialog<EventDateFilterResult>(
    context: context,
    builder: (ctx) => _EventDateFilterDialog(
      initialRange: initialRange,
      firstDate: resolvedFirst,
      lastDate: resolvedLast,
      today: today,
    ),
  );
}

class _EventDatePickerDialog extends StatefulWidget {
  const _EventDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_EventDatePickerDialog> createState() => _EventDatePickerDialogState();
}

class _EventDatePickerDialogState extends State<_EventDatePickerDialog> {
  late DateTime _visibleMonth;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _visibleMonth = DateTime(_selected.year, _selected.month);
  }

  void _shiftMonth(int delta) {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    if (next.isBefore(
          DateTime(widget.firstDate.year, widget.firstDate.month),
        ) ||
        next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month))) {
      return;
    }
    setState(() => _visibleMonth = next);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final firstWeekday = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    ).weekday; // Mon=1 … Sun=7
    final leading = firstWeekday - 1;

    return AppGlassDialog(
      title: const Text('Pick a date'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
          child: const Text('Confirm'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MonthHeader(visibleMonth: _visibleMonth, onShift: _shiftMonth),
          const GutterSmall(),
          const _WeekdayRow(),
          const GutterSmall(),
          _CalendarGrid(
            visibleMonth: _visibleMonth,
            leading: leading,
            daysInMonth: daysInMonth,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            isHighlighted: (date) => isSameCalendarDay(date, _selected),
            onTapDay: (date) => setState(() => _selected = date),
          ),
        ],
      ),
    );
  }
}

enum _DateFilterMode { single, range }

class _EventDateFilterDialog extends StatefulWidget {
  const _EventDateFilterDialog({
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
    required this.today,
  });

  final DateTimeRange? initialRange;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime today;

  @override
  State<_EventDateFilterDialog> createState() => _EventDateFilterDialogState();
}

class _EventDateFilterDialogState extends State<_EventDateFilterDialog> {
  late _DateFilterMode _mode;
  late DateTime _visibleMonth;
  DateTime? _single;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRange;
    if (initial != null && isSameCalendarDay(initial.start, initial.end)) {
      _mode = _DateFilterMode.single;
      _single = DateTime(
        initial.start.year,
        initial.start.month,
        initial.start.day,
      );
      _visibleMonth = DateTime(_single!.year, _single!.month);
    } else if (initial != null) {
      _mode = _DateFilterMode.range;
      _rangeStart = DateTime(
        initial.start.year,
        initial.start.month,
        initial.start.day,
      );
      _rangeEnd = DateTime(
        initial.end.year,
        initial.end.month,
        initial.end.day,
      );
      _visibleMonth = DateTime(_rangeStart!.year, _rangeStart!.month);
    } else {
      _mode = _DateFilterMode.single;
      _single = widget.today;
      _visibleMonth = DateTime(widget.today.year, widget.today.month);
    }
  }

  void _shiftMonth(int delta) {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    if (next.isBefore(
          DateTime(widget.firstDate.year, widget.firstDate.month),
        ) ||
        next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month))) {
      return;
    }
    setState(() => _visibleMonth = next);
  }

  void _setMode(_DateFilterMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      if (mode == _DateFilterMode.single) {
        _single ??= _rangeStart ?? widget.today;
        _visibleMonth = DateTime(_single!.year, _single!.month);
      } else {
        _rangeStart ??= _single;
        _rangeEnd = null;
        if (_rangeStart != null) {
          _visibleMonth = DateTime(_rangeStart!.year, _rangeStart!.month);
        }
      }
    });
  }

  void _onTapDay(DateTime date) {
    setState(() {
      if (_mode == _DateFilterMode.single) {
        _single = date;
        return;
      }
      // Range: first tap = start; second = end (swap if needed).
      if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
        _rangeStart = date;
        _rangeEnd = null;
        return;
      }
      if (date.isBefore(_rangeStart!)) {
        _rangeEnd = _rangeStart;
        _rangeStart = date;
      } else {
        _rangeEnd = date;
      }
    });
  }

  bool _canApply() {
    if (_mode == _DateFilterMode.single) return _single != null;
    return _rangeStart != null && _rangeEnd != null;
  }

  void _apply() {
    if (!_canApply()) return;
    if (_mode == _DateFilterMode.single) {
      final day = _single!;
      Navigator.pop(
        context,
        EventDateFilterResult.applied(DateTimeRange(start: day, end: day)),
      );
      return;
    }
    Navigator.pop(
      context,
      EventDateFilterResult.applied(
        DateTimeRange(start: _rangeStart!, end: _rangeEnd!),
      ),
    );
  }

  bool _isHighlighted(DateTime date) {
    if (_mode == _DateFilterMode.single) {
      return _single != null && isSameCalendarDay(date, _single!);
    }
    if (_rangeStart != null && isSameCalendarDay(date, _rangeStart!)) {
      return true;
    }
    if (_rangeEnd != null && isSameCalendarDay(date, _rangeEnd!)) {
      return true;
    }
    return false;
  }

  bool _isInRange(DateTime date) {
    if (_mode != _DateFilterMode.range) return false;
    final start = _rangeStart;
    final end = _rangeEnd;
    if (start == null || end == null) return false;
    if (isSameCalendarDay(date, start) || isSameCalendarDay(date, end)) {
      return false;
    }
    return date.isAfter(start) && date.isBefore(end);
  }

  String get _hint {
    if (_mode == _DateFilterMode.single) {
      return 'Tap one day to show events on that date only.';
    }
    if (_rangeStart == null) {
      return 'Tap the start date of your range.';
    }
    if (_rangeEnd == null) {
      return 'Now tap the end date to complete the range.';
    }
    return 'Range selected — Apply to filter, or tap again to restart.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final firstWeekday = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    ).weekday;
    final leading = firstWeekday - 1;

    return AppGlassDialog(
      title: const Text('Filter by date'),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, const EventDateFilterResult.cleared()),
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canApply() ? _apply : null,
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
          child: const Text('Apply'),
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose a single day or a date range.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const Gutter(),
            Row(
              children: [
                Expanded(
                  child: _ModeChip(
                    label: 'One day',
                    icon: LucideIcons.calendar,
                    selected: _mode == _DateFilterMode.single,
                    onTap: () => _setMode(_DateFilterMode.single),
                  ),
                ),
                const GutterSmall(),
                Expanded(
                  child: _ModeChip(
                    label: 'Date range',
                    icon: LucideIcons.calendarRange,
                    selected: _mode == _DateFilterMode.range,
                    onTap: () => _setMode(_DateFilterMode.range),
                  ),
                ),
              ],
            ),
            const GutterSmall(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.info,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const GutterSmall(),
                    Expanded(
                      child: Text(
                        _hint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gutter(),
            _MonthHeader(visibleMonth: _visibleMonth, onShift: _shiftMonth),
            const GutterSmall(),
            const _WeekdayRow(),
            const GutterSmall(),
            _CalendarGrid(
              visibleMonth: _visibleMonth,
              leading: leading,
              daysInMonth: daysInMonth,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              isHighlighted: _isHighlighted,
              isInRange: _isInRange,
              onTapDay: _onTapDay,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.18)
          : colors.surfaceContainerHighest.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.primary : colors.onSurfaceVariant,
              ),
              const Gutter.custom(size: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.primary : colors.onSurface,
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

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.visibleMonth, required this.onShift});

  final DateTime visibleMonth;
  final ValueChanged<int> onShift;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: () => onShift(-1),
          icon: const Icon(LucideIcons.chevronLeft),
        ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy').format(visibleMonth),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () => onShift(1),
          icon: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        for (final label in const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'])
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.visibleMonth,
    required this.leading,
    required this.daysInMonth,
    required this.firstDate,
    required this.lastDate,
    required this.isHighlighted,
    required this.onTapDay,
    this.isInRange,
  });

  final DateTime visibleMonth;
  final int leading;
  final int daysInMonth;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool Function(DateTime date) isHighlighted;
  final bool Function(DateTime date)? isInRange;
  final ValueChanged<DateTime> onTapDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leading + daysInMonth,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        if (index < leading) {
          return const SizedBox.shrink();
        }
        final day = index - leading + 1;
        final date = DateTime(visibleMonth.year, visibleMonth.month, day);
        final selected = isHighlighted(date);
        final inRange = isInRange?.call(date) ?? false;
        final enabled = !date.isBefore(firstDate) && !date.isAfter(lastDate);

        return Material(
          color: selected
              ? AppColors.primary
              : inRange
              ? AppColors.primary.withValues(alpha: 0.22)
              : colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? () => onTapDay(date) : null,
            child: Center(
              child: Text(
                '$day',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: !enabled
                      ? colors.onSurfaceVariant.withValues(alpha: 0.35)
                      : selected
                      ? AppColors.onPrimary
                      : colors.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
