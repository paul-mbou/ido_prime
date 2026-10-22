import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_bubble_icon_button.dart';
import 'package:ido_prime/src/core/shared/widgets/app_cached_network_image.dart';
import 'package:ido_prime/src/core/theme/app_colors.dart';
import 'package:ido_prime/src/features/home/models/feed_post.dart';
import 'package:ido_prime/src/features/home/widgets/post_media_carousel.dart';
import 'package:ido_prime/src/features/home/widgets/post_overflow_menu.dart';
import 'package:ido_prime/src/features/home/widgets/text_post_panel.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({super.key, required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    return switch (post.type) {
      FeedPostType.video => _VideoFeedPost(post: post),
      FeedPostType.image => _ImageFeedPost(post: post),
      FeedPostType.text => _TextFeedPost(post: post),
    };
  }
}

class _VideoFeedPost extends HookWidget {
  const _VideoFeedPost({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final commentOpen = useState(false);
    final commentCount = useState(post.comments);
    final fade = Theme.of(context).scaffoldBackgroundColor;

    final side = EdgeInsets.symmetric(horizontal: context.gutter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: side,
          child: _PostHeader(post: post),
        ),
        const GutterSmall(),
        GestureDetector(
          onTap: () => context.push(AppRoutes.postDetail(post.id)),
          child: AspectRatio(
            aspectRatio: 4 / 4.1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppCachedNetworkImage(
                  imageUrl: post.mediaUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.zero,
                  errorWidget: ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: Icon(
                      LucideIcons.imageOff,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        fade.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
                const Center(child: _PlayButton()),
              ],
            ),
          ),
        ),
        const GutterSmall(),
        Padding(
          padding: side,
          child: _EngagementRow(
            likes: post.likes,
            comments: commentCount.value,
            commentOpen: commentOpen.value,
            onCommentPressed: () => commentOpen.value = !commentOpen.value,
          ),
        ),
        if (commentOpen.value) ...[
          const GutterSmall(),
          Padding(
            padding: side,
            child: _InlineCommentComposer(
              onSubmitted: () {
                commentCount.value += 1;
                commentOpen.value = false;
                context.showSnackBar('Comment posted');
              },
              onDismiss: () => commentOpen.value = false,
            ),
          ),
        ],
        const GutterTiny(),
        Padding(
          padding: side,
          child: _Caption(post: post),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: SizedBox(
          width: 72,
          height: 72,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.25,
              ),
            ),
            child: const Icon(LucideIcons.play, color: Colors.white, size: 36),
          ),
        ),
      ),
    );
  }
}

class _ImageFeedPost extends HookWidget {
  const _ImageFeedPost({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final commentOpen = useState(false);
    final commentCount = useState(post.comments);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post),
          const GutterSmall(),
          PostMediaCarousel(
            urls: post.mediaUrls,
            heroTagPrefix: 'feed-${post.id}',
            onTapImage: (index) =>
                context.push(AppRoutes.postDetail(post.id), extra: index),
          ),
          const GutterSmall(),
          _EngagementRow(
            likes: post.likes,
            comments: commentCount.value,
            commentOpen: commentOpen.value,
            onCommentPressed: () => commentOpen.value = !commentOpen.value,
          ),
          if (commentOpen.value) ...[
            const GutterSmall(),
            _InlineCommentComposer(
              onSubmitted: () {
                commentCount.value += 1;
                commentOpen.value = false;
                context.showSnackBar('Comment posted');
              },
              onDismiss: () => commentOpen.value = false,
            ),
          ],
          const GutterTiny(),
          _Caption(post: post),
        ],
      ),
    );
  }
}

class _TextFeedPost extends HookWidget {
  const _TextFeedPost({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final commentOpen = useState(false);
    final commentCount = useState(post.comments);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post),
          const GutterSmall(),
          GestureDetector(
            onTap: () => context.push(AppRoutes.postDetail(post.id)),
            behavior: HitTestBehavior.opaque,
            child: TextPostPanel(
              caption: post.caption,
              timeAgo: post.timeAgo,
              maxLines: 2,
            ),
          ),
          const GutterSmall(),
          _EngagementRow(
            likes: post.likes,
            comments: commentCount.value,
            commentOpen: commentOpen.value,
            onCommentPressed: () => commentOpen.value = !commentOpen.value,
          ),
          if (commentOpen.value) ...[
            const GutterSmall(),
            _InlineCommentComposer(
              onSubmitted: () {
                commentCount.value += 1;
                commentOpen.value = false;
                context.showSnackBar('Comment posted');
              },
              onDismiss: () => commentOpen.value = false,
            ),
          ],
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.plannerProfile(post.authorId)),
            behavior: HitTestBehavior.opaque,
            child: _AuthorRow(
              name: post.authorName,
              role: post.authorRole,
              avatarUrl: post.authorAvatarUrl,
            ),
          ),
        ),
        PostOverflowMenuButton(
          authorName: post.authorName,
          authorId: post.authorId,
        ),
      ],
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.postDetail(post.id)),
      behavior: HitTestBehavior.opaque,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${post.authorName} ',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            TextSpan(
              text: post.caption,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                height: 1.35,
              ),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  final String name;
  final String role;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        AppCachedAvatar(imageUrl: avatarUrl, radius: 18, fallbackName: name),
        const GutterSmall(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              Text(
                role,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EngagementRow extends HookWidget {
  const _EngagementRow({
    required this.likes,
    required this.comments,
    required this.commentOpen,
    required this.onCommentPressed,
  });

  final int likes;
  final int comments;
  final bool commentOpen;
  final VoidCallback onCommentPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final liked = useState(false);
    final bookmarked = useState(false);
    final likeCount = useState(likes);

    final idleColor = colors.onSurface;

    return Row(
      children: [
        AppBubbleIconButton(
          icon: LucideIcons.heart,
          label: '${likeCount.value}',
          color: liked.value ? AppColors.like : idleColor,
          labelColor: idleColor,
          fill: liked.value ? 1 : 0,
          bubbleColor: AppColors.like,
          onPressed: () {
            liked.value = !liked.value;
            likeCount.value += liked.value ? 1 : -1;
          },
        ),
        const Gutter(),
        _ActionChip(
          icon: LucideIcons.messageCircle,
          label: '$comments',
          iconColor: commentOpen ? AppColors.primary : idleColor,
          labelColor: idleColor,
          filled: false,
          onPressed: onCommentPressed,
        ),
        const Gutter(),
        IconButton(
          onPressed: () => context.showSnackBar('Share coming soon'),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(LucideIcons.share2, size: 22),
          color: idleColor,
        ),
        const Spacer(),
        AppBubbleIconButton(
          icon: LucideIcons.bookmark,
          size: 24,
          color: bookmarked.value ? AppColors.primary : idleColor,
          fill: bookmarked.value ? 1 : 0,
          bubbleColor: AppColors.primary,
          padding: EdgeInsets.zero,
          onPressed: () => bookmarked.value = !bookmarked.value,
        ),
      ],
    );
  }
}

class _InlineCommentComposer extends HookWidget {
  const _InlineCommentComposer({
    required this.onSubmitted,
    required this.onDismiss,
  });

  final VoidCallback onSubmitted;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final canSend = useState(false);

    useEffect(() {
      void listener() => canSend.value = controller.text.trim().isNotEmpty;
      controller.addListener(listener);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (focusNode.canRequestFocus) focusNode.requestFocus();
      });
      return () => controller.removeListener(listener);
    }, [controller, focusNode]);

    void submit() {
      if (controller.text.trim().isEmpty) return;
      onSubmitted();
    }

    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => submit(),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Write a comment…',
                filled: true,
                fillColor: colors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: colors.outline.withValues(alpha: 0.7),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: colors.outline.withValues(alpha: 0.7),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const GutterSmall(),
          IconButton(
            onPressed: canSend.value ? submit : onDismiss,
            style: IconButton.styleFrom(
              backgroundColor: canSend.value
                  ? AppColors.primary
                  : colors.surfaceContainerHighest.withValues(alpha: 0.55),
              foregroundColor: canSend.value
                  ? AppColors.onPrimary
                  : colors.onSurfaceVariant,
            ),
            icon: Icon(
              canSend.value ? LucideIcons.send : LucideIcons.x,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.iconColor,
    required this.labelColor,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color iconColor;
  final Color labelColor;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: iconColor, fill: filled ? 1 : 0),
              const Gutter.custom(size: 6),
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
