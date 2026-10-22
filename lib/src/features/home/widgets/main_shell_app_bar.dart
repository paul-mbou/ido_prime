import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/features/home/providers/notifications_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Default main-tab app bar: avatar | contextual search | notifications.
class MainShellAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const MainShellAppBar({
    super.key,
    required this.searchHint,
    this.frosted = false,
    this.actions = const [],
    this.avatarUrl = _defaultAvatarUrl,
  });

  static const _defaultAvatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop';

  final String searchHint;
  final bool frosted;
  final List<Widget> actions;
  final String avatarUrl;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationsCountProvider);

    return AppFrostedAppBar(
      frosted: frosted,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 8,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.push(AppRoutes.profile),
              child: AppCachedAvatar(
                imageUrl: avatarUrl,
                radius: 18,
                fallbackName: 'Emma Thompson',
              ),
            ),
          ),
        ),
      ),
      title: _ShellSearchField(
        hint: searchHint,
        onTap: () => context.push(
          '${AppRoutes.search}?from=${_originParam(searchHint)}',
        ),
      ),
      actions: [
        ...actions,
        AppCircleIconButton(
          icon: LucideIcons.bell,
          badgeCount: unread,
          tooltip: unread == 0
              ? 'Notifications'
              : 'Notifications, $unread unread',
          onPressed: () => context.push(AppRoutes.notifications),
        ),
        const GutterSmall(),
      ],
    );
  }
}

String _originParam(String hint) {
  final h = hint.toLowerCase();
  if (h.contains('vendor')) return 'vendors';
  if (h.contains('event')) return 'events';
  if (h.contains('inspiration')) return 'inspiration';
  return 'feed';
}

class _ShellSearchField extends StatelessWidget {
  const _ShellSearchField({required this.hint, required this.onTap});

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outline.withValues(alpha: 0.55)),
          ),
          child: Row(
            children: [
              const GutterSmall(),
              Icon(
                LucideIcons.search,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
              const Gutter.custom(size: 8),
              Expanded(
                child: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              const GutterSmall(),
            ],
          ),
        ),
      ),
    );
  }
}
