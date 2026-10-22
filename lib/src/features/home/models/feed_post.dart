enum FeedPostType { video, image, text }

class FeedPost {
  const FeedPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatarUrl,
    required this.caption,
    required this.type,
    this.mediaUrls = const [],
    this.likes = 0,
    this.comments = 0,
    this.timeAgo = '1 day ago',
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String authorAvatarUrl;
  final String caption;
  final FeedPostType type;
  final List<String> mediaUrls;
  final int likes;
  final int comments;
  final String timeAgo;

  /// First media URL (compat for single-image / video / fullscreen).
  String get mediaUrl => mediaUrls.isEmpty ? '' : mediaUrls.first;

  bool get hasMedia => mediaUrls.isNotEmpty;
}

FeedPost? findFeedPostById(String id) {
  for (final post in mockFeedPosts) {
    if (post.id == id) return post;
  }
  return null;
}

const mockFeedPosts = <FeedPost>[
  FeedPost(
    id: '1',
    authorId: 'sarah',
    authorName: 'Sarah Johnson',
    authorRole: 'Event Planner',
    authorAvatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    mediaUrls: [
      'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
      'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80',
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80',
    ],
    caption: 'Just wrapped up the most magical wedding at The Grand Manor! ✨',
    type: FeedPostType.image,
    likes: 2340,
    comments: 128,
    timeAgo: '2 hours ago',
  ),
  FeedPost(
    id: '2',
    authorId: 'alex',
    authorName: 'Alex Chen',
    authorRole: 'Birthday Specialist',
    authorAvatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
    mediaUrls: [
      'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80',
    ],
    caption: 'Sweet 16 dreams do come true! 🎈',
    type: FeedPostType.video,
    likes: 1492,
    comments: 89,
    timeAgo: '5 hours ago',
  ),
  FeedPost(
    id: '7',
    authorId: 'emma',
    authorName: 'Emma Thompson',
    authorRole: 'Planner',
    authorAvatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    caption:
        'Looking for a florist in Douala who can work with a soft peach '
        'palette for late September — any recommendations?',
    type: FeedPostType.text,
    likes: 48,
    comments: 12,
    timeAgo: '6 hours ago',
  ),
  FeedPost(
    id: '3',
    authorId: 'marcus',
    authorName: 'Marcus Williams',
    authorRole: 'Corporate Events',
    authorAvatarUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80',
    mediaUrls: [
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80',
      'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=800&q=80',
    ],
    caption:
        'Marcus Williams Tech Summit 2026 was a massive success! Over 500 attendees 🚀',
    type: FeedPostType.image,
    likes: 3421,
    comments: 3,
    timeAgo: '1 day ago',
  ),
  FeedPost(
    id: '4',
    authorId: 'lea',
    authorName: 'Léa Nguema',
    authorRole: 'Wedding DJ',
    authorAvatarUrl: '',
    mediaUrls: [
      'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&q=80',
    ],
    caption: 'Dance floor never empty — last night’s reception highlights.',
    type: FeedPostType.video,
    likes: 2104,
    comments: 67,
    timeAgo: '1 day ago',
  ),
  FeedPost(
    id: '8',
    authorId: 'noah',
    authorName: 'Noah Essomba',
    authorRole: 'Guest',
    authorAvatarUrl: '',
    caption:
        'Pro tip for planners: lock your catering headcount 10 days out. '
        'Saved us a last-minute scramble on Saturday.',
    type: FeedPostType.text,
    likes: 203,
    comments: 31,
    timeAgo: '1 day ago',
  ),
  FeedPost(
    id: '5',
    authorId: 'maya',
    authorName: 'Maya Okoro',
    authorRole: 'Floral Designer',
    authorAvatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
    mediaUrls: [
      'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800&q=80',
      'https://images.unsplash.com/photo-1487530811176-3780da4402bd?w=800&q=80',
      'https://images.unsplash.com/photo-1522673607200-164a2e1b4950?w=800&q=80',
    ],
    caption: 'Spring palette for an intimate garden brunch.',
    type: FeedPostType.image,
    likes: 876,
    comments: 42,
    timeAgo: '2 days ago',
  ),
  FeedPost(
    id: '6',
    authorId: 'jordan',
    authorName: 'Jordan Blake',
    authorRole: 'Venue Host',
    authorAvatarUrl: '',
    mediaUrls: [
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80',
    ],
    caption: 'Golden hour walkthrough of the new terrace wing.',
    type: FeedPostType.video,
    likes: 654,
    comments: 19,
    timeAgo: '3 days ago',
  ),
];
