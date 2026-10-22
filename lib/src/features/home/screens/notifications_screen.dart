import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/home/models/app_notification.dart';
import 'package:ido_prime/src/features/home/providers/notifications_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gutter = context.gutter;
    final items = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          'Notifications',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: unread == 0
                ? null
                : () => ref.read(notificationsProvider.notifier).markAllRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, gutter, gutter, 32),
            sliver: items.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No notifications yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : (SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const GutterSmall(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _NotificationTile(
                        data: item,
                        onTap: item.unread
                            ? () => ref
                                  .read(notificationsProvider.notifier)
                                  .markRead(item.id)
                            : null,
                      );
                    },
                  )),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.data, this.onTap});

  final AppNotification data;
  final VoidCallback? onTap;

  (IconData, Color) _badge(ColorScheme colors) => switch (data.kind) {
    AppNotificationKind.like => (LucideIcons.heart, AppColors.like),
    AppNotificationKind.comment => (
      LucideIcons.messageCircle,
      colors.secondary,
    ),
    AppNotificationKind.follow => (LucideIcons.userPlus, colors.tertiary),
    AppNotificationKind.friendRequest => (LucideIcons.users, AppColors.primary),
    AppNotificationKind.message => (LucideIcons.mail, colors.primary),
    AppNotificationKind.event => (LucideIcons.calendarDays, AppColors.primary),
    AppNotificationKind.budget => (LucideIcons.wallet, AppColors.primary),
    AppNotificationKind.tasks => (LucideIcons.listChecks, colors.tertiary),
    AppNotificationKind.invites => (LucideIcons.mailOpen, colors.secondary),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final badge = _badge(colors);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: data.unread
                ? colors.primaryContainer.withValues(alpha: 0.35)
                : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.55)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppCachedAvatar(
                      imageUrl: data.avatarUrl,
                      radius: 24,
                      fallbackName: data.title,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: colors.surface,
                        child: Icon(badge.$1, size: 12, color: badge.$2),
                      ),
                    ),
                  ],
                ),
                const Gutter(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CategoryTag(label: data.tagLabel),
                          const Spacer(),
                          Text(
                            data.time,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const GutterTiny(),
                      Text(
                        data.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: data.unread
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      const GutterTiny(),
                      Text(
                        data.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (data.unread) ...[
                  const GutterSmall(),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
