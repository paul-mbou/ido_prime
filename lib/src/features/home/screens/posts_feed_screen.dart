import 'package:material_ui/material_ui.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/core/routing/app_routes.dart';
import 'package:ido_prime/src/core/shared/widgets/app_root_layout.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/home/models/feed_item.dart';
import 'package:ido_prime/src/features/home/providers/feed_posts_provider.dart';
import 'package:ido_prime/src/features/home/widgets/feed_event_card.dart';
import 'package:ido_prime/src/features/home/widgets/feed_post_card.dart';
import 'package:ido_prime/src/features/home/widgets/feed_reels_row.dart';
import 'package:ido_prime/src/features/home/widgets/feed_suggestions_card.dart';

class PostsFeedScreen extends ConsumerWidget {
  const PostsFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    final posts = ref.watch(feedPostsProvider);
    final feed = buildMixedFeed(posts: posts, events: events);

    return AppRootLayout(
      extendUnderAppBar: true,
      padding: EdgeInsets.only(top: 0, bottom: context.gutterLarge + 80),
      children: [
        for (final item in feed) ...[
          switch (item) {
            FeedReelsItem(:final reels) => FeedReelsRow(
              reels: reels,
              onReelTap: (reel) {
                final id = reel.plannerId;
                if (id == null) return;
                context.push(AppRoutes.plannerProfile(id));
              },
            ),
            FeedPostItem(:final post) => FeedPostCard(post: post),
            FeedEventItem(:final event) => FeedEventCard(event: event),
            FeedSuggestionsItem(:final suggestions) =>
              FeedSuggestionsCard(suggestions: suggestions),
          },
          const GutterLarge(),
        ],
      ],
    );
  }
}
