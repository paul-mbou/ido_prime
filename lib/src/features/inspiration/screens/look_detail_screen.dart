import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/inspiration/models/inspiration_look.dart';
import 'package:ido_prime/src/features/inspiration/widgets/save_to_board_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LookDetailScreen extends HookConsumerWidget {
  const LookDetailScreen({super.key, required this.lookId});

  final String lookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final look = findInspirationLookById(lookId);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final frosted = useState(false);

    if (look == null) {
      return Scaffold(
        appBar: const AppFrostedAppBar(title: Text('Look')),
        body: Center(
          child: Text(
            'Look not found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppFrostedAppBar(
        frosted: frosted.value,
        showCircleActions: true,
        title: Text(look.category),
        actions: [
          IconButton(
            onPressed: () => showSaveToBoardSheet(context, ref, look: look),
            icon: const Icon(LucideIcons.bookmark),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          final next = n.metrics.pixels > 0;
          if (frosted.value != next) frosted.value = next;
          return false;
        },
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + 24,
          ),
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: AppCachedNetworkImage(
                imageUrl: look.imageUrl,
                borderRadius: BorderRadius.zero,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in look.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Gutter(),
                  Text(
                    look.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const GutterSmall(),
                  Text(
                    look.copy,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.78),
                      height: 1.45,
                    ),
                  ),
                  const Gutter(),
                  Material(
                    color: colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: colors.outline.withValues(alpha: 0.7),
                      ),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: AppCachedNetworkImage(
                            imageUrl: look.vendorImageUrl,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      title: Text(
                        look.vendorName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Verified vendor · Same vibe',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        LucideIcons.chevronRight,
                        color: colors.onSurfaceVariant,
                      ),
                      onTap: () => context.go(AppRoutes.vendors),
                    ),
                  ),
                  const GutterLarge(),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Look linked to your event'),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize: const Size.fromHeight(48),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(LucideIcons.calendar, size: 18),
                    label: const Text('Use for my event'),
                  ),
                  const GutterSmall(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go(AppRoutes.vendors),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Same vibe vendors'),
                        ),
                      ),
                      const GutterSmall(),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ask AI about this look…'),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                            minimumSize: const Size.fromHeight(48),
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(LucideIcons.sparkles, size: 16),
                          label: const Text('Ask AI'),
                        ),
                      ),
                    ],
                  ),
                  const GutterSmall(),
                  OutlinedButton(
                    onPressed: () =>
                        showSaveToBoardSheet(context, ref, look: look),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Save to board'),
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
