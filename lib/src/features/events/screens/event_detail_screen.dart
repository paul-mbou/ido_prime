import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/providers/event_vendor_links_provider.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/events/widgets/event_budget_section.dart';
import 'package:ido_prime/src/features/events/widgets/event_invitation_section.dart';
import 'package:ido_prime/src/features/events/widgets/event_tasks_section.dart';
import 'package:ido_prime/src/features/events/widgets/event_tickets_section.dart';
import 'package:ido_prime/src/features/events/widgets/event_vendors_section.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(eventsProvider).where((e) => e.id == eventId);
    final event = matches.isEmpty ? null : matches.first;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (event == null) {
      return Scaffold(
        appBar: const AppFrostedAppBar(title: Text('Event')),
        body: Center(
          child: Text(
            'Event not found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (!event.isMine) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppFrostedAppBar(
          title: Text(
            event.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: _OverviewBody(event: event),
      );
    }

    final pending = event.invitation.pendingCount;
    final showTickets = event.isPaidEntry;
    final vendorLinks = ref
        .watch(eventVendorLinksProvider)
        .where((l) => l.eventId == event.id)
        .length;
    final tabCount = showTickets ? 6 : 5;

    return DefaultTabController(
      length: tabCount,
      child: Scaffold(
        appBar: AppFrostedAppBar(
          title: Text(
            event.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              const Tab(text: 'Overview'),
              const Tab(text: 'Budget'),
              Tab(text: vendorLinks > 0 ? 'Vendors ($vendorLinks)' : 'Vendors'),
              Tab(text: 'Tasks (${event.doneTaskCount}/${event.tasks.length})'),
              Tab(text: pending > 0 ? 'Invites ($pending)' : 'Invites'),
              if (showTickets) const Tab(text: 'Tickets'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewBody(event: event, showFindVendors: true),
            ListView(
              padding: EdgeInsets.fromLTRB(
                context.gutter,
                context.gutter,
                context.gutter,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [EventBudgetSection(event: event)],
            ),
            EventVendorsSection(event: event),
            ListView(
              padding: EdgeInsets.fromLTRB(
                context.gutter,
                context.gutter,
                context.gutter,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [EventTasksSection(event: event)],
            ),
            EventInvitationSection(event: event),
            if (showTickets)
              ListView(
                padding: EdgeInsets.fromLTRB(
                  context.gutter,
                  context.gutter,
                  context.gutter,
                  MediaQuery.paddingOf(context).bottom + 24,
                ),
                children: [EventTicketsSection(event: event)],
              ),
          ],
        ),
      ),
    );
  }
}

class _OverviewBody extends ConsumerWidget {
  const _OverviewBody({required this.event, this.showFindVendors = false});

  final Event event;
  final bool showFindVendors;

  void _goToTab(BuildContext context, int index) {
    final controller = DefaultTabController.maybeOf(context);
    if (controller == null || index < 0 || index >= controller.length) {
      return;
    }
    controller.animateTo(index);
  }

  Future<void> _editAbout(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: event.description);
    final result = await showAppGlassDialog<String>(
      context: context,
      builder: (ctx) {
        return AppGlassDialog(
          title: const Text('About this event'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              style: FilledButton.styleFrom(shape: const StadiumBorder()),
              child: const Text('Save'),
            ),
          ],
          child: TextField(
            controller: ctrl,
            autofocus: true,
            maxLines: 5,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Share a short note about this celebration…',
              alignLabelWithHint: true,
            ),
          ),
        );
      },
    );
    // Dispose after the dialog route finishes its exit animation.
    Future<void>.delayed(const Duration(milliseconds: 300), ctrl.dispose);
    if (result == null) return;
    ref.read(eventsProvider.notifier).updateDescription(event.id, result);
  }

  Future<void> _changeVisibility(BuildContext context, WidgetRef ref) async {
    final picked = await showAppGlassDialog<EventVisibility>(
      context: context,
      builder: (ctx) {
        return AppGlassDialog(
          title: const Text('Event visibility'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in EventVisibility.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    switch (option) {
                      EventVisibility.private => LucideIcons.lock,
                      EventVisibility.friends => LucideIcons.users,
                      EventVisibility.public => LucideIcons.globe,
                    },
                    color: option == event.visibility
                        ? AppColors.primary
                        : null,
                  ),
                  title: Text(option.label),
                  subtitle: Text(option.subtitle),
                  trailing: option == event.visibility
                      ? const Icon(
                          LucideIcons.circleCheck,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(ctx, option),
                ),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      ref.read(eventsProvider.notifier).updateVisibility(event.id, picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppCachedNetworkImage(
                imageUrl: event.coverUrl,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.zero,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                    ],
                    stops: const [0.4, 1],
                  ),
                ),
              ),
              Positioned(
                left: context.gutter,
                right: context.gutter,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Pill(label: event.statusLabel, filled: true),
                        const GutterSmall(),
                        _Pill(label: event.type.label),
                        if (event.isMine) ...[
                          const GutterSmall(),
                          _Pill(label: event.visibility.label),
                        ],
                        const GutterSmall(),
                        _Pill(label: event.entryType.label),
                      ],
                    ),
                    const GutterSmall(),
                    Text(
                      event.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoCard(
                children: [
                  _DetailRow(
                    icon: LucideIcons.calendarDays,
                    label: 'Date',
                    value: event.dateLabel,
                  ),
                  const Gutter(),
                  _DetailRow(
                    icon: LucideIcons.mapPin,
                    label: 'Place',
                    value: event.place,
                  ),
                  const Gutter(),
                  _DetailRow(
                    icon: event.isPaidEntry
                        ? LucideIcons.ticket
                        : LucideIcons.gift,
                    label: 'Entry',
                    value: event.isPaidEntry && event.ticketPage.price > 0
                        ? 'Paid · ${formatEventMoney(event.ticketPage.price)}'
                        : event.entryType.label,
                  ),
                  if (event.isMine) ...[
                    const Gutter(),
                    _DetailRow(
                      icon: LucideIcons.eye,
                      label: 'Visibility',
                      value: event.visibility.label,
                    ),
                  ],
                  if (event.theme.isNotEmpty) ...[
                    const Gutter(),
                    _DetailRow(
                      icon: LucideIcons.palette,
                      label: 'Theme',
                      value: event.theme,
                    ),
                  ],
                  if (!event.isMine && event.hostName.isNotEmpty) ...[
                    const Gutter(),
                    _DetailRow(
                      icon: LucideIcons.user,
                      label: 'Hosted by',
                      value: event.hostName,
                    ),
                  ],
                ],
              ),
              if (event.isMine) ...[
                const GutterSmall(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _changeVisibility(context, ref),
                    icon: const Icon(LucideIcons.pencil, size: 16),
                    label: const Text('Change visibility'),
                  ),
                ),
              ],
              const Gutter(),
              if (event.isMine) ...[
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: LucideIcons.users,
                        value: '${event.guestCount}',
                        label: 'Guests',
                        onTap: () => _goToTab(context, 4),
                      ),
                    ),
                    const GutterSmall(),
                    Expanded(
                      child: _StatTile(
                        icon: LucideIcons.store,
                        value:
                            '${ref.watch(eventVendorLinksProvider).where((l) => l.eventId == event.id).length}',
                        label: 'Vendors',
                        onTap: () => _goToTab(context, 2),
                      ),
                    ),
                  ],
                ),
                const GutterSmall(),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: LucideIcons.wallet,
                        value: formatEventMoney(
                          event.totalBudget,
                          currency: '',
                        ).trim(),
                        label: event.currency,
                        onTap: () => _goToTab(context, 1),
                      ),
                    ),
                    const GutterSmall(),
                    Expanded(
                      child: _StatTile(
                        icon: LucideIcons.listChecks,
                        value: '${event.doneTaskCount}/${event.tasks.length}',
                        label: 'Tasks',
                        onTap: () => _goToTab(context, 3),
                      ),
                    ),
                  ],
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: LucideIcons.users,
                        value: '${event.guestCount}',
                        label: 'Guests',
                      ),
                    ),
                    if (event.vendorCount > 0) ...[
                      const GutterSmall(),
                      Expanded(
                        child: _StatTile(
                          icon: LucideIcons.store,
                          value: '${event.vendorCount}',
                          label: 'Vendors',
                        ),
                      ),
                    ],
                  ],
                ),
              if (event.isMine || event.description.isNotEmpty) ...[
                const Gutter(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'About',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (event.isMine)
                      TextButton.icon(
                        onPressed: () => _editAbout(context, ref),
                        icon: const Icon(LucideIcons.pencil, size: 16),
                        label: Text(event.description.isEmpty ? 'Add' : 'Edit'),
                      ),
                  ],
                ),
                if (!event.isMine) const GutterSmall(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: event.isMine
                          ? () => _editAbout(context, ref)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          event.description.isEmpty
                              ? 'Add a short description for your event…'
                              : event.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                            color: event.description.isEmpty
                                ? colors.onSurfaceVariant
                                : colors.onSurface,
                            fontStyle: event.description.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (showFindVendors) ...[
                const GutterLarge(),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.go(AppRoutes.vendorsForEvent(event.id)),
                  icon: const Icon(LucideIcons.store, size: 18),
                  label: const Text('Find vendors'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: const StadiumBorder(),
                    side: BorderSide(
                      color: colors.outline.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.filled = false});

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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const GutterSmall(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const GutterTiny(),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Column(
              children: [
                Icon(icon, size: 18, color: colors.primary),
                const GutterTiny(),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
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
