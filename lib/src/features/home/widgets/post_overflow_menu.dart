import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/extensions/context_extension.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/features/social/models/planner_friendship.dart';
import 'package:ido_prime/src/features/social/providers/planner_friendship_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum PostMenuAction {
  addFriend,
  message,
  share,
  copyLink,
  save,
  notInterested,
  mute,
  report,
}

List<PopupMenuEntry<PostMenuAction>> _menuEntries(String authorName) => [
  _item(PostMenuAction.addFriend, LucideIcons.userPlus, 'Add $authorName'),
  _item(PostMenuAction.message, LucideIcons.messageCircle, 'Message'),
  const PopupMenuDivider(),
  _item(PostMenuAction.share, LucideIcons.share2, 'Share post'),
  _item(PostMenuAction.copyLink, LucideIcons.link, 'Copy link'),
  _item(PostMenuAction.save, LucideIcons.bookmark, 'Save post'),
  const PopupMenuDivider(),
  _item(PostMenuAction.notInterested, LucideIcons.eyeOff, 'Not interested'),
  _item(PostMenuAction.mute, LucideIcons.volumeX, 'Mute author'),
  _item(PostMenuAction.report, LucideIcons.flag, 'Report', destructive: true),
];

/// Overflow actions for a feed post (⋯). Anchors to [context]'s render box.
Future<void> showPostOverflowMenu(
  BuildContext context, {
  required String authorName,
  String? authorId,
}) async {
  final colors = Theme.of(context).colorScheme;
  final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
  final box = context.findRenderObject() as RenderBox?;
  final size = overlay.size;

  late final RelativeRect position;
  if (box != null && box.hasSize) {
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final bottomRight = box.localToGlobal(
      box.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    position = RelativeRect.fromLTRB(
      topLeft.dx.clamp(8.0, size.width - 8),
      bottomRight.dy,
      (size.width - bottomRight.dx).clamp(8.0, size.width - 8),
      (size.height - bottomRight.dy).clamp(0.0, size.height),
    );
  } else {
    position = RelativeRect.fromLTRB(size.width - 220, 72, 12, 0);
  }

  final maxH = MediaQuery.sizeOf(context).height * 0.45;

  final action = await showMenu<PostMenuAction>(
    context: context,
    position: position,
    constraints: BoxConstraints(maxWidth: 280, maxHeight: maxH),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    color: colors.surface,
    items: _menuEntries(authorName),
  );

  if (action == null || !context.mounted) return;
  await _handle(context, action, authorName, authorId: authorId);
}

PopupMenuItem<PostMenuAction> _item(
  PostMenuAction action,
  IconData icon,
  String label, {
  bool destructive = false,
}) {
  return PopupMenuItem(
    value: action,
    child: Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: destructive ? const Color(0xFFE25555) : null,
        ),
        const GutterSmall(),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: destructive ? const Color(0xFFE25555) : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<void> _handle(
  BuildContext context,
  PostMenuAction action,
  String authorName, {
  String? authorId,
}) async {
  final container = ProviderScope.containerOf(context);

  if (action == PostMenuAction.addFriend && authorId != null) {
    final friendship = container.read(plannerFriendshipProvider(authorId));
    if (friendship.status == FriendshipStatus.none ||
        friendship.status == FriendshipStatus.declined) {
      await container
          .read(plannerFriendshipProvider(authorId).notifier)
          .sendRequest();
      if (context.mounted) {
        context.showSnackBar('Friend request sent to $authorName');
      }
      return;
    }
    if (context.mounted) {
      context.push(AppRoutes.plannerProfile(authorId));
    }
    return;
  }

  if (action == PostMenuAction.message && authorId != null) {
    final friendship = container.read(plannerFriendshipProvider(authorId));
    if (friendship.status == FriendshipStatus.accepted) {
      if (context.mounted) {
        context.push(AppRoutes.plannerChat(authorId));
      }
      return;
    }
    if (context.mounted) {
      context.showSnackBar(
        'Chat unlocks after $authorName accepts your friend request',
      );
    }
    return;
  }

  final message = switch (action) {
    PostMenuAction.addFriend => 'Open profile to add $authorName',
    PostMenuAction.message =>
      'Chat unlocks after they accept your friend request',
    PostMenuAction.share => 'Share coming soon',
    PostMenuAction.copyLink => 'Link copied',
    PostMenuAction.save => 'Post saved',
    PostMenuAction.notInterested => 'We’ll show fewer posts like this',
    PostMenuAction.mute => 'Muted $authorName',
    PostMenuAction.report => 'Thanks — we’ll review this post',
  };
  if (action == PostMenuAction.copyLink) {
    Clipboard.setData(const ClipboardData(text: 'https://ido.app/posts'));
  }
  if (context.mounted) context.showSnackBar(message);
}

class PostOverflowMenuButton extends ConsumerWidget {
  const PostOverflowMenuButton({
    super.key,
    required this.authorName,
    this.authorId,
    this.iconColor,
  });

  final String authorName;
  final String? authorId;
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final maxH = MediaQuery.sizeOf(context).height * 0.45;

    return PopupMenuButton<PostMenuAction>(
      tooltip: 'More',
      offset: const Offset(0, 8),
      position: PopupMenuPosition.under,
      constraints: BoxConstraints(maxWidth: 280, maxHeight: maxH),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: colors.surface,
      onSelected: (action) =>
          _handle(context, action, authorName, authorId: authorId),
      itemBuilder: (context) => _menuEntries(authorName),
      icon: Icon(
        LucideIcons.ellipsisVertical,
        color: iconColor ?? colors.onSurfaceVariant,
      ),
    );
  }
}
