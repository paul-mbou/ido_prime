import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/models/event_invitation.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/events/utils/invitation_share_image.dart';
import 'package:ido_prime/src/features/events/utils/invitee_guest_list_pdf.dart';
import 'package:ido_prime/src/features/events/widgets/invitation_card_preview.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class EventInvitationSection extends HookConsumerWidget {
  const EventInvitationSection({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final notifier = ref.read(eventsProvider.notifier);
    final invitation = event.invitation;
    final filter = useState<InviteeStatus?>(null);
    final messageCtrl = useTextEditingController(text: invitation.message);
    final headlineCtrl = useTextEditingController(text: invitation.headline);
    final exporting = useState(false);
    final sharing = useState(false);

    useEffect(() {
      messageCtrl.text = invitation.message;
      headlineCtrl.text = invitation.headline;
      return null;
    }, [event.id, invitation.message, invitation.headline]);

    final filtered = [
      for (final invitee in invitation.invitees)
        if (filter.value == null || invitee.status == filter.value) invitee,
    ];

    Future<void> shareInvitation() async {
      if (sharing.value) return;
      sharing.value = true;
      final link = eventInviteLink(event.id);
      final headline = invitation.headline.trim().isEmpty
          ? event.title
          : invitation.headline.trim();
      final text =
          '$headline\n'
          '${invitation.message}\n\n'
          'RSVP: $link';
      try {
        final file = await buildInvitationSharePng(context, event);
        if (!context.mounted) return;
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile(
                file.path,
                mimeType: 'image/png',
                name: '${event.title}_invitation.png',
              ),
            ],
            text: text,
            subject: event.title,
          ),
        );
      } catch (_) {
        // Fallback to text-only share if image capture fails.
        if (!context.mounted) return;
        await SharePlus.instance.share(
          ShareParams(text: text, subject: event.title),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shared as text — image could not be generated'),
            ),
          );
        }
      } finally {
        sharing.value = false;
      }
    }

    Future<void> copyLink() async {
      final link = eventInviteLink(event.id);
      await Clipboard.setData(ClipboardData(text: link));
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invite link copied')));
    }

    Future<void> exportPdf() async {
      if (invitation.acceptedCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No accepted guests to export yet')),
        );
        return;
      }
      exporting.value = true;
      try {
        final bytes = await buildAcceptedInviteesPdf(event);
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: '${event.title}_guest_list.pdf',
        );
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not generate PDF')),
          );
        }
      } finally {
        exporting.value = false;
      }
    }

    Future<void> editGuestCount() async {
      final ctrl = TextEditingController(text: event.guestCount.toString());
      final result = await showAppGlassDialog<int>(
        context: context,
        builder: (ctx) {
          return AppGlassDialog(
            title: const Text('Expected guests'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final parsed = int.tryParse(ctrl.text.trim());
                  Navigator.pop(ctx, parsed);
                },
                style: FilledButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Save'),
              ),
            ],
            child: TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Guest count',
                prefixIcon: Icon(LucideIcons.users),
              ),
            ),
          );
        },
      );
      // Dispose after the dialog route finishes its exit animation.
      Future<void>.delayed(const Duration(milliseconds: 300), ctrl.dispose);
      if (result == null) return;
      notifier.updateGuestCount(event.id, result);
    }

    Future<void> editCopy() async {
      final result = await showAppGlassDialog<(String, String)>(
        context: context,
        builder: (ctx) {
          final h = TextEditingController(text: headlineCtrl.text);
          final m = TextEditingController(text: messageCtrl.text);
          return AppGlassDialog(
            title: const Text('Invitation copy'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, (h.text, m.text)),
                style: FilledButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Save'),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: h,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Headline (optional)',
                    hintText: 'Uses event title if empty',
                  ),
                ),
                const Gutter(),
                TextField(
                  controller: m,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          );
        },
      );
      if (result == null) return;
      headlineCtrl.text = result.$1;
      messageCtrl.text = result.$2;
      notifier.updateInvitationCopy(
        event.id,
        headline: result.$1.trim(),
        message: result.$2.trim(),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.gutter,
        context.gutter,
        context.gutter,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.18),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      LucideIcons.users,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Gutter(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expected guests',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const GutterTiny(),
                      Text(
                        '${event.guestCount}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: editGuestCount,
                  icon: const Icon(LucideIcons.pencil, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ),
        ),
        const Gutter(),
        Text(
          'Invitation card',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const GutterSmall(),
        InvitationCardPreview(event: event),
        const Gutter(),
        Text(
          'Card style',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const GutterSmall(),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final style in InvitationCardStyle.values)
              ChoiceChip(
                label: Text(style.label),
                selected: invitation.cardStyle == style,
                showCheckmark: false,
                onSelected: (_) =>
                    notifier.setInvitationCardStyle(event.id, style),
                selectedColor: AppColors.primary.withValues(alpha: 0.22),
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: invitation.cardStyle == style
                      ? AppColors.primary
                      : colors.onSurface,
                ),
                side: BorderSide(
                  color: invitation.cardStyle == style
                      ? AppColors.primary
                      : colors.outline.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
        const GutterTiny(),
        Text(
          invitation.cardStyle.subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const Gutter(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: editCopy,
                icon: const Icon(LucideIcons.penLine, size: 16),
                label: const Text('Edit copy'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const GutterSmall(),
            Expanded(
              child: FilledButton.icon(
                onPressed: sharing.value ? null : shareInvitation,
                icon: sharing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.share2, size: 16),
                label: Text(sharing.value ? 'Preparing…' : 'Share card'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
        const GutterSmall(),
        OutlinedButton.icon(
          onPressed: copyLink,
          icon: const Icon(LucideIcons.copy, size: 16),
          label: Text(
            eventInviteLink(event.id),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: const StadiumBorder(),
          ),
        ),
        const GutterLarge(),
        Text(
          'RSVP settings',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const GutterSmall(),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
          ),
          child: SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: Text(
              'Auto-accept guests',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              invitation.autoAccept
                  ? 'New RSVPs are accepted automatically.'
                  : 'You approve or reject each person manually.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            value: invitation.autoAccept,
            activeThumbColor: AppColors.onPrimary,
            activeTrackColor: AppColors.primary,
            onChanged: (value) =>
                notifier.setInvitationAutoAccept(event.id, value),
          ),
        ),
        const GutterLarge(),
        Row(
          children: [
            Expanded(
              child: Text(
                'Invitees',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: exporting.value ? null : exportPdf,
              icon: exporting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.fileDown, size: 16),
              label: const Text('PDF list'),
            ),
          ],
        ),
        const GutterTiny(),
        Text(
          '${invitation.acceptedCount} accepted · '
          '${invitation.pendingCount} pending · '
          '${invitation.rejectedCount} rejected'
          '${invitation.acceptedHeadcount > 0 ? ' · ${invitation.acceptedHeadcount} seats' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const GutterSmall(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All (${invitation.invitees.length})',
                selected: filter.value == null,
                onTap: () => filter.value = null,
              ),
              const GutterSmall(),
              _FilterChip(
                label: 'Pending (${invitation.pendingCount})',
                selected: filter.value == InviteeStatus.pending,
                onTap: () => filter.value = InviteeStatus.pending,
              ),
              const GutterSmall(),
              _FilterChip(
                label: 'Accepted (${invitation.acceptedCount})',
                selected: filter.value == InviteeStatus.accepted,
                onTap: () => filter.value = InviteeStatus.accepted,
              ),
              const GutterSmall(),
              _FilterChip(
                label: 'Rejected (${invitation.rejectedCount})',
                selected: filter.value == InviteeStatus.rejected,
                onTap: () => filter.value = InviteeStatus.rejected,
              ),
            ],
          ),
        ),
        const Gutter(),
        if (filtered.isEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.mailOpen,
                    color: colors.onSurfaceVariant,
                    size: 28,
                  ),
                  const GutterSmall(),
                  Text(
                    filter.value == null
                        ? 'No responses yet — share your invite link.'
                        : 'No ${filter.value!.label.toLowerCase()} guests.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < filtered.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: colors.outline.withValues(alpha: 0.45),
                    ),
                  _InviteeTile(
                    invitee: filtered[i],
                    onAccept: () => notifier.setInviteeStatus(
                      event.id,
                      filtered[i].id,
                      InviteeStatus.accepted,
                    ),
                    onReject: () => notifier.setInviteeStatus(
                      event.id,
                      filtered[i].id,
                      InviteeStatus.rejected,
                    ),
                    onResetPending: () => notifier.setInviteeStatus(
                      event.id,
                      filtered[i].id,
                      InviteeStatus.pending,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      color: selected
          ? AppColors.primary.withValues(alpha: 0.2)
          : colors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : colors.outline.withValues(alpha: 0.7),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteeTile extends StatelessWidget {
  const _InviteeTile({
    required this.invitee,
    required this.onAccept,
    required this.onReject,
    required this.onResetPending,
  });

  final EventInvitee invitee;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onResetPending;

  Color _statusColor(InviteeStatus status) => switch (status) {
    InviteeStatus.pending => AppColors.primary,
    InviteeStatus.accepted => const Color(0xFF3D9A6A),
    InviteeStatus.rejected => AppColors.like,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = _statusColor(invitee.status);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCachedAvatar(
            imageUrl: invitee.avatarUrl,
            radius: 22,
            fallbackName: invitee.name,
          ),
          const Gutter(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        invitee.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          invitee.status.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (invitee.email.isNotEmpty) ...[
                  const Gutter.custom(size: 4),
                  Text(
                    invitee.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (invitee.plusOnes > 0 || invitee.note.isNotEmpty) ...[
                  const Gutter.custom(size: 4),
                  Text(
                    [
                      if (invitee.plusOnes > 0) '+${invitee.plusOnes} guest(s)',
                      if (invitee.note.isNotEmpty) invitee.note,
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                const GutterSmall(),
                Row(
                  children: [
                    if (invitee.status != InviteeStatus.accepted)
                      TextButton(
                        onPressed: onAccept,
                        child: const Text('Accept'),
                      ),
                    if (invitee.status != InviteeStatus.rejected)
                      TextButton(
                        onPressed: onReject,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.like,
                        ),
                        child: const Text('Reject'),
                      ),
                    if (invitee.status != InviteeStatus.pending)
                      TextButton(
                        onPressed: onResetPending,
                        child: const Text('Pending'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
