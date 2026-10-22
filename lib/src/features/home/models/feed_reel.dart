class FeedReel {
  const FeedReel({
    required this.id,
    required this.authorName,
    required this.avatarUrl,
    required this.coverUrl,
    this.plannerId,
    this.hasUnseen = true,
    this.isMine = false,
  });

  final String id;
  final String authorName;
  final String avatarUrl;
  final String coverUrl;
  final String? plannerId;
  final bool hasUnseen;
  final bool isMine;
}

const mockFeedReels = <FeedReel>[
  FeedReel(
    id: 'me',
    authorName: 'Your story',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    coverUrl: '',
    plannerId: 'emma',
    hasUnseen: false,
    isMine: true,
  ),
  FeedReel(
    id: 'r1',
    authorName: 'Sarah',
    plannerId: 'sarah',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    coverUrl:
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80',
  ),
  FeedReel(
    id: 'r2',
    authorName: 'Alex',
    plannerId: 'alex',
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
    coverUrl:
        'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600&q=80',
  ),
  FeedReel(
    id: 'r3',
    authorName: 'Maya',
    plannerId: 'maya',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
    coverUrl:
        'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=600&q=80',
  ),
  FeedReel(
    id: 'r4',
    authorName: 'Marcus',
    plannerId: 'marcus',
    avatarUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80',
    coverUrl:
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&q=80',
  ),
  FeedReel(
    id: 'r5',
    authorName: 'Léa',
    plannerId: 'lea',
    avatarUrl: '',
    coverUrl:
        'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=600&q=80',
  ),
  FeedReel(
    id: 'r6',
    authorName: 'Jordan',
    plannerId: 'jordan',
    avatarUrl: '',
    coverUrl:
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=600&q=80',
    hasUnseen: false,
  ),
];
