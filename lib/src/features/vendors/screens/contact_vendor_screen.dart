import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/vendor_onboarding/models/vendor_business.dart';
import 'package:ido_prime/src/features/vendor_onboarding/providers/vendor_onboarding_providers.dart';
import 'package:ido_prime/src/features/vendors/models/vendor.dart';
import 'package:ido_prime/src/features/vendors/providers/vendor_chat_provider.dart';
import 'package:ido_prime/src/features/vendors/providers/vendor_connection_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
// import 'package:url_launcher/url_launcher.dart';

/// Planner contact form + LinkedIn-style connection request review.
/// Chat opens only after the vendor accepts.
class ContactVendorScreen extends HookConsumerWidget {
  const ContactVendorScreen({super.key, required this.vendorId, this.eventId});

  final String vendorId;
  final String? eventId;

  static const _prompts = <String>[
    'Request a quote',
    'Check availability',
    'Ask about packages',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = findVendorById(vendorId);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;
    final frosted = useState(false);
    final connection = ref.watch(vendorConnectionProvider(vendorId));
    final space = ref.watch(activeSpaceProvider);
    final isVendorSpace = space == ActiveSpace.vendor;
    final events = ref.watch(eventsProvider);
    final myEvents = events.where((e) => e.isMine).toList(growable: false);

    final initialEventId = () {
      final fromRoute = eventId?.trim();
      if (fromRoute != null && fromRoute.isNotEmpty) {
        for (final e in myEvents) {
          if (e.id == fromRoute) return fromRoute;
        }
      }
      return myEvents.isEmpty ? null : myEvents.first.id;
    }();

    final selectedEventId = useState<String?>(initialEventId);

    String eventNameFor(String? id) {
      if (id == null) return 'my event';
      for (final e in myEvents) {
        if (e.id == id) return e.title;
      }
      return 'my event';
    }

    final selectedEventName = eventNameFor(selectedEventId.value);

    final messageController = useTextEditingController(
      text:
          'Hi! I\'m planning my $selectedEventName and would love to learn more '
          'about your services.',
    );
    final selectedPrompt = useState<String?>(null);
    final sending = useState(false);

    if (vendor == null) {
      return Scaffold(
        appBar: const AppFrostedAppBar(title: Text('Contact')),
        body: Center(
          child: Text(
            'Vendor not found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Once accepted, jump into the in-app chat.
    useEffect(() {
      if (connection?.status == VendorConnectionStatus.accepted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.replace(AppRoutes.vendorChat(vendorId));
        });
      }
      return null;
    }, [connection?.status]);

    Future<void> sendRequest() async {
      final text = messageController.text.trim();
      if (text.isEmpty) {
        context.showErrorSnackBar('Write a short message first');
        return;
      }
      final eid = selectedEventId.value;
      if (eid == null || eid.isEmpty) {
        context.showErrorSnackBar('Choose an event for this request');
        return;
      }
      sending.value = true;
      await ref
          .read(vendorConnectionProvider(vendorId).notifier)
          .sendRequest(
            eventName: eventNameFor(eid),
            eventId: eid,
            message: text,
            prompt: selectedPrompt.value,
          );
      if (!context.mounted) return;
      sending.value = false;
      context.showSnackBar('Connection request sent to ${vendor.name}');
    }

    // Future: restore external tel/mailto when needed.
    // Future<void> openUri(Uri uri, String fallback) async {
    //   try {
    //     final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    //     if (!ok && context.mounted) context.showSnackBar(fallback);
    //   } catch (_) {
    //     if (context.mounted) context.showSnackBar(fallback);
    //   }
    // }

    final appBarExtent = MediaQuery.paddingOf(context).top + kToolbarHeight - 4;

    final status = connection?.status ?? VendorConnectionStatus.none;
    final showVendorReview =
        status == VendorConnectionStatus.pending && isVendorSpace;
    final showPlannerPending =
        status == VendorConnectionStatus.pending && !isVendorSpace;
    final showDeclined = status == VendorConnectionStatus.declined;
    final showForm =
        status == VendorConnectionStatus.none ||
        (showDeclined && !isVendorSpace);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppFrostedAppBar(
        frosted: frosted.value,
        title: Text(
          showVendorReview ? 'Connection request' : 'Contact',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final next = notification.metrics.pixels > 2;
          if (next != frosted.value) frosted.value = next;
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      appBarExtent,
                      gutter,
                      gutter,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _VendorContactHeader(vendor: vendor),
                        const Gutter(),
                        if (showVendorReview && connection != null) ...[
                          _RequestReviewCard(request: connection),
                        ] else if (showPlannerPending &&
                            connection != null) ...[
                          _PendingRequestCard(
                            request: connection,
                            vendorName: vendor.name,
                            onReviewAsVendor: () async {
                              await ref
                                  .read(activeSpaceProvider.notifier)
                                  .setSpace(ActiveSpace.vendor);
                              if (context.mounted) {
                                context.showSnackBar(
                                  'Switched to Vendor — accept or decline below',
                                );
                              }
                            },
                          ),
                        ] else if (showDeclined && connection != null) ...[
                          _DeclinedCard(
                            vendorName: vendor.name,
                            onRetry: () => ref
                                .read(
                                  vendorConnectionProvider(vendorId).notifier,
                                )
                                .reset(),
                          ),
                        ] else if (showForm) ...[
                          Text(
                            'Event',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const GutterSmall(),
                          if (myEvents.isEmpty)
                            Text(
                              'Create an event first so this request is linked to a plan.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final event in myEvents)
                                  FilterChip(
                                    showCheckmark: false,
                                    selected: selectedEventId.value == event.id,
                                    label: Text(event.title),
                                    onSelected: (_) {
                                      selectedEventId.value = event.id;
                                      messageController.text =
                                          'Hi! I\'m planning my ${event.title} and '
                                          'would love to learn more about your services.';
                                    },
                                  ),
                              ],
                            ),
                          const Gutter(),
                          Text(
                            'Quick asks',
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
                              for (final prompt in _prompts)
                                _PromptChip(
                                  label: prompt,
                                  selected: selectedPrompt.value == prompt,
                                  onTap: () {
                                    selectedPrompt.value = prompt;
                                    messageController.text =
                                        'Hi ${vendor.name} — $prompt for my '
                                        '$selectedEventName. '
                                        'Could you share details and next steps?';
                                    messageController
                                        .selection = TextSelection.fromPosition(
                                      TextPosition(
                                        offset: messageController.text.length,
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                          const Gutter(),
                          Text(
                            'Your message',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const GutterSmall(),
                          TextField(
                            controller: messageController,
                            minLines: 5,
                            maxLines: 8,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText:
                                  'Share dates, guest count, or what you need…',
                              filled: true,
                              fillColor: colors.surface,
                              alignLabelWithHint: true,
                            ),
                          ),
                          const Gutter(),
                          Text(
                            'Contact is always tied to one of your events. '
                            'Sending a request does not open a chat yet — '
                            'after the vendor accepts, you can message inside IDO.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            if (showForm)
              _BottomBar(
                child: FilledButton(
                  onPressed: sending.value || myEvents.isEmpty
                      ? null
                      : sendRequest,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: const StadiumBorder(),
                  ),
                  child: sending.value
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colors.onPrimary,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.send, size: 18),
                            GutterSmall(),
                            Text('Send request'),
                          ],
                        ),
                ),
              )
            else if (showVendorReview)
              _BottomBar(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await ref
                              .read(vendorConnectionProvider(vendorId).notifier)
                              .decline();
                          if (context.mounted) {
                            context.showSnackBar('Request declined');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          foregroundColor: AppColors.like,
                          side: const BorderSide(color: AppColors.like),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const GutterSmall(),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          await ref
                              .read(vendorConnectionProvider(vendorId).notifier)
                              .accept();
                          await ref
                              .read(vendorChatProvider(vendorId).notifier)
                              .bootstrapFromRequest(connection?.message ?? '');
                          if (context.mounted) {
                            context.showSnackBar('Chat started');
                            context.replace(AppRoutes.vendorChat(vendorId));
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              )
            else if (showPlannerPending)
              _BottomBar(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Done'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;

    return Material(
      color: theme.navigationBarTheme.backgroundColor ?? colors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(gutter, 10, gutter, 10),
          child: child,
        ),
      ),
    );
  }
}

class _RequestReviewCard extends StatelessWidget {
  const _RequestReviewCard({required this.request});

  final VendorConnectionRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
          children: [
            Text(
              'New connection request',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const GutterTiny(),
            Text(
              'An organizer wants to connect. Review the details, then accept '
              'to start an in-app chat — or decline.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const Gutter(),
            _EventContextChip(eventName: request.eventName),
            if (request.prompt != null) ...[
              const GutterSmall(),
              Text(
                'Intent: ${request.prompt}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const Gutter(),
            Text(
              'Message',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const GutterTiny(),
            Text(
              request.message,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.request,
    required this.vendorName,
    required this.onReviewAsVendor,
  });

  final VendorConnectionRequest request;
  final String vendorName;
  final VoidCallback onReviewAsVendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
          children: [
            Row(
              children: [
                Icon(LucideIcons.clock3, size: 20, color: colors.primary),
                const GutterSmall(),
                Expanded(
                  child: Text(
                    'Waiting for $vendorName',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const GutterSmall(),
            Text(
              'Your connection request was sent. Chat unlocks only after they '
              'accept — just like a LinkedIn intro.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const Gutter(),
            _EventContextChip(eventName: request.eventName),
            if (request.prompt != null) ...[
              const GutterSmall(),
              Text(
                'Intent: ${request.prompt}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const Gutter(),
            Text(
              request.message,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            const Gutter(),
            OutlinedButton(
              onPressed: onReviewAsVendor,
              style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
              child: const Text('Review as vendor (demo)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeclinedCard extends StatelessWidget {
  const _DeclinedCard({required this.vendorName, required this.onRetry});

  final String vendorName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
          children: [
            Text(
              'Request declined',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const GutterSmall(),
            Text(
              '$vendorName declined this connection. You can send a new request '
              'later with updated details.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const Gutter(),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(shape: const StadiumBorder()),
              child: const Text('Send a new request'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorContactHeader extends StatelessWidget {
  const _VendorContactHeader({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72,
                height: 72,
                child: AppCachedNetworkImage(
                  imageUrl: vendor.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Gutter(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          vendor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (vendor.isVerified) ...[
                        const GutterTiny(),
                        Icon(
                          LucideIcons.badgeCheck,
                          size: 18,
                          color: colors.primary,
                        ),
                      ],
                    ],
                  ),
                  const GutterTiny(),
                  Text(
                    vendor.category,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const GutterTiny(),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 14,
                        color: colors.onSurfaceVariant,
                      ),
                      const Gutter.custom(size: 4),
                      Text(
                        vendor.location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
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

class _EventContextChip extends StatelessWidget {
  const _EventContextChip({required this.eventName});

  final String eventName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.calendar, size: 16, color: colors.primary),
            const GutterTiny(),
            Text(
              'About: $eventName',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.primary : colors.outline,
            ),
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

// External Call / Email actions — paused (in-app messaging only for now).
// class _DirectAction extends StatelessWidget {
//   const _DirectAction({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;
//
//     return OutlinedButton(
//       onPressed: onTap,
//       style: OutlinedButton.styleFrom(
//         minimumSize: const Size(0, 48),
//         foregroundColor: colors.onSurface,
//         backgroundColor: colors.surface,
//         side: BorderSide(color: colors.outline),
//         shape: const StadiumBorder(),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [Icon(icon, size: 18), const GutterTiny(), Text(label)],
//       ),
//     );
//   }
// }
