import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/inspiration/models/inspiration_look.dart';
import 'package:ido_prime/src/features/inspiration/providers/inspiration_provider.dart';
import 'package:ido_prime/src/features/inspiration/widgets/mood_board_pill.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<void> showSaveToBoardSheet(
  BuildContext context,
  WidgetRef ref, {
  required InspirationLook look,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _SaveToBoardSheet(look: look),
  );
}

class _SaveToBoardSheet extends ConsumerWidget {
  const _SaveToBoardSheet({required this.look});

  final InspirationLook look;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final boards = ref.watch(moodBoardsProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Gutter(),
          Text(
            'Save to board',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const GutterTiny(),
          Text(
            look.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const Gutter(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(LucideIcons.plus, color: AppColors.primary),
            ),
            title: Text(
              'Create new board',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Name it after a vibe or event',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('${AppRoutes.createMoodBoard}?lookId=${look.id}');
            },
          ),
          Divider(color: colors.outline.withValues(alpha: 0.7)),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: boards.length,
              itemBuilder: (context, index) {
                final board = boards[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MoodBoardCoverCollage(
                        coverUrls: board.coverUrls,
                        gap: 1,
                      ),
                    ),
                  ),
                  title: Text(
                    board.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    board.countLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    ref
                        .read(moodBoardsProvider.notifier)
                        .saveLookToBoard(board.id, look.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved to ${board.name}')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
