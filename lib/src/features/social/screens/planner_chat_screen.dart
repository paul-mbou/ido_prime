import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/profile/models/planner_profile.dart';
import 'package:ido_prime/src/features/social/models/planner_friendship.dart';
import 'package:ido_prime/src/features/social/providers/planner_chat_provider.dart';
import 'package:ido_prime/src/features/social/providers/planner_friendship_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Planner ↔ planner chat — only after friendship is accepted.
class PlannerChatScreen extends HookConsumerWidget {
  const PlannerChatScreen({super.key, required this.plannerId});

  final String plannerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planner = findPlannerById(plannerId);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;
    final friendship = ref.watch(plannerFriendshipProvider(plannerId));
    final messages = ref.watch(plannerChatProvider(plannerId));
    final controller = useTextEditingController();
    final scrollController = useScrollController();
    final frosted = useState(false);

    useEffect(() {
      if (friendship.status != FriendshipStatus.accepted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.replace(AppRoutes.plannerProfile(plannerId));
        });
      }
      return null;
    }, [friendship.status]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
      return null;
    }, [messages.length]);

    if (planner == null) {
      return Scaffold(
        appBar: const AppFrostedAppBar(title: Text('Chat')),
        body: Center(
          child: Text(
            'Profile not found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (friendship.status != FriendshipStatus.accepted) {
      return const Scaffold(
        appBar: AppFrostedAppBar(title: Text('Chat')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Future<void> send() async {
      final text = controller.text;
      controller.clear();
      await ref.read(plannerChatProvider(plannerId).notifier).send(text);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppFrostedAppBar(
        frosted: frosted.value,
        title: Row(
          children: [
            AppCachedAvatar(
              imageUrl: planner.avatarUrl,
              radius: 16,
              fallbackName: planner.name,
            ),
            const GutterSmall(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    planner.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Friends · chat',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          final next = n.metrics.pixels > 2;
          if (next != frosted.value) frosted.value = next;
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      MediaQuery.paddingOf(context).top + kToolbarHeight + 16,
                      gutter,
                      12,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final msg = messages[index];
                        return _Bubble(message: msg);
                      }, childCount: messages.length),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: theme.navigationBarTheme.backgroundColor ?? colors.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 10, gutter, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => send(),
                          decoration: InputDecoration(
                            hintText: 'Message…',
                            isDense: true,
                            filled: true,
                            fillColor: colors.surfaceContainerHighest
                                .withValues(alpha: 0.45),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(999),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(999),
                              ),
                              borderSide: BorderSide(
                                color: colors.outline.withValues(alpha: 0.55),
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(999),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const GutterSmall(),
                      IconButton.filled(
                        onPressed: send,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                        ),
                        icon: const Icon(LucideIcons.send, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final PlannerChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mine = message.fromMe;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: mine
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : colors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(mine ? 16 : 4),
                bottomRight: Radius.circular(mine ? 4 : 16),
              ),
              border: Border.all(
                color: mine
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : colors.outline.withValues(alpha: 0.55),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                message.body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
