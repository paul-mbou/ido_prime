import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_root_layout.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/inspiration/models/inspiration_look.dart';
import 'package:ido_prime/src/features/inspiration/providers/inspiration_provider.dart';
import 'package:ido_prime/src/features/inspiration/widgets/inspiration_chips.dart';
import 'package:ido_prime/src/features/inspiration/widgets/look_pin_tile.dart';
import 'package:ido_prime/src/features/inspiration/widgets/mood_board_pill.dart';
import 'package:ido_prime/src/features/inspiration/widgets/save_to_board_sheet.dart';

class InspirationScreen extends HookConsumerWidget {
  const InspirationScreen({super.key});

  Event? _activeEvent(List<Event> events) {
    for (final e in events) {
      if (e.isMine &&
          (e.effectiveStatus == EventStatus.upcoming ||
              e.effectiveStatus == EventStatus.planning)) {
        return e;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final category = useState(inspirationCategories.first);
    final boards = ref.watch(moodBoardsProvider);
    final events = ref.watch(eventsProvider);
    final activeEvent = _activeEvent(events);

    final looks = category.value == 'All'
        ? mockInspirationLooks
        : mockInspirationLooks
              .where((l) => l.category == category.value)
              .toList(growable: false);

    final nearYou = mockInspirationLooks
        .where((l) => l.nearYouPlace != null)
        .toList(growable: false);

    final savedIds = <String>{
      for (final board in boards)
        for (final id in board.lookIds) id,
    };

    return AppRootLayout(
      extendUnderAppBar: true,
      padding: EdgeInsets.fromLTRB(context.gutter, 0, context.gutter, 100),
      children: [
        if (activeEvent != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: EventContextChip(
              label: 'For ${activeEvent.title}',
              onTap: () => context.push(AppRoutes.eventDetail(activeEvent.id)),
            ),
          ),
          const Gutter(),
        ],
        Text(
          'YOUR BOARDS',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        const GutterSmall(),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: boards.length + 1,
            separatorBuilder: (_, _) => const GutterSmall(),
            itemBuilder: (context, index) {
              if (index == 0) {
                return NewMoodBoardPill(
                  onTap: () => context.push(AppRoutes.createMoodBoard),
                );
              }
              final board = boards[index - 1];
              return MoodBoardPill(
                board: board,
                onTap: () => context.push(AppRoutes.moodBoardDetail(board.id)),
              );
            },
          ),
        ),
        const Gutter(),
        InspirationCategoryChips(
          categories: inspirationCategories,
          selected: category.value,
          onSelected: (value) => category.value = value,
        ),
        const Gutter(),
        InspirationMasonry(
          looks: looks,
          savedIds: savedIds,
          onLookTap: (look) => context.push(AppRoutes.lookDetail(look.id)),
          onSave: (look) => showSaveToBoardSheet(context, ref, look: look),
        ),
        const GutterLarge(),
        Text(
          'Near you · Douala',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const GutterSmall(),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: nearYou.length,
            separatorBuilder: (_, _) => const GutterSmall(),
            itemBuilder: (context, index) {
              final look = nearYou[index];
              return _NearYouCard(
                look: look,
                onTap: () => context.push(AppRoutes.lookDetail(look.id)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NearYouCard extends StatelessWidget {
  const _NearYouCard({required this.look, required this.onTap});

  final InspirationLook look;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: 200,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outline.withValues(alpha: 0.7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppCachedNetworkImage(
                  imageUrl: look.imageUrl,
                  borderRadius: BorderRadius.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      look.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      look.nearYouPlace ?? look.category,
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
