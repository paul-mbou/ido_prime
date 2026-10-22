import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/home/models/feed_post.dart';
import 'package:ido_prime/src/features/home/providers/feed_posts_provider.dart';
import 'package:ido_prime/src/features/profile/models/planner_profile.dart';
import 'package:ido_prime/src/features/social/models/planner_friendship.dart';
import 'package:ido_prime/src/features/social/providers/planner_friendship_provider.dart';
import 'package:ido_prime/src/features/social/providers/vendor_follow_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Public planner profile — friendship (not follow). Chat after accept only.
class PlannerProfileScreen extends ConsumerWidget {
  const PlannerProfileScreen({super.key, required this.plannerId});

  final String plannerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planner = findPlannerById(plannerId);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final feedPosts = ref.watch(feedPostsProvider);
    final friendship = ref.watch(plannerFriendshipProvider(plannerId));
    final friendsCount = ref.watch(friendshipGraphProvider).friendsCount;
    final vendorsFollowed = ref.watch(vendorFollowProvider).length;

    if (planner == null) {
      return Scaffold(
        appBar: const AppFrostedAppBar(title: Text('Profile')),
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

    final posts = feedPosts
        .where((p) => p.authorId == planner.id)
        .toList(growable: false);

    final displayFriends = planner.isMe ? friendsCount : planner.friendsCount;

    return Scaffold(
      appBar: AppFrostedAppBar(
        title: Text(
          planner.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!planner.isMe)
            IconButton(
              icon: const Icon(LucideIcons.ellipsisVertical),
              onPressed: () {},
            ),
        ],
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              context.gutter,
              context.gutter,
              context.gutter,
              MediaQuery.paddingOf(context).bottom + 24,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HeaderCard(
                  planner: planner,
                  friendsCount: displayFriends,
                  vendorsFollowed: planner.isMe ? vendorsFollowed : null,
                ),
                const Gutter(),
                if (planner.isMe)
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.profile),
                    icon: const Icon(LucideIcons.settings, size: 18),
                    label: const Text('Edit profile & settings'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: const StadiumBorder(),
                    ),
                  )
                else
                  _FriendshipActions(planner: planner, friendship: friendship),
                const GutterLarge(),
                Text(
                  'Posts',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const GutterSmall(),
                if (posts.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: context.gutterLarge,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.imageOff,
                            size: 36,
                            color: colors.onSurfaceVariant,
                          ),
                          const GutterSmall(),
                          Text(
                            'No posts yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _PostTile(post: post);
                    },
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendshipActions extends ConsumerWidget {
  const _FriendshipActions({required this.planner, required this.friendship});

  final PlannerProfile planner;
  final PlannerFriendship friendship;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final notifier = ref.read(plannerFriendshipProvider(planner.id).notifier);

    switch (friendship.status) {
      case FriendshipStatus.pendingIncoming:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.65),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Friend request',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const GutterTiny(),
                    Text(
                      friendship.message.isEmpty
                          ? '${planner.name} wants to connect with you.'
                          : friendship.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const GutterSmall(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await notifier.decline();
                      if (context.mounted) {
                        context.showSnackBar('Request declined');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const GutterSmall(),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await notifier.accept();
                      if (context.mounted) {
                        context.showSnackBar('You are now friends');
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        );
      case FriendshipStatus.pendingOutgoing:
        return Column(
          children: [
            FilledButton(
              onPressed: () async {
                await notifier.cancelOutgoing();
                if (context.mounted) {
                  context.showSnackBar('Request cancelled');
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: colors.surfaceContainerHighest,
                foregroundColor: colors.onSurface,
                shape: const StadiumBorder(),
              ),
              child: const Text('Request pending'),
            ),
            const GutterTiny(),
            Text(
              'Chat unlocks after ${planner.name.split(' ').first} accepts.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        );
      case FriendshipStatus.accepted:
        return Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  final remove = await showModalBottomSheet<bool>(
                    context: context,
                    showDragHandle: true,
                    builder: (ctx) => SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          ctx.gutter,
                          0,
                          ctx.gutter,
                          ctx.gutter,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Friends',
                              style: Theme.of(ctx).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const Gutter(),
                            Text(
                              'You and ${planner.name} are friends. '
                              'Remove the connection?',
                              style: Theme.of(ctx).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      ctx,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const GutterLarge(),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Unfriend'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  if (remove == true) {
                    await notifier.unfriend();
                    if (context.mounted) {
                      context.showSnackBar('Removed from friends');
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: colors.surfaceContainerHighest,
                  foregroundColor: colors.onSurface,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Friends'),
              ),
            ),
            const GutterSmall(),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.plannerChat(planner.id)),
                icon: const Icon(LucideIcons.messageCircle, size: 18),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        );
      case FriendshipStatus.declined:
        return FilledButton(
          onPressed: () async {
            await notifier.resetDeclined();
            await notifier.sendRequest();
            if (context.mounted) {
              context.showSnackBar('Friend request sent');
            }
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: const StadiumBorder(),
          ),
          child: const Text('Add friend'),
        );
      case FriendshipStatus.none:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  await notifier.sendRequest(
                    message: 'Hi! Would love to connect on IDO.',
                  );
                  if (context.mounted) {
                    context.showSnackBar('Friend request sent');
                  }
                },
                icon: const Icon(LucideIcons.userPlus, size: 18),
                label: const Text('Add friend'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const GutterSmall(),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.showSnackBar(
                    'Chat unlocks after they accept your friend request',
                  );
                },
                icon: const Icon(LucideIcons.messageCircle, size: 18),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: colors.onSurfaceVariant,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.planner,
    required this.friendsCount,
    this.vendorsFollowed,
  });

  final PlannerProfile planner;
  final int friendsCount;
  final int? vendorsFollowed;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: AppCachedAvatar(
                      imageUrl: planner.avatarUrl,
                      radius: 36,
                      fallbackName: planner.name,
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
                              planner.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (planner.isPro) ...[
                            const GutterTiny(),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                child: Text(
                                  'Pro',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const GutterTiny(),
                      Text(
                        planner.role,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (planner.location.isNotEmpty) ...[
                        const GutterTiny(),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              size: 14,
                              color: colors.onSurfaceVariant,
                            ),
                            const GutterTiny(),
                            Text(
                              planner.location,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (planner.bio.isNotEmpty) ...[
              const Gutter(),
              Text(
                planner.bio,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ],
            const Gutter(),
            Row(
              children: [
                _Stat(value: '${planner.eventsCount}', label: 'Events'),
                _Stat(value: '${planner.postsCount}', label: 'Posts'),
                _Stat(value: _compact(friendsCount), label: 'Friends'),
                if (vendorsFollowed != null)
                  _Stat(value: _compact(vendorsFollowed!), label: 'Following'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _compact(int n) {
    if (n >= 1000) {
      final v = n / 1000;
      return v == v.roundToDouble()
          ? '${v.toInt()}k'
          : '${v.toStringAsFixed(1)}k';
    }
    return '$n';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(AppRoutes.postDetail(post.id)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: post.hasMedia
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    AppCachedNetworkImage(
                      imageUrl: post.mediaUrl,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.zero,
                    ),
                    if (post.type == FeedPostType.video)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            LucideIcons.play,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      post.caption,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
