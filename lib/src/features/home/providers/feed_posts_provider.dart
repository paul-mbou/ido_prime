import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/home/models/feed_post.dart';
import 'package:ido_prime/src/features/profile/models/user_account_profile.dart';

final feedPostsProvider = NotifierProvider<FeedPostsNotifier, List<FeedPost>>(
  FeedPostsNotifier.new,
);

class FeedPostsNotifier extends Notifier<List<FeedPost>> {
  @override
  List<FeedPost> build() => List<FeedPost>.from(mockFeedPosts);

  FeedPost? byId(String id) {
    for (final post in state) {
      if (post.id == id) return post;
    }
    return null;
  }

  FeedPost createPost({
    required UserAccountProfile author,
    required String caption,
    List<String> mediaUrls = const [],
  }) {
    final trimmed = caption.trim();
    final media = [
      for (final url in mediaUrls)
        if (url.trim().isNotEmpty) url.trim(),
    ];
    final type = media.isEmpty
        ? FeedPostType.text
        : FeedPostType.image;

    final post = FeedPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorId: author.id,
      authorName: author.displayName,
      authorRole: author.role,
      authorAvatarUrl: author.avatarUrl,
      caption: trimmed,
      type: type,
      mediaUrls: media,
      likes: 0,
      comments: 0,
      timeAgo: 'Just now',
    );
    state = [post, ...state];
    return post;
  }
}
