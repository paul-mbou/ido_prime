import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/inspiration/models/mood_board.dart';
import 'package:ido_prime/src/features/inspiration/providers/inspiration_provider.dart';
import 'package:ido_prime/src/features/inspiration/widgets/inspiration_chips.dart';
import 'package:ido_prime/src/features/inspiration/widgets/look_pin_tile.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MoodBoardDetailScreen extends HookConsumerWidget {
  const MoodBoardDetailScreen({super.key, required this.boardId});

  final String boardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final frosted = useState(false);
    final boards = ref.watch(moodBoardsProvider);
    MoodBoard? board;
    for (final b in boards) {
      if (b.id == boardId) {
        board = b;
        break;
      }
    }

    if (board == null) {
      return Scaffold(
        appBar: const AppFrostedAppBar(title: Text('Mood board')),
        body: Center(
          child: Text(
            'Board not found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final current = board;
    final looks = looksForBoard(current);
    final covers = current.coverUrls;
    final c0 = covers.isNotEmpty ? covers[0] : '';
    final c1 = covers.length > 1 ? covers[1] : c0;
    final c2 = covers.length > 2 ? covers[2] : c0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppFrostedAppBar(
        frosted: frosted.value,
        showCircleActions: true,
        title: const Text('Mood board'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rename · Share · Delete')),
              );
            },
            icon: const Icon(LucideIcons.ellipsis),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.gutter, 8, context.gutter, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        current.eventTitle != null
                            ? 'Board linked to ${current.eventTitle}'
                            : 'Pick an event to link',
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size.fromHeight(46),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(LucideIcons.calendar, size: 18),
                label: Text(
                  current.eventTitle != null
                      ? 'Use for ${current.eventTitle}'
                      : 'Link to an event',
                ),
              ),
              const GutterSmall(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go(AppRoutes.vendors),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Find vendors'),
                    ),
                  ),
                  const GutterSmall(),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ask AI about “${current.name}”…'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                        minimumSize: const Size.fromHeight(44),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(LucideIcons.sparkles, size: 16),
                      label: const Text('Ask AI'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          final next = n.metrics.pixels > 0;
          if (frosted.value != next) frosted.value = next;
          return false;
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            context.gutter,
            MediaQuery.paddingOf(context).top + kToolbarHeight,
            context.gutter,
            24,
          ),
          children: [
            SizedBox(
              height: 220,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.55),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 14,
                        child: AppCachedNetworkImage(
                          imageUrl: c0,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      Gutter.custom(size: 3),
                      Expanded(
                        flex: 10,
                        child: Column(
                          children: [
                            Expanded(
                              child: AppCachedNetworkImage(
                                imageUrl: c1,
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            Gutter.custom(size: 3),
                            Expanded(
                              child: AppCachedNetworkImage(
                                imageUrl: c2,
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gutter(),
            Text(
              current.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const GutterSmall(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  current.countLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (current.eventTitle != null)
                  EventContextChip(
                    label: current.eventTitle!,
                    icon: LucideIcons.calendar,
                    onTap: current.eventId == null
                        ? null
                        : () => context.push(
                            AppRoutes.eventDetail(current.eventId!),
                          ),
                  ),
              ],
            ),
            const GutterSmall(),
            Text(
              current.blurb,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.78),
                height: 1.45,
              ),
            ),
            if (current.vendors.isNotEmpty) ...[
              const Gutter(),
              Text(
                'VENDORS IN THIS VIBE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const GutterSmall(),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: current.vendors.length,
                  separatorBuilder: (_, _) => const GutterSmall(),
                  itemBuilder: (context, index) {
                    final vendor = current.vendors[index];
                    return Material(
                      color: colors.surface,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: colors.outline.withValues(alpha: 0.7),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => context.go(AppRoutes.vendors),
                        customBorder: const StadiumBorder(),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: AppCachedNetworkImage(
                                    imageUrl: vendor.imageUrl,
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                              const GutterTiny(),
                              Text(
                                vendor.name,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const GutterLarge(),
            Text(
              'SAVED LOOKS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
            const GutterSmall(),
            if (looks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.8),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'No looks yet — start collecting ideas.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Gutter(),
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.inspiration),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Browse inspiration'),
                    ),
                  ],
                ),
              )
            else
              InspirationMasonry(
                looks: looks,
                showTitles: true,
                onLookTap: (look) =>
                    context.push(AppRoutes.lookDetail(look.id)),
                onSave: (_) {},
              ),
          ],
        ),
      ),
    );
  }
}
