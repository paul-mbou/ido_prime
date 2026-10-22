import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/models/event_templates.dart';
import 'package:ido_prime/src/features/events/providers/event_vendor_links_provider.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/vendors/models/vendor.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventBudgetSection extends ConsumerWidget {
  const EventBudgetSection({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final notifier = ref.read(eventsProvider.notifier);
    final health = event.budgetHealth;
    final allocatedRatio = event.totalBudget <= 0
        ? 0.0
        : (event.allocatedBudget / event.totalBudget).clamp(0.0, 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Budget',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _editTotalBudget(context, notifier),
              icon: Icon(LucideIcons.pencil, size: 14, color: colors.primary),
              label: Text(
                'Edit total',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const GutterSmall(),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatEventMoney(event.totalBudget, currency: event.currency),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const GutterTiny(),
                Text(
                  'Allocated ${formatEventMoney(event.allocatedBudget)} · '
                  'Left ${formatEventMoney(event.remainingBudget)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Gutter(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: allocatedRatio > 1 ? 1 : allocatedRatio,
                    minHeight: 8,
                    backgroundColor: colors.surfaceContainerHighest,
                    color: health == BudgetHealth.overAllocated
                        ? AppColors.like
                        : AppColors.primary,
                  ),
                ),
                const Gutter(),
                _HealthBanner(event: event),
                const Gutter(),
                for (final line in event.budgetLines) ...[
                  _BudgetLineTile(
                    event: event,
                    line: line,
                    onEdit: () => _editLine(context, notifier, line),
                    onDelete: () =>
                        notifier.removeBudgetLine(event.id, line.id),
                  ),
                  const GutterSmall(),
                ],
                const GutterSmall(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        notifier.applyAiBudgetProposal(event.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('AI proposed a new budget split'),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.sparkles, size: 16),
                      label: const Text('AI new split'),
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showAiTips(context),
                      icon: const Icon(LucideIcons.messageCircle, size: 16),
                      label: const Text('AI tips'),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _addCategory(context, notifier),
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Add category'),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                      ),
                    ),
                    TextButton(
                      onPressed: () => notifier.resetBudgetToDefaults(event.id),
                      child: const Text('Reset defaults'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editTotalBudget(
    BuildContext context,
    EventsNotifier notifier,
  ) async {
    final result = await showAppGlassDialog<double>(
      context: context,
      builder: (ctx) => _AmountDialog(
        title: 'Total budget',
        subtitle:
            'Recommended ~${formatEventMoney(event.recommendedBudget)} '
            'for ${event.guestCount} guests',
        initialAmount: event.totalBudget,
      ),
    );
    if (result != null) notifier.updateTotalBudget(event.id, result);
  }

  Future<void> _editLine(
    BuildContext context,
    EventsNotifier notifier,
    BudgetLine line,
  ) async {
    final result = await showAppGlassDialog<(String, double)>(
      context: context,
      builder: (ctx) =>
          _EditBudgetLineDialog(line: line, currency: event.currency),
    );
    if (result == null) return;
    notifier.updateBudgetLine(
      event.id,
      line.id,
      label: result.$1,
      amount: result.$2,
    );
  }

  Future<void> _addCategory(
    BuildContext context,
    EventsNotifier notifier,
  ) async {
    final available = EventTemplates.availableCategoriesFor(event.budgetLines);
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All categories are already on this budget'),
        ),
      );
      return;
    }

    final result = await showAppGlassDialog<(BudgetCategoryOption, double)>(
      context: context,
      builder: (ctx) => _AddBudgetCategoryDialog(
        options: available,
        currency: event.currency,
      ),
    );
    if (result == null) return;
    notifier.addBudgetLine(event.id, label: result.$1.label, amount: result.$2);
  }

  void _showAiTips(BuildContext context) {
    final tips = EventTemplates.aiTipsFor(event);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colors = theme.colorScheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            context.gutter,
            0,
            context.gutter,
            MediaQuery.paddingOf(ctx).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.sparkles, color: colors.primary, size: 20),
                  const GutterSmall(),
                  Text(
                    'AI budget tips',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Gutter(),
              for (final tip in tips) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(tip, style: theme.textTheme.bodyMedium),
                  ),
                ),
                const GutterSmall(),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HealthBanner extends StatelessWidget {
  const _HealthBanner({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (icon, title, body, tone) = switch (event.budgetHealth) {
      BudgetHealth.healthy => (
        LucideIcons.circleCheck,
        'Budget looks sufficient',
        'Allocations fit your total and match the recommended range for this ${event.type.label.toLowerCase()}.',
        colors.primary,
      ),
      BudgetHealth.overAllocated => (
        LucideIcons.triangleAlert,
        'Over allocated — raise total or trim lines',
        'Categories sum to ${formatEventMoney(event.allocatedBudget)}, which is above your total of ${formatEventMoney(event.totalBudget)}.',
        AppColors.like,
      ),
      BudgetHealth.belowRecommended => (
        LucideIcons.trendingUp,
        'Consider increasing your budget',
        'For ~${event.guestCount} guests, a typical ${event.type.label.toLowerCase()} needs about ${formatEventMoney(event.recommendedBudget)}.',
        AppColors.like,
      ),
      BudgetHealth.underAllocated => (
        LucideIcons.pieChart,
        'Some budget is still unassigned',
        '${formatEventMoney(event.remainingBudget)} left to distribute across categories.',
        colors.tertiary,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: tone),
            const GutterSmall(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tone,
                    ),
                  ),
                  const GutterTiny(),
                  Text(
                    body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
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

class _BudgetLineTile extends ConsumerWidget {
  const _BudgetLineTile({
    required this.event,
    required this.line,
    required this.onEdit,
    required this.onDelete,
  });

  final Event event;
  final BudgetLine line;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Future<void> _linkVendors(BuildContext context, WidgetRef ref) async {
    final allLinks = ref
        .read(eventVendorLinksProvider)
        .where((l) => l.eventId == event.id)
        .toList(growable: false);
    if (allLinks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact vendors from the Vendors tab first'),
        ),
      );
      return;
    }

    final currentlyLinked = {
      for (final l in allLinks)
        if (l.budgetLineIds.contains(line.id)) l.vendorId,
    };

    final result = await showAppGlassDialog<Set<String>>(
      context: context,
      builder: (ctx) => _LinkVendorsToLineDialog(
        links: allLinks,
        initiallySelected: currentlyLinked,
      ),
    );
    if (result == null) return;

    final notifier = ref.read(eventVendorLinksProvider.notifier);
    for (final link in allLinks) {
      final shouldHave = result.contains(link.vendorId);
      final has = link.budgetLineIds.contains(line.id);
      if (shouldHave && !has) {
        await notifier.addBudgetLine(
          eventId: event.id,
          vendorId: link.vendorId,
          budgetLineId: line.id,
        );
      } else if (!shouldHave && has) {
        await notifier.removeBudgetLine(
          eventId: event.id,
          vendorId: link.vendorId,
          budgetLineId: line.id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pct = event.percentOfTotal(line);
    final linked = ref
        .watch(eventVendorLinksProvider)
        .where(
          (l) => l.eventId == event.id && l.budgetLineIds.contains(line.id),
        )
        .toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const GutterTiny(),
                        Text(
                          '${formatEventMoney(line.amount)} · ${pct.toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const GutterTiny(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (pct / 100).clamp(0.0, 1.0),
                            minHeight: 4,
                            backgroundColor: colors.outline.withValues(
                              alpha: 0.25,
                            ),
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _linkVendors(context, ref),
                  icon: Icon(
                    LucideIcons.userPlus,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  tooltip: 'Link vendors',
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  tooltip: 'Edit amount',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  tooltip: 'Remove',
                ),
              ],
            ),
            if (linked.isNotEmpty) ...[
              const GutterSmall(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final link in linked)
                    _LinkedVendorChip(
                      vendorId: link.vendorId,
                      onRemove: () => ref
                          .read(eventVendorLinksProvider.notifier)
                          .removeBudgetLine(
                            eventId: event.id,
                            vendorId: link.vendorId,
                            budgetLineId: line.id,
                          ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinkedVendorChip extends StatelessWidget {
  const _LinkedVendorChip({required this.vendorId, required this.onRemove});

  final String vendorId;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vendor = findVendorById(vendorId);
    final name = vendor?.name ?? 'Vendor';

    return InputChip(
      avatar: AppCachedAvatar(
        imageUrl: vendor?.imageUrl ?? '',
        radius: 12,
        fallbackName: name,
      ),
      label: Text(name, style: theme.textTheme.labelMedium),
      onDeleted: onRemove,
      deleteIconColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
    );
  }
}

class _LinkVendorsToLineDialog extends StatefulWidget {
  const _LinkVendorsToLineDialog({
    required this.links,
    required this.initiallySelected,
  });

  final List<EventVendorLink> links;
  final Set<String> initiallySelected;

  @override
  State<_LinkVendorsToLineDialog> createState() =>
      _LinkVendorsToLineDialogState();
}

class _LinkVendorsToLineDialogState extends State<_LinkVendorsToLineDialog> {
  late Set<String> _selected;

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
      title: const Text('Link vendors'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
          child: const Text('Save'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose vendors contacted for this event. Several can share '
            'this category.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const Gutter(),
          for (final link in widget.links) ...[
            Builder(
              builder: (context) {
                final vendor = findVendorById(link.vendorId);
                final name = vendor?.name ?? 'Vendor';
                final selected = _selected.contains(link.vendorId);
                return CheckboxListTile(
                  value: selected,
                  contentPadding: EdgeInsets.zero,
                  secondary: AppCachedAvatar(
                    imageUrl: vendor?.imageUrl ?? '',
                    radius: 18,
                    fallbackName: name,
                  ),
                  title: Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    vendor?.category ??
                        (link.isWorkingWith ? 'Working with' : 'Contacted'),
                  ),
                  activeColor: AppColors.primary,
                  onChanged: (on) {
                    setState(() {
                      if (on == true) {
                        _selected.add(link.vendorId);
                      } else {
                        _selected.remove(link.vendorId);
                      }
                    });
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _EditBudgetLineDialog extends StatefulWidget {
  const _EditBudgetLineDialog({required this.line, required this.currency});

  final BudgetLine line;
  final String currency;

  @override
  State<_EditBudgetLineDialog> createState() => _EditBudgetLineDialogState();
}

class _EditBudgetLineDialogState extends State<_EditBudgetLineDialog> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.line.label);
    _amountCtrl = TextEditingController(
      text: widget.line.amount.round().toString(),
    );
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppGlassDialog(
      title: const Text('Edit category'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_amountCtrl.text.trim());
            if (amount == null) return;
            final label = _labelCtrl.text.trim();
            if (label.isEmpty) return;
            Navigator.pop(context, (label, amount));
          },
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
          child: const Text('Save'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update the name and how much is allocated to this category.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
          ),
          const Gutter(),
          TextField(
            controller: _labelCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Category name',
              prefixIcon: Icon(LucideIcons.tag),
            ),
          ),
          const Gutter(),
          TextField(
            controller: _amountCtrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Amount allocated (${widget.currency})',
              prefixIcon: const Icon(LucideIcons.banknote),
              prefixText: '${widget.currency} ',
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBudgetCategoryDialog extends StatefulWidget {
  const _AddBudgetCategoryDialog({
    required this.options,
    required this.currency,
  });

  final List<BudgetCategoryOption> options;
  final String currency;

  @override
  State<_AddBudgetCategoryDialog> createState() =>
      _AddBudgetCategoryDialogState();
}

class _AddBudgetCategoryDialogState extends State<_AddBudgetCategoryDialog> {
  BudgetCategoryOption? _selected;
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final listHeight = (MediaQuery.sizeOf(context).height * 0.4).clamp(
      180.0,
      360.0,
    );

    return AppGlassDialog(
      title: const Text('Add category'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () {
                  final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
                  Navigator.pop(context, (
                    _selected!,
                    amount < 0 ? 0.0 : amount,
                  ));
                },
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
          child: const Text('Add'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tap a category to select it, then set the allocated amount.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
          ),
          const Gutter(),
          SizedBox(
            height: listHeight,
            child: ListView.separated(
              itemCount: widget.options.length,
              separatorBuilder: (_, _) => const GutterSmall(),
              itemBuilder: (context, index) {
                final option = widget.options[index];
                final selected = _selected == option;
                return Material(
                  color: colors.surfaceContainerHighest.withValues(
                    alpha: selected ? 0.55 : 0.35,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _selected = option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : colors.outline.withValues(alpha: 0.45),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.label,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const GutterTiny(),
                                Text(
                                  option.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(
                              LucideIcons.circleCheck,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Gutter(),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Amount allocated (${widget.currency})',
              prefixIcon: const Icon(LucideIcons.banknote),
              prefixText: '${widget.currency} ',
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.title,
    required this.subtitle,
    required this.initialAmount,
  });

  final String title;
  final String subtitle;
  final double initialAmount;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialAmount.round().toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppGlassDialog(
      title: Text(widget.title),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(_controller.text.trim());
            if (value == null) return;
            Navigator.pop(context, value);
          },
          child: const Text('Save'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.subtitle, style: Theme.of(context).textTheme.bodySmall),
          const Gutter(),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Amount (XAF)',
              prefixText: 'XAF ',
            ),
          ),
        ],
      ),
    );
  }
}
