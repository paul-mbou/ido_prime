import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/inspiration/models/inspiration_look.dart';
import 'package:ido_prime/src/features/inspiration/providers/inspiration_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CreateMoodBoardScreen extends HookConsumerWidget {
  const CreateMoodBoardScreen({super.key, this.seedLookId});

  final String? seedLookId;

  static const _covers = <({String url, String label})>[
    (
      url:
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&h=450&fit=crop&q=80',
      label: 'Gold & green',
    ),
    (
      url:
          'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=600&h=450&fit=crop&q=80',
      label: 'Coastal dusk',
    ),
    (
      url:
          'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=600&h=450&fit=crop&q=80',
      label: 'Lantern glow',
    ),
    (
      url:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&h=450&fit=crop&q=80',
      label: 'Feast table',
    ),
  ];

  static const _vibeTags = <String>[
    'Décor',
    'Tenues',
    'Tables',
    'Fleurs',
    'Menus',
    'Lieux',
    'Traditional',
    'Modern',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final step = useState(0);
    final nameCtrl = useTextEditingController();
    final noteCtrl = useTextEditingController();
    final nameTick = useState(0);
    final selectedEventId = useState<String?>('1');
    final coverUrl = useState(_covers.first.url);
    final tags = useState(<String>{'Décor'});

    final seedLook = seedLookId == null
        ? null
        : findInspirationLookById(seedLookId!);

    useEffect(() {
      if (seedLook != null) {
        coverUrl.value = seedLook.imageUrl;
        tags.value = {seedLook.category};
      }
      return null;
    }, const []);

    final events = ref
        .watch(eventsProvider)
        .where((e) => e.isMine)
        .take(4)
        .toList(growable: false);

    void syncName() => nameTick.value++;

    String previewName() {
      nameTick.value; // rebuild when name changes
      final n = nameCtrl.text.trim();
      return n.isEmpty ? 'Untitled board' : n;
    }

    String eventLabel() {
      final id = selectedEventId.value;
      if (id == null) return 'Not linked yet';
      for (final e in events) {
        if (e.id == id) return e.title;
      }
      return 'Not linked yet';
    }

    void finish() {
      final name = nameCtrl.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Give your board a name')));
        step.value = 0;
        return;
      }

      String? eventTitle;
      final eventId = selectedEventId.value;
      if (eventId != null) {
        for (final e in events) {
          if (e.id == eventId) {
            eventTitle = e.title;
            break;
          }
        }
      }

      final board = ref
          .read(moodBoardsProvider.notifier)
          .createBoard(
            name: name,
            coverUrl: coverUrl.value,
            eventId: eventId,
            eventTitle: eventTitle,
            note: noteCtrl.text,
            tags: tags.value.toList(growable: false),
            seedLookId: seedLook?.id,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            seedLook != null ? 'Board created · look saved' : 'Board created',
          ),
        ),
      );
      context.pushReplacement(AppRoutes.moodBoardDetail(board.id));
    }

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: const Text('New mood board'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.x),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.gutter, 8, context.gutter, 8),
          child: Row(
            children: [
              if (step.value > 0)
                OutlinedButton(
                  onPressed: () => step.value--,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(96, 48),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Back'),
                ),
              if (step.value > 0) const GutterSmall(),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    if (step.value == 0) {
                      if (nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Give your board a name'),
                          ),
                        );
                        return;
                      }
                      step.value = 1;
                      return;
                    }
                    if (step.value == 1) {
                      step.value = 2;
                      return;
                    }
                    finish();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(step.value == 2 ? 'Create board' : 'Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.gutter),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const GutterTiny(),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      decoration: BoxDecoration(
                        color: i <= step.value
                            ? AppColors.primary
                            : colors.outline,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (seedLook != null) ...[
            const Gutter(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.gutter),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: AppCachedNetworkImage(
                          imageUrl: seedLook.imageUrl,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const GutterSmall(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Will save this look',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            seedLook.title,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(context.gutter),
              children: [
                if (step.value == 0) ...[
                  Text(
                    'Name your board',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const GutterTiny(),
                  Text(
                    'Something you’ll recognize later — a vibe, a ceremony, '
                    'or a color story.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const GutterLarge(),
                  Text(
                    'BOARD NAME',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const GutterSmall(),
                  TextField(
                    controller: nameCtrl,
                    onChanged: (_) => syncName(),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'e.g. Soft gold reception',
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const Gutter(),
                  Text(
                    'NOTE (OPTIONAL)',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const GutterSmall(),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'What feeling are you chasing?',
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const Gutter(),
                  _PreviewCard(
                    coverUrl: coverUrl.value,
                    name: previewName(),
                    meta: '0 looks · ${eventLabel()}',
                  ),
                ] else if (step.value == 1) ...[
                  Text(
                    'Link an event?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const GutterTiny(),
                  Text(
                    'Boards get more useful when they’re tied to a '
                    'celebration you’re planning.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const GutterLarge(),
                  for (final event in events) ...[
                    _EventOption(
                      event: event,
                      selected: selectedEventId.value == event.id,
                      onTap: () => selectedEventId.value = event.id,
                    ),
                    const GutterSmall(),
                  ],
                  _SkipEventOption(
                    selected: selectedEventId.value == null,
                    onTap: () => selectedEventId.value = null,
                  ),
                ] else ...[
                  Text(
                    'Pick a starting vibe',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const GutterTiny(),
                  Text(
                    'Choose a cover mood and a few tags. You can change '
                    'these anytime.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const GutterLarge(),
                  Text(
                    'COVER',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const GutterSmall(),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 4 / 3,
                    children: [
                      for (final cover in _covers)
                        _CoverOption(
                          url: cover.url,
                          label: cover.label,
                          selected: coverUrl.value == cover.url,
                          onTap: () => coverUrl.value = cover.url,
                        ),
                    ],
                  ),
                  const Gutter(),
                  Text(
                    'TAGS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const GutterSmall(),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in _vibeTags)
                        FilterChip(
                          label: Text(tag),
                          selected: tags.value.contains(tag),
                          showCheckmark: false,
                          onSelected: (selected) {
                            final next = {...tags.value};
                            if (selected) {
                              next.add(tag);
                            } else {
                              next.remove(tag);
                            }
                            tags.value = next;
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: theme.textTheme.labelLarge?.copyWith(
                            color: tags.value.contains(tag)
                                ? AppColors.onPrimary
                                : colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const Gutter(),
                  _PreviewCard(
                    coverUrl: coverUrl.value,
                    name: previewName(),
                    meta:
                        '0 looks · ${eventLabel()} · '
                        '${tags.value.take(3).join(' · ')}',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.coverUrl,
    required this.name,
    required this.meta,
  });

  final String coverUrl;
  final String name;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: AppCachedNetworkImage(
                imageUrl: coverUrl,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
                Text(
                  meta,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventOption extends StatelessWidget {
  const _EventOption({
    required this.event,
    required this.selected,
    required this.onTap,
  });

  final Event event;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.14)
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : colors.outline.withValues(alpha: 0.75),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.calendar,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const GutterSmall(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${event.dateLabel} · ${event.place}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
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

class _SkipEventOption extends StatelessWidget {
  const _SkipEventOption({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.14)
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : colors.outline.withValues(alpha: 0.75),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.plus,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const GutterSmall(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skip for now',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'You can link an event later',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
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

class _CoverOption extends StatelessWidget {
  const _CoverOption({
    required this.url,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String url;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppCachedNetworkImage(
                  imageUrl: url,
                  borderRadius: BorderRadius.zero,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xD91A0F2F)],
                      ),
                    ),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
