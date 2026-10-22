import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_bubble_icon_button.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/shared/widgets/app_frosted_app_bar.dart';
import 'package:ido_prime/src/core/shared/widgets/scroll_chrome.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/home/models/feed_post.dart';
import 'package:ido_prime/src/features/home/models/post_comment.dart';
import 'package:ido_prime/src/features/home/providers/feed_posts_provider.dart';
import 'package:ido_prime/src/features/home/widgets/post_media_carousel.dart';
import 'package:ido_prime/src/features/home/widgets/post_overflow_menu.dart';
import 'package:ido_prime/src/features/home/widgets/text_post_panel.dart';
import 'package:ido_prime/src/features/social/models/planner_friendship.dart';
import 'package:ido_prime/src/features/social/providers/planner_friendship_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PostDetailScreen extends HookConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(
      feedPostsProvider.select((posts) {
        for (final p in posts) {
          if (p.id == postId) return p;
        }
        return null;
      }),
    );
    final frosted = useState(false);
    final chromeVisible = useState(true);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gutter = context.gutter;
    final appBarExtent = MediaQuery.paddingOf(context).top + kToolbarHeight + 1;

    if (post == null) {
      return Scaffold(
        appBar: AppFrostedAppBar(
          title: const Text('Post'),
          showCircleActions: true,
          actions: [
            AppCircleIconButton(
              icon: LucideIcons.ellipsisVertical,
              onPressed: () {},
            ),
            const GutterSmall(),
          ],
        ),
        body: const Center(child: Text('Post not found')),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 1),
        child: ScrollChromeSlide(
          visible: chromeVisible.value,
          edge: ScrollChromeEdge.top,
          child: AppFrostedAppBar(
            frosted: frosted.value,
            showCircleActions: true,
            title: Text(
              'Post',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              Builder(
                builder: (btnContext) => AppCircleIconButton(
                  icon: LucideIcons.ellipsisVertical,
                  onPressed: () => showPostOverflowMenu(
                    btnContext,
                    authorName: post.authorName,
                    authorId: post.authorId,
                  ),
                ),
              ),
              const GutterSmall(),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.axis == Axis.vertical) {
                  final next = notification.metrics.pixels > 2;
                  if (next != frosted.value) frosted.value = next;
                }
                updateScrollChromeVisibility(
                  notification,
                  visible: chromeVisible.value,
                  onVisibilityChanged: (value) => chromeVisible.value = value,
                );
                return false;
              },
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      appBarExtent + 8,
                      gutter,
                      24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _PostAuthorHeader(post: post),
                        const Gutter(),
                        if (post.type == FeedPostType.image)
                          PostMediaCarousel(
                            urls: post.mediaUrls,
                            heroTagPrefix: 'post-${post.id}',
                            initialIndex: 0,
                            onTapImage: (index) => context.push(
                              AppRoutes.postFullscreenImage(post.id),
                              extra: index,
                            ),
                          )
                        else if (post.type == FeedPostType.video)
                          GestureDetector(
                            onTap: () => context.push(
                              AppRoutes.postFullscreenImage(post.id),
                            ),
                            child: AspectRatio(
                              aspectRatio: 4 / 4.1,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  AppCachedNetworkImage(
                                    imageUrl: post.mediaUrl,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  const Center(
                                    child: Icon(
                                      LucideIcons.play,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          TextPostPanel(
                            caption: post.caption,
                            timeAgo: post.timeAgo,
                          ),
                        if (post.type != FeedPostType.text) ...[
                          const GutterSmall(),
                          _EngagementRow(
                            likes: post.likes,
                            comments: post.comments,
                          ),
                          const GutterSmall(),
                          Text(
                            post.caption,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ] else ...[
                          const GutterSmall(),
                          _EngagementRow(
                            likes: post.likes,
                            comments: post.comments,
                          ),
                        ],
                        const Gutter(),
                        Divider(color: colors.outline.withValues(alpha: 0.5)),
                        const Gutter(),
                        Text(
                          'Comments (${mockPostComments.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gutter(),
                        for (final comment in mockPostComments) ...[
                          _CommentTile(comment: comment),
                          const Gutter(),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _CommentComposer(),
        ],
      ),
    );
  }
}

class _PostAuthorHeader extends ConsumerWidget {
  const _PostAuthorHeader({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final friendship = ref.watch(plannerFriendshipProvider(post.authorId));
    final isMe = post.authorId == 'emma';

    String? friendLabel;
    if (!isMe) {
      friendLabel = switch (friendship.status) {
        FriendshipStatus.accepted => 'Friends',
        FriendshipStatus.pendingOutgoing => 'Pending',
        FriendshipStatus.pendingIncoming => 'Respond',
        FriendshipStatus.declined || FriendshipStatus.none => 'Add friend',
      };
    }

    return Row(
      children: [
        InkWell(
          onTap: () => context.push(AppRoutes.plannerProfile(post.authorId)),
          customBorder: const CircleBorder(),
          child: AppCachedAvatar(
            imageUrl: post.authorAvatarUrl,
            radius: 22,
            fallbackName: post.authorName,
          ),
        ),
        const GutterSmall(),
        Expanded(
          child: InkWell(
            onTap: () => context.push(AppRoutes.plannerProfile(post.authorId)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${post.authorRole} • ${post.timeAgo}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (friendLabel != null)
          TextButton(
            onPressed: () {
              if (friendship.status == FriendshipStatus.none ||
                  friendship.status == FriendshipStatus.declined) {
                ref
                    .read(plannerFriendshipProvider(post.authorId).notifier)
                    .sendRequest();
              } else {
                context.push(AppRoutes.plannerProfile(post.authorId));
              }
            },
            child: Text(
              friendLabel,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: friendship.status == FriendshipStatus.accepted
                    ? theme.colorScheme.onSurfaceVariant
                    : AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _EngagementRow extends HookWidget {
  const _EngagementRow({required this.likes, required this.comments});

  final int likes;
  final int comments;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final liked = useState(false);
    final bookmarked = useState(false);
    final likeCount = useState(likes);
    final idle = colors.onSurface;

    return Row(
      children: [
        AppBubbleIconButton(
          icon: LucideIcons.heart,
          label: '${likeCount.value}',
          color: liked.value ? AppColors.like : idle,
          labelColor: idle,
          fill: liked.value ? 1 : 0,
          bubbleColor: AppColors.like,
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          onPressed: () {
            liked.value = !liked.value;
            likeCount.value += liked.value ? 1 : -1;
          },
        ),
        const Gutter(),
        _Metric(
          icon: LucideIcons.messageCircle,
          label: '$comments',
          iconColor: idle,
          labelColor: idle,
        ),
        const Gutter(),
        Icon(LucideIcons.share2, size: 22, color: idle),
        const Spacer(),
        AppBubbleIconButton(
          icon: LucideIcons.bookmark,
          color: bookmarked.value ? AppColors.primary : idle,
          fill: bookmarked.value ? 1 : 0,
          bubbleColor: AppColors.primary,
          padding: const EdgeInsets.all(4),
          onPressed: () => bookmarked.value = !bookmarked.value,
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.labelColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: iconColor),
        const Gutter.custom(size: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final PostComment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => context.push(AppRoutes.plannerProfile(comment.authorId)),
          customBorder: const CircleBorder(),
          child: AppCachedAvatar(
            imageUrl: comment.authorAvatarUrl,
            radius: 18,
            fallbackName: comment.authorName,
          ),
        ),
        const GutterSmall(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => context.push(
                          AppRoutes.plannerProfile(comment.authorId),
                        ),
                        child: Text(
                          comment.authorName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const GutterTiny(),
                      Text(
                        comment.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gutter.custom(size: 6),
              Row(
                children: [
                  Text(
                    comment.timeAgo,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                  const Gutter.custom(size: 12),
                  Text(
                    'Like',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gutter.custom(size: 12),
                  Text(
                    'Reply',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentComposer extends HookWidget {
  const _CommentComposer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final controller = useTextEditingController();
    final canSend = useState(false);

    useEffect(() {
      void listener() => canSend.value = controller.text.trim().isNotEmpty;
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    return Material(
      color: theme.navigationBarTheme.backgroundColor ?? AppColors.bottomNav,
      child: SafeArea(
        top: false,
        // Home indicator only when the keyboard is closed.
        bottom: !keyboardOpen,
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.gutter, 10, context.gutter, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: 'Add a comment…',
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 88,
                      minHeight: 40,
                    ),
                    prefixIcon: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {},
                      icon: Icon(
                        LucideIcons.smile,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                      tooltip: 'Emoji',
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {},
                          icon: Icon(
                            LucideIcons.image,
                            size: 20,
                            color: colors.onSurfaceVariant,
                          ),
                          tooltip: 'Image',
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {},
                          icon: Icon(
                            LucideIcons.paperclip,
                            size: 20,
                            color: colors.onSurfaceVariant,
                          ),
                          tooltip: 'Attach',
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const GutterSmall(),
              IconButton.filled(
                onPressed: canSend.value
                    ? () {
                        controller.clear();
                        canSend.value = false;
                      }
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: canSend.value
                      ? AppColors.primary
                      : colors.surfaceContainerHighest,
                  foregroundColor: canSend.value
                      ? AppColors.onPrimary
                      : colors.onSurfaceVariant,
                  disabledBackgroundColor: colors.surfaceContainerHighest,
                  disabledForegroundColor: colors.onSurfaceVariant,
                ),
                icon: const Icon(LucideIcons.send, size: 18),
                tooltip: 'Send',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
