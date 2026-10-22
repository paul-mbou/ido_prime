import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/providers/event_vendor_links_provider.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/utils/active_space_gate.dart';
import 'package:ido_prime/src/features/vendors/models/vendor.dart';
import 'package:ido_prime/src/features/vendors/providers/vendor_connection_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _VendorFilter { all, contacted, workingWith }

/// Event detail tab: vendors contacted for this event + category assignment.
class EventVendorsSection extends HookConsumerWidget {
  const EventVendorsSection({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final filter = useState(_VendorFilter.all);
    final links = ref
        .watch(eventVendorLinksProvider)
        .where((l) => l.eventId == event.id)
        .toList(growable: false);

    final filtered = switch (filter.value) {
      _VendorFilter.all => links,
      _VendorFilter.contacted =>
        links.where((l) => !l.isWorkingWith).toList(growable: false),
      _VendorFilter.workingWith =>
        links.where((l) => l.isWorkingWith).toList(growable: false),
    };

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.gutter,
        context.gutter,
        context.gutter,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        Text(
          'Vendors',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const GutterTiny(),
        Text(
          'Everyone you’ve contacted for this event. Assign a budget '
          'category when you’ve decided they’ll handle that piece.',
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
            for (final option in _VendorFilter.values)
              FilterChip(
                showCheckmark: false,
                selected: filter.value == option,
                label: Text(switch (option) {
                  _VendorFilter.all => 'All (${links.length})',
                  _VendorFilter.contacted =>
                    'Contacted (${links.where((l) => !l.isWorkingWith).length})',
                  _VendorFilter.workingWith =>
                    'Working with (${links.where((l) => l.isWorkingWith).length})',
                }),
                onSelected: (_) => filter.value = option,
              ),
          ],
        ),
        const Gutter(),
        if (filtered.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.gutterLarge),
            child: Column(
              children: [
                Icon(
                  LucideIcons.store,
                  size: 40,
                  color: colors.onSurfaceVariant,
                ),
                const GutterSmall(),
                Text(
                  links.isEmpty
                      ? 'No vendors for this event yet'
                      : 'No vendors in this filter',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const GutterTiny(),
                Text(
                  links.isEmpty
                      ? 'Find vendors and send a contact request — '
                            'they’ll appear here after they accept.'
                      : 'Try another filter or assign a budget category.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Gutter(),
                FilledButton.icon(
                  onPressed: () =>
                      context.go(AppRoutes.vendorsForEvent(event.id)),
                  icon: const Icon(LucideIcons.search, size: 18),
                  label: const Text('Find vendors'),
                  style: FilledButton.styleFrom(shape: const StadiumBorder()),
                ),
              ],
            ),
          )
        else
          for (final link in filtered) ...[
            _EventVendorTile(event: event, link: link),
            const GutterSmall(),
          ],
        if (links.isNotEmpty) ...[
          const Gutter(),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.vendorsForEvent(event.id)),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Find more vendors'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ],
    );
  }
}

class _EventVendorTile extends ConsumerWidget {
  const _EventVendorTile({required this.event, required this.link});

  final Event event;
  final EventVendorLink link;

  Future<void> _assignCategories(BuildContext context, WidgetRef ref) async {
    final selected = link.budgetLineIds.toSet();
    final result = await showAppGlassDialog<Set<String>>(
      context: context,
      builder: (ctx) => _AssignCategoriesDialog(
        lines: event.budgetLines,
        initiallySelected: selected,
      ),
    );
    if (result == null) return;
    await ref
        .read(eventVendorLinksProvider.notifier)
        .setBudgetLineIds(
          eventId: event.id,
          vendorId: link.vendorId,
          budgetLineIds: result.toList(),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final vendor = findVendorById(link.vendorId);
    final name = vendor?.name ?? 'Vendor';
    final category = vendor?.category ?? '';
    final imageUrl = vendor?.imageUrl ?? '';

    final lineLabels = [
      for (final id in link.budgetLineIds)
        for (final line in event.budgetLines)
          if (line.id == id) line.label,
    ];

    final connection = ref.watch(vendorConnectionProvider(link.vendorId));
    final canChat = connection?.status == VendorConnectionStatus.accepted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.65)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppCachedAvatar(
                  imageUrl: imageUrl,
                  radius: 22,
                  fallbackName: name,
                ),
                const GutterSmall(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (category.isNotEmpty)
                        Text(
                          category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        link.isWorkingWith ? 'Working with' : 'Contacted',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: link.isWorkingWith
                              ? AppColors.primary
                              : colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Open profile',
                  onPressed: () =>
                      context.push(AppRoutes.vendorProfile(link.vendorId)),
                  icon: const Icon(LucideIcons.user, size: 18),
                ),
                IconButton(
                  tooltip: canChat ? 'Open chat' : 'Chat after accept',
                  onPressed: canChat
                      ? () {
                          runInActiveSpace(
                            context,
                            ref,
                            requiredSpace: ActiveSpace.planner,
                            actionLabel: 'message this vendor',
                            message:
                                'Vendor accounts can’t message other vendors. '
                                'Switch to Planner to continue this event chat.',
                            action: () => context.push(
                              AppRoutes.vendorChat(link.vendorId),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(LucideIcons.messageCircle, size: 18),
                ),
              ],
            ),
            if (lineLabels.isNotEmpty) ...[
              const GutterSmall(),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final label in lineLabels)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const GutterSmall(),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _assignCategories(context, ref),
                  icon: const Icon(LucideIcons.tags, size: 16),
                  label: Text(
                    link.isWorkingWith
                        ? 'Edit categories'
                        : 'Assign categories',
                  ),
                ),
                if (link.isWorkingWith)
                  TextButton(
                    onPressed: () => ref
                        .read(eventVendorLinksProvider.notifier)
                        .clearBudgetLines(
                          eventId: event.id,
                          vendorId: link.vendorId,
                        ),
                    child: const Text('Clear categories'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignCategoriesDialog extends StatefulWidget {
  const _AssignCategoriesDialog({
    required this.lines,
    required this.initiallySelected,
  });

  final List<BudgetLine> lines;
  final Set<String> initiallySelected;

  @override
  State<_AssignCategoriesDialog> createState() =>
      _AssignCategoriesDialogState();
}

class _AssignCategoriesDialogState extends State<_AssignCategoriesDialog> {
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
      title: const Text('Assign categories'),
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
            'Select one or more budget categories this vendor will handle. '
            'Several vendors can share a category.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const Gutter(),
          if (widget.lines.isEmpty)
            Text(
              'Add budget categories first on the Budget tab.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final line in widget.lines)
                  FilterChip(
                    showCheckmark: false,
                    selected: _selected.contains(line.id),
                    label: Text(line.label),
                    onSelected: (on) {
                      setState(() {
                        if (on) {
                          _selected.add(line.id);
                        } else {
                          _selected.remove(line.id);
                        }
                      });
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
