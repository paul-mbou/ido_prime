enum FeedSuggestionKind { vendor, user }

class FeedSuggestion {
  const FeedSuggestion({
    required this.id,
    required this.kind,
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    this.routeId,
  });

  final String id;
  final FeedSuggestionKind kind;
  final String name;
  final String subtitle;
  final String avatarUrl;

  /// Vendor id or user/post author id when navigating.
  final String? routeId;
}

const mockFeedSuggestions = <FeedSuggestion>[
  FeedSuggestion(
    id: 's1',
    kind: FeedSuggestionKind.vendor,
    name: 'Bloom & Vine Florals',
    subtitle: 'Florals · Midtown',
    avatarUrl:
        'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=200&q=80',
    routeId: '4',
  ),
  FeedSuggestion(
    id: 's2',
    kind: FeedSuggestionKind.user,
    name: 'Emma Thompson',
    subtitle: 'Planner · Douala',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    routeId: 'emma',
  ),
  FeedSuggestion(
    id: 's3',
    kind: FeedSuggestionKind.vendor,
    name: 'Lens & Light Studio',
    subtitle: 'Photography · Westside',
    avatarUrl:
        'https://images.unsplash.com/photo-1511285560929-80b456fe3cdb?w=200&q=80',
    routeId: '2',
  ),
  FeedSuggestion(
    id: 's4',
    kind: FeedSuggestionKind.user,
    name: 'Noah Essomba',
    subtitle: 'Member · Yaoundé',
    avatarUrl: '',
    routeId: 'noah',
  ),
  FeedSuggestion(
    id: 's5',
    kind: FeedSuggestionKind.vendor,
    name: 'Midnight Sound DJ',
    subtitle: 'Music · Downtown',
    avatarUrl:
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=200&q=80',
    routeId: '6',
  ),
];
