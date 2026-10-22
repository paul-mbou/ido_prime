import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/providers/events_provider.dart';
import 'package:ido_prime/src/features/home/models/feed_post.dart';
import 'package:ido_prime/src/features/home/models/feed_reel.dart';
import 'package:ido_prime/src/features/home/models/feed_suggestion.dart';

/// Heterogeneous feed slots: reels rail, posts, events, and suggestions.
sealed class FeedItem {
  const FeedItem();
}

class FeedReelsItem extends FeedItem {
  const FeedReelsItem(this.reels);
  final List<FeedReel> reels;
}

class FeedPostItem extends FeedItem {
  const FeedPostItem(this.post);
  final FeedPost post;
}

class FeedEventItem extends FeedItem {
  const FeedEventItem(this.event);
  final Event event;
}

class FeedSuggestionsItem extends FeedItem {
  const FeedSuggestionsItem(this.suggestions);
  final List<FeedSuggestion> suggestions;
}

/// Posts with events and suggestion rails interleaved; reels always first.
List<FeedItem> buildMixedFeed({
  List<FeedPost>? posts,
  List<Event>? events,
  List<FeedReel>? reels,
  List<FeedSuggestion>? suggestions,
}) {
  final postList = posts ?? mockFeedPosts;
  final eventList = events ?? mockEvents;
  final reelList = reels ?? mockFeedReels;
  final suggestionList = suggestions ?? mockFeedSuggestions;

  final items = <FeedItem>[FeedReelsItem(reelList)];
  final discoverable = eventList
      .where(
        (e) =>
            e.appearsInFeed &&
            e.effectiveStatus != EventStatus.past &&
            // Own private events stay off the social feed.
            !(e.isMine && e.visibility == EventVisibility.private),
      )
      .toList();
  var eventIndex = 0;
  var suggestionInserted = false;

  for (var i = 0; i < postList.length; i++) {
    items.add(FeedPostItem(postList[i]));

    // Melt an event after every 2nd post.
    if ((i + 1) % 2 == 0 && eventIndex < discoverable.length) {
      items.add(FeedEventItem(discoverable[eventIndex++]));
    }

    // Suggestions rail once, after the third post block.
    if (!suggestionInserted && i == 2) {
      items.add(FeedSuggestionsItem(suggestionList));
      suggestionInserted = true;
    }
  }

  while (eventIndex < discoverable.length) {
    items.add(FeedEventItem(discoverable[eventIndex++]));
  }

  if (!suggestionInserted && suggestionList.isNotEmpty) {
    items.add(FeedSuggestionsItem(suggestionList));
  }

  return items;
}
