import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/shared/widgets/app_glass_dialog.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/models/event_templates.dart';
import 'package:ido_prime/src/features/events/providers/event_draft_provider.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/events/widgets/event_date_picker_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Multi-step funnel: Type → Details → Visibility → Entry → Budget → Review.
class CreateEventScreen extends HookConsumerWidget {
  const CreateEventScreen({super.key});

  static const _stepCount = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final step = useState(0);
    final titleCtrl = useTextEditingController();
    final placeCtrl = useTextEditingController();
    final descriptionCtrl = useTextEditingController();
    final guestsCtrl = useTextEditingController(text: '80');
    final budgetCtrl = useTextEditingController(text: '2000000');
    final ticketTitleCtrl = useTextEditingController();
    final ticketDescCtrl = useTextEditingController();
    final ticketPriceCtrl = useTextEditingController();
    final ticketQtyCtrl = useTextEditingController();
    final type = useState(EventType.wedding);
    final eventDate = useState<DateTime?>(null);
    final guests = useState(80);
    final budget = useState(2_000_000.0);
    final visibility = useState(EventVisibility.private);
    final entryType = useState(EventEntryType.free);
    final coverPath = useState('');
    final saving = useState(false);
    final draftPrompted = useRef(false);

    EventCreateDraft currentDraft() => EventCreateDraft(
      step: step.value,
      type: type.value,
      title: titleCtrl.text,
      place: placeCtrl.text,
      description: descriptionCtrl.text,
      dateIso: eventDate.value?.toIso8601String(),
      guests: guests.value,
      budget: budget.value,
      visibility: visibility.value,
      coverPath: coverPath.value,
      entryType: entryType.value,
      ticketTitle: ticketTitleCtrl.text,
      ticketDescription: ticketDescCtrl.text,
      ticketPrice: double.tryParse(ticketPriceCtrl.text) ?? 0,
      ticketQuantity: int.tryParse(ticketQtyCtrl.text) ?? 0,
    );

    Future<void> persistDraft() {
      return ref.read(eventCreateDraftProvider.notifier).save(currentDraft());
    }

    void applyDraft(EventCreateDraft draft) {
      step.value = draft.step.clamp(0, _stepCount - 1);
      type.value = draft.type;
      titleCtrl.text = draft.title;
      placeCtrl.text = draft.place;
      descriptionCtrl.text = draft.description;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final draftDate = draft.date;
      if (draftDate != null) {
        final day = DateTime(draftDate.year, draftDate.month, draftDate.day);
        eventDate.value = day.isBefore(today) ? today : day;
      } else {
        eventDate.value = null;
      }
      guests.value = draft.guests;
      guestsCtrl.text = draft.guests.toString();
      budget.value = draft.budget;
      budgetCtrl.text = draft.budget.round().toString();
      visibility.value = draft.visibility;
      coverPath.value = draft.coverPath;
      entryType.value = draft.entryType;
      ticketTitleCtrl.text = draft.ticketTitle;
      ticketDescCtrl.text = draft.ticketDescription;
      ticketPriceCtrl.text = draft.ticketPrice > 0
          ? draft.ticketPrice.round().toString()
          : '';
      ticketQtyCtrl.text = draft.ticketQuantity > 0
          ? draft.ticketQuantity.toString()
          : '';
    }

    useEffect(() {
      Future.microtask(() async {
        await ref.read(eventCreateDraftProvider.notifier).load();
        if (!context.mounted || draftPrompted.value) return;
        final draft = ref.read(eventCreateDraftProvider);
        if (draft == null || !draft.hasProgress) return;
        draftPrompted.value = true;
        final resume = await showAppGlassDialog<bool>(
          context: context,
          builder: (ctx) => AppGlassDialog(
            title: const Text('Resume draft?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Start fresh'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Resume'),
              ),
            ],
            child: Text(
              'You left an event unfinished. Continue where you stopped, '
              'or start fresh.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        );
        if (!context.mounted) return;
        if (resume == true) {
          applyDraft(draft);
        } else {
          await ref.read(eventCreateDraftProvider.notifier).clear();
        }
      });
      return null;
    }, const []);

    final recommended = Event(
      id: 'preview',
      title: 'preview',
      dateLabel: '',
      place: '',
      coverUrl: '',
      status: EventStatus.planning,
      type: type.value,
      guestCount: guests.value,
      totalBudget: budget.value,
    ).recommendedBudget;

    final previewBudget = EventTemplates.budgetLinesFor(
      type: type.value,
      totalBudget: budget.value <= 0 ? 1 : budget.value,
    );
    final previewTasks = EventTemplates.tasksFor(type.value);

    final stepTitles = [
      'What are you celebrating?',
      'Event details',
      'Who can see it?',
      'Free or paid entry?',
      'Set your budget',
      'Review & create',
    ];
    final stepSubtitles = [
      'We’ll tailor budget categories and a starter checklist to this type.',
      'Name, date, place, guests, a short description — and an optional cover.',
      'Private, friends, or public — you can change this anytime later.',
      'Choose how guests get in — free RSVP or paid tickets.',
      'Start with a total — you can fine-tune every line after creating.',
      'Confirm the defaults, then open your event to edit budget & tasks.',
    ];

    final exiting = useRef(false);

    /// Full exit from the funnel (app bar / system back) — not step-by-step.
    Future<void> confirmExit() async {
      if (exiting.value) return;
      exiting.value = true;
      try {
        final draft = currentDraft();
        if (!draft.hasProgress) {
          await ref.read(eventCreateDraftProvider.notifier).clear();
          if (context.mounted) context.pop();
          return;
        }

        final choice = await showAppGlassDialog<String>(
          context: context,
          builder: (ctx) => AppGlassDialog(
            title: const Text('Leave event creation?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'stay'),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'discard'),
                child: const Text('Discard'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, 'save'),
                style: FilledButton.styleFrom(shape: const StadiumBorder()),
                child: const Text('Save draft'),
              ),
            ],
            child: Text(
              'Save your progress as a draft to resume later at this step, '
              'or discard it and start over next time.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        );

        if (!context.mounted) return;
        if (choice == null || choice == 'stay') return;

        if (choice == 'save') {
          await persistDraft();
        } else {
          await ref.read(eventCreateDraftProvider.notifier).clear();
        }
        if (context.mounted) context.pop();
      } finally {
        exiting.value = false;
      }
    }

    /// Bottom “Back” — previous step only (never exits the funnel).
    void goBackStep() {
      if (step.value <= 0) return;
      step.value = step.value - 1;
      persistDraft();
    }

    bool validateCurrentStep() {
      switch (step.value) {
        case 1:
          if (titleCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Add an event name')));
            return false;
          }
          if (eventDate.value == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Pick an event date')));
            return false;
          }
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final picked = eventDate.value!;
          final day = DateTime(picked.year, picked.month, picked.day);
          if (day.isBefore(today)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pick today or a future date')),
            );
            return false;
          }
          return true;
        case 3:
          if (entryType.value == EventEntryType.paid) {
            final price = double.tryParse(ticketPriceCtrl.text) ?? 0;
            if (price <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Set a ticket price')),
              );
              return false;
            }
            if (ticketTitleCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add a ticket page title')),
              );
              return false;
            }
          }
          return true;
        case 4:
          if (budget.value <= 0) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Set a total budget')));
            return false;
          }
          return true;
        default:
          return true;
      }
    }

    void goNext() {
      if (!validateCurrentStep()) return;
      if (step.value < _stepCount - 1) {
        step.value = step.value + 1;
        persistDraft();
      }
    }

    Future<void> pickCover(ImageSource source) async {
      try {
        final file = await ImagePicker().pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        if (file == null) return;
        coverPath.value = file.path;
        await persistDraft();
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not pick image')));
      }
    }

    Future<void> chooseCoverSource() async {
      final source = await showAppGlassDialog<ImageSource>(
        context: context,
        builder: (ctx) => AppGlassDialog(
          title: const Text('Event cover'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, ImageSource.camera),
              child: const Text('Camera'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
              style: FilledButton.styleFrom(shape: const StadiumBorder()),
              child: const Text('Gallery'),
            ),
          ],
          child: Text(
            'Optional — this photo is shown when people view your event. '
            'Skip to keep a default image for this event type.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ),
      );
      if (source != null) await pickCover(source);
    }

    Future<void> submit() async {
      if (!validateCurrentStep()) return;
      final date = eventDate.value;
      if (date == null) return;
      saving.value = true;
      final ticketPrice = double.tryParse(ticketPriceCtrl.text) ?? 0;
      final ticketQty = int.tryParse(ticketQtyCtrl.text) ?? guests.value;
      final resolvedTicketTitle = ticketTitleCtrl.text.trim().isEmpty
          ? '${titleCtrl.text.trim()} — Tickets'
          : ticketTitleCtrl.text.trim();
      final event = ref
          .read(eventsProvider.notifier)
          .createEvent(
            title: titleCtrl.text.trim(),
            type: type.value,
            dateLabel: formatEventDate(date),
            eventDate: date,
            place: placeCtrl.text.trim().isEmpty
                ? 'Location TBD'
                : placeCtrl.text.trim(),
            guestCount: guests.value,
            totalBudget: budget.value,
            visibility: visibility.value,
            description: descriptionCtrl.text.trim(),
            entryType: entryType.value,
            ticketPage: entryType.value == EventEntryType.paid
                ? EventTicketPage(
                    title: resolvedTicketTitle,
                    description: ticketDescCtrl.text.trim(),
                    price: ticketPrice,
                    quantity: ticketQty > 0 ? ticketQty : guests.value,
                  )
                : const EventTicketPage(),
            coverUrl: coverPath.value.trim().isEmpty
                ? null
                : coverPath.value.trim(),
          );
      await ref.read(eventCreateDraftProvider.notifier).clear();
      saving.value = false;
      if (!context.mounted) return;
      context.pushReplacement(AppRoutes.eventDetail(event.id));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await confirmExit();
      },
      child: Scaffold(
        appBar: AppFrostedAppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            tooltip: 'Close',
            onPressed: confirmExit,
          ),
          title: Text(
            'Plan an event',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.gutter,
                8,
                context.gutter,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Step ${step.value + 1} of $_stepCount',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${((step.value + 1) / _stepCount * 100).round()}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const GutterSmall(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (step.value + 1) / _stepCount,
                      minHeight: 6,
                      backgroundColor: colors.surfaceContainerHighest,
                      color: AppColors.primary,
                    ),
                  ),
                  const Gutter(),
                  Text(
                    stepTitles[step.value],
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const GutterTiny(),
                  Text(
                    stepSubtitles[step.value],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Gutter(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey(step.value),
                  child: switch (step.value) {
                    0 => _TypeStep(
                      selected: type.value,
                      onSelected: (value) {
                        type.value = value;
                        persistDraft();
                      },
                    ),
                    1 => _DetailsStep(
                      titleCtrl: titleCtrl,
                      placeCtrl: placeCtrl,
                      descriptionCtrl: descriptionCtrl,
                      guestsCtrl: guestsCtrl,
                      eventDate: eventDate.value,
                      coverPath: coverPath.value,
                      fallbackCoverUrl: type.value.defaultCoverUrl,
                      onPickDate: () async {
                        final picked = await showEventDatePicker(
                          context,
                          initialDate: eventDate.value ?? DateTime.now(),
                        );
                        if (picked != null) {
                          eventDate.value = picked;
                          persistDraft();
                        }
                      },
                      onPickCover: chooseCoverSource,
                      onClearCover: () {
                        coverPath.value = '';
                        persistDraft();
                      },
                      onGuestsChanged: (value) {
                        guests.value = value;
                        persistDraft();
                      },
                      onChanged: persistDraft,
                    ),
                    2 => _VisibilityStep(
                      selected: visibility.value,
                      onSelected: (value) {
                        visibility.value = value;
                        persistDraft();
                      },
                    ),
                    3 => _EntryStep(
                      selected: entryType.value,
                      ticketTitleCtrl: ticketTitleCtrl,
                      ticketDescCtrl: ticketDescCtrl,
                      ticketPriceCtrl: ticketPriceCtrl,
                      ticketQtyCtrl: ticketQtyCtrl,
                      eventTitle: titleCtrl.text.trim(),
                      guests: guests.value,
                      onSelected: (value) {
                        entryType.value = value;
                        if (value == EventEntryType.paid) {
                          if (ticketTitleCtrl.text.trim().isEmpty &&
                              titleCtrl.text.trim().isNotEmpty) {
                            ticketTitleCtrl.text =
                                '${titleCtrl.text.trim()} — Tickets';
                          }
                          if (ticketQtyCtrl.text.trim().isEmpty) {
                            ticketQtyCtrl.text = guests.value.toString();
                          }
                        }
                        persistDraft();
                      },
                      onChanged: persistDraft,
                    ),
                    4 => _BudgetStep(
                      budgetCtrl: budgetCtrl,
                      budget: budget.value,
                      recommended: recommended,
                      guests: guests.value,
                      typeLabel: type.value.label,
                      onBudgetChanged: (value) {
                        budget.value = value;
                        persistDraft();
                      },
                      onUseRecommended: () {
                        budget.value = recommended;
                        budgetCtrl.text = recommended.round().toString();
                        persistDraft();
                      },
                    ),
                    _ => _ReviewStep(
                      type: type.value,
                      title: titleCtrl.text.trim().isEmpty
                          ? 'Untitled event'
                          : titleCtrl.text.trim(),
                      dateLabel: eventDate.value == null
                          ? 'Date TBD'
                          : formatEventDate(eventDate.value!),
                      place: placeCtrl.text.trim(),
                      description: descriptionCtrl.text.trim(),
                      guests: guests.value,
                      budget: budget.value,
                      recommended: recommended,
                      visibility: visibility.value,
                      entryType: entryType.value,
                      ticketPrice:
                          double.tryParse(ticketPriceCtrl.text) ?? 0,
                      ticketTitle: ticketTitleCtrl.text.trim(),
                      coverPath: coverPath.value,
                      fallbackCoverUrl: type.value.defaultCoverUrl,
                      previewBudget: previewBudget,
                      previewTasks: previewTasks,
                    ),
                  },
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.gutter,
                  8,
                  context.gutter,
                  12,
                ),
                child: Row(
                  children: [
                    if (step.value > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: goBackStep,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                      const GutterSmall(),
                    ],
                    Expanded(
                      flex: step.value > 0 ? 2 : 1,
                      child: FilledButton(
                        onPressed: saving.value
                            ? null
                            : () {
                                if (step.value == _stepCount - 1) {
                                  submit();
                                } else {
                                  goNext();
                                }
                              },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          saving.value
                              ? 'Creating…'
                              : step.value == _stepCount - 1
                              ? 'Create event'
                              : 'Continue',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeStep extends StatelessWidget {
  const _TypeStep({required this.selected, required this.onSelected});

  final EventType selected;
  final ValueChanged<EventType> onSelected;

  IconData _iconFor(EventType type) => switch (type) {
    EventType.wedding => LucideIcons.heart,
    EventType.birthday => LucideIcons.cake,
    EventType.corporate => LucideIcons.briefcase,
    EventType.brunch => LucideIcons.coffee,
    EventType.engagement => LucideIcons.gem,
    EventType.other => LucideIcons.sparkles,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      children: [
        for (final option in EventType.values) ...[
          Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected == option
                        ? AppColors.primary
                        : colors.outline.withValues(alpha: 0.7),
                    width: selected == option ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected == option
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : colors.surfaceContainerHighest,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          _iconFor(option),
                          size: 22,
                          color: selected == option
                              ? AppColors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Gutter(),
                    Expanded(
                      child: Text(
                        option.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (selected == option)
                      const Icon(
                        LucideIcons.circleCheck,
                        color: AppColors.primary,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const GutterSmall(),
        ],
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.titleCtrl,
    required this.placeCtrl,
    required this.descriptionCtrl,
    required this.guestsCtrl,
    required this.eventDate,
    required this.coverPath,
    required this.fallbackCoverUrl,
    required this.onPickDate,
    required this.onPickCover,
    required this.onClearCover,
    required this.onGuestsChanged,
    required this.onChanged,
  });

  final TextEditingController titleCtrl;
  final TextEditingController placeCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController guestsCtrl;
  final DateTime? eventDate;
  final String coverPath;
  final String fallbackCoverUrl;
  final VoidCallback onPickDate;
  final VoidCallback onPickCover;
  final VoidCallback onClearCover;
  final ValueChanged<int> onGuestsChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasCustomCover = coverPath.trim().isNotEmpty;
    final previewUrl = hasCustomCover ? coverPath : fallbackCoverUrl;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      children: [
        Text(
          'Cover photo',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const GutterTiny(),
        Text(
          'Optional — shown as the main image on your event.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const GutterSmall(),
        Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onPickCover,
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.7),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppCachedNetworkImage(
                        imageUrl: previewUrl,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.zero,
                        errorWidget: ColoredBox(
                          color: colors.surfaceContainerHighest,
                          child: Icon(
                            LucideIcons.imagePlus,
                            color: colors.onSurfaceVariant,
                            size: 36,
                          ),
                        ),
                      ),
                      ColoredBox(color: Colors.black.withValues(alpha: 0.28)),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasCustomCover
                                  ? LucideIcons.image
                                  : LucideIcons.imagePlus,
                              color: Colors.white,
                              size: 28,
                            ),
                            const GutterTiny(),
                            Text(
                              hasCustomCover
                                  ? 'Change cover'
                                  : 'Add cover photo',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (!hasCustomCover) ...[
                              const Gutter.custom(size: 4),
                              Text(
                                'Default preview for now',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (hasCustomCover)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onClearCover,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  LucideIcons.x,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gutter(),
        TextField(
          controller: titleCtrl,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Event name',
            hintText: 'Summer Wedding',
          ),
        ),
        const Gutter(),
        TextField(
          controller: descriptionCtrl,
          maxLines: 3,
          maxLength: 280,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'A short note about the celebration…',
            alignLabelWithHint: true,
          ),
        ),
        const Gutter(),
        Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(LucideIcons.calendarDays),
                border: OutlineInputBorder(),
              ),
              child: Text(
                eventDate == null
                    ? 'Tap to open calendar'
                    : formatEventDate(eventDate!),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: eventDate == null
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const Gutter(),
        TextField(
          controller: placeCtrl,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => onChanged(),
          decoration: const InputDecoration(
            labelText: 'Place',
            hintText: 'Douala · Venue name',
            prefixIcon: Icon(LucideIcons.mapPin),
          ),
        ),
        const Gutter(),
        TextField(
          controller: guestsCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Guests',
            prefixIcon: Icon(LucideIcons.users),
          ),
          onChanged: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null) onGuestsChanged(parsed);
          },
        ),
      ],
    );
  }
}

class _VisibilityStep extends StatelessWidget {
  const _VisibilityStep({required this.selected, required this.onSelected});

  final EventVisibility selected;
  final ValueChanged<EventVisibility> onSelected;

  IconData _icon(EventVisibility v) => switch (v) {
    EventVisibility.private => LucideIcons.lock,
    EventVisibility.friends => LucideIcons.users,
    EventVisibility.public => LucideIcons.globe,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      children: [
        for (final option in EventVisibility.values) ...[
          Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected == option
                        ? AppColors.primary
                        : colors.outline.withValues(alpha: 0.7),
                    width: selected == option ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _icon(option),
                      color: selected == option
                          ? AppColors.primary
                          : colors.onSurfaceVariant,
                    ),
                    const Gutter(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const GutterTiny(),
                          Text(
                            option.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected == option)
                      const Icon(
                        LucideIcons.circleCheck,
                        color: AppColors.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const GutterSmall(),
        ],
      ],
    );
  }
}

class _EntryStep extends StatelessWidget {
  const _EntryStep({
    required this.selected,
    required this.ticketTitleCtrl,
    required this.ticketDescCtrl,
    required this.ticketPriceCtrl,
    required this.ticketQtyCtrl,
    required this.eventTitle,
    required this.guests,
    required this.onSelected,
    required this.onChanged,
  });

  final EventEntryType selected;
  final TextEditingController ticketTitleCtrl;
  final TextEditingController ticketDescCtrl;
  final TextEditingController ticketPriceCtrl;
  final TextEditingController ticketQtyCtrl;
  final String eventTitle;
  final int guests;
  final ValueChanged<EventEntryType> onSelected;
  final VoidCallback onChanged;

  IconData _icon(EventEntryType type) => switch (type) {
    EventEntryType.free => LucideIcons.ticketSlash,
    EventEntryType.paid => LucideIcons.ticket,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.info,
                  size: 18,
                  color: AppColors.primary,
                ),
                const GutterSmall(),
                Expanded(
                  child: Text(
                    'Free vs paid is about guest entry — not your planning '
                    'budget. Free: guests RSVP with invites. Paid: you set up '
                    'a ticket page so guests can buy entry. Budget (next step) '
                    'is still what you spend to organize the event.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gutter(),
        for (final option in EventEntryType.values) ...[
          Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected == option
                        ? AppColors.primary
                        : colors.outline.withValues(alpha: 0.7),
                    width: selected == option ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _icon(option),
                      color: selected == option
                          ? AppColors.primary
                          : colors.onSurfaceVariant,
                    ),
                    const Gutter(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const GutterTiny(),
                          Text(
                            option.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected == option)
                      const Icon(
                        LucideIcons.circleCheck,
                        color: AppColors.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const GutterSmall(),
        ],
        if (selected == EventEntryType.paid) ...[
          const Gutter(),
          Text(
            'Ticket page',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const GutterTiny(),
          Text(
            'Guests will see this page when buying tickets. You can refine it '
            'after creating the event.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const GutterSmall(),
          TextField(
            controller: ticketTitleCtrl,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: 'Page title',
              hintText: eventTitle.isEmpty
                  ? 'Event — Tickets'
                  : '$eventTitle — Tickets',
              prefixIcon: const Icon(LucideIcons.ticket),
            ),
          ),
          const Gutter(),
          TextField(
            controller: ticketDescCtrl,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'What’s included with the ticket…',
              alignLabelWithHint: true,
            ),
          ),
          const Gutter(),
          TextField(
            controller: ticketPriceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Ticket price (XAF)',
              prefixIcon: Icon(LucideIcons.banknote),
            ),
          ),
          const Gutter(),
          TextField(
            controller: ticketQtyCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: 'Tickets available',
              hintText: guests.toString(),
              prefixIcon: const Icon(LucideIcons.hash),
            ),
          ),
        ],
      ],
    );
  }
}

class _BudgetStep extends StatelessWidget {
  const _BudgetStep({
    required this.budgetCtrl,
    required this.budget,
    required this.recommended,
    required this.guests,
    required this.typeLabel,
    required this.onBudgetChanged,
    required this.onUseRecommended,
  });

  final TextEditingController budgetCtrl;
  final double budget;
  final double recommended;
  final int guests;
  final String typeLabel;
  final ValueChanged<double> onBudgetChanged;
  final VoidCallback onUseRecommended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final below = budget > 0 && budget + 0.5 < recommended;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      children: [
        TextField(
          controller: budgetCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Total budget (XAF)',
            prefixIcon: Icon(LucideIcons.wallet),
          ),
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed != null) onBudgetChanged(parsed);
          },
        ),
        const Gutter(),
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
                  'Suggested for $guests guests',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const GutterTiny(),
                Text(
                  formatEventMoney(recommended),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const GutterTiny(),
                Text(
                  'Typical ${typeLabel.toLowerCase()} spend in this guest range.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Gutter(),
                OutlinedButton(
                  onPressed: onUseRecommended,
                  style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                  child: const Text('Use suggested budget'),
                ),
              ],
            ),
          ),
        ),
        if (below) ...[
          const Gutter(),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.like.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.like.withValues(alpha: 0.35)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Your budget is below the suggested ${formatEventMoney(recommended)}. '
                'You can continue and increase it later.',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.type,
    required this.title,
    required this.dateLabel,
    required this.place,
    required this.description,
    required this.guests,
    required this.budget,
    required this.recommended,
    required this.visibility,
    required this.entryType,
    required this.ticketPrice,
    required this.ticketTitle,
    required this.coverPath,
    required this.fallbackCoverUrl,
    required this.previewBudget,
    required this.previewTasks,
  });

  final EventType type;
  final String title;
  final String dateLabel;
  final String place;
  final String description;
  final int guests;
  final double budget;
  final double recommended;
  final EventVisibility visibility;
  final EventEntryType entryType;
  final double ticketPrice;
  final String ticketTitle;
  final String coverPath;
  final String fallbackCoverUrl;
  final List<BudgetLine> previewBudget;
  final List<EventTask> previewTasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final coverUrl = coverPath.trim().isEmpty
        ? fallbackCoverUrl
        : coverPath.trim();

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: AppCachedNetworkImage(
              imageUrl: coverUrl,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.zero,
              errorWidget: ColoredBox(
                color: colors.surfaceContainerHighest,
                child: Icon(
                  LucideIcons.imageOff,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        const Gutter(),
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
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const GutterTiny(),
                Text(
                  '${type.label} · ${visibility.label} · '
                  '${entryType.label} · $guests guests',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Gutter(),
                Text(dateLabel, style: theme.textTheme.bodyMedium),
                const GutterTiny(),
                Text(
                  place.isEmpty ? 'Location TBD' : place,
                  style: theme.textTheme.bodyMedium,
                ),
                if (description.isNotEmpty) ...[
                  const GutterSmall(),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
                const GutterTiny(),
                Text(
                  formatEventMoney(budget),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (entryType == EventEntryType.paid) ...[
                  const GutterSmall(),
                  Text(
                    ticketTitle.isEmpty
                        ? 'Ticket: ${formatEventMoney(ticketPrice)}'
                        : '$ticketTitle · ${formatEventMoney(ticketPrice)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (coverPath.trim().isEmpty) ...[
                  const GutterSmall(),
                  Text(
                    'Using default cover for ${type.label.toLowerCase()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const Gutter(),
        Text(
          'Budget split',
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
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (final line in previewBudget) ...[
                  Row(
                    children: [
                      Expanded(child: Text(line.label)),
                      Text(
                        '${((line.amount / (budget <= 0 ? 1 : budget)) * 100).round()}%',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const GutterSmall(),
                ],
              ],
            ),
          ),
        ),
        const Gutter(),
        Text(
          'Starter tasks (${previewTasks.length})',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const GutterSmall(),
        Text(
          previewTasks.take(4).map((t) => '• ${t.title}').join('\n'),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
