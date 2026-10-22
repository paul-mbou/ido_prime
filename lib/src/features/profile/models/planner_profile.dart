import 'package:ido_prime/src/features/home/models/feed_post.dart';

class PlannerProfile {
  const PlannerProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    this.location = '',
    this.bio = '',
    this.eventsCount = 0,
    this.postsCount = 0,
    this.friendsCount = 0,
    this.isPro = false,
    this.isMe = false,
  });

  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final String location;
  final String bio;
  final int eventsCount;
  final int postsCount;

  /// Mock friends count for other planners (own count comes from friendship graph).
  final int friendsCount;
  final bool isPro;
  final bool isMe;

  /// Posts authored by this planner (from the mock feed).
  List<FeedPost> get posts =>
      mockFeedPosts.where((p) => p.authorId == id).toList(growable: false);
}

PlannerProfile? findPlannerById(String id) {
  for (final planner in mockPlanners) {
    if (planner.id == id) return planner;
  }
  return null;
}

const mockPlanners = <PlannerProfile>[
  PlannerProfile(
    id: 'emma',
    name: 'Emma Thompson',
    role: 'Planner',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    location: 'Douala',
    bio:
        'Planning celebrations with calm details and warm light. '
        'Currently prepping a soft-peach September wedding.',
    eventsCount: 12,
    postsCount: 1,
    friendsCount: 48,
    isPro: true,
    isMe: true,
  ),
  PlannerProfile(
    id: 'sarah',
    name: 'Sarah Johnson',
    role: 'Event Planner',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    location: 'Douala',
    bio:
        'Full-service weddings & garden ceremonies. '
        'I share real moments from the celebrations I build.',
    eventsCount: 28,
    postsCount: 1,
    friendsCount: 186,
    isPro: true,
  ),
  PlannerProfile(
    id: 'alex',
    name: 'Alex Chen',
    role: 'Birthday Specialist',
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
    location: 'Yaoundé',
    bio:
        'Milestone birthdays with bold color, cake drama, and dance floors '
        'that never empty.',
    eventsCount: 41,
    postsCount: 1,
    friendsCount: 92,
  ),
  PlannerProfile(
    id: 'marcus',
    name: 'Marcus Williams',
    role: 'Corporate Events',
    avatarUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80',
    location: 'Douala',
    bio: 'Summits, galas, and brand nights — production-forward, guest-first.',
    eventsCount: 19,
    postsCount: 1,
    friendsCount: 210,
    isPro: true,
  ),
  PlannerProfile(
    id: 'lea',
    name: 'Léa Nguema',
    role: 'Wedding DJ',
    avatarUrl: '',
    location: 'Douala',
    bio: 'Reading the room so the dance floor never stalls.',
    eventsCount: 60,
    postsCount: 1,
    friendsCount: 74,
  ),
  PlannerProfile(
    id: 'noah',
    name: 'Noah Essomba',
    role: 'Guest',
    avatarUrl: '',
    location: 'Yaoundé',
    bio: 'Sharing planning tips from the guest side of celebrations.',
    eventsCount: 3,
    postsCount: 1,
    friendsCount: 31,
  ),
  PlannerProfile(
    id: 'maya',
    name: 'Maya Okoro',
    role: 'Floral Designer',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
    location: 'Limbe',
    bio: 'Garden-inspired florals for intimate brunches and soft ceremonies.',
    eventsCount: 22,
    postsCount: 1,
    friendsCount: 58,
    isPro: true,
  ),
  PlannerProfile(
    id: 'jordan',
    name: 'Jordan Blake',
    role: 'Venue Host',
    avatarUrl: '',
    location: 'Douala',
    bio: 'Golden-hour walkthroughs of our terrace wing and garden courtyards.',
    eventsCount: 15,
    postsCount: 1,
    friendsCount: 44,
  ),
  PlannerProfile(
    id: 'emma-davis',
    name: 'Emma Davis',
    role: 'Guest',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
    location: 'Douala',
    bio: 'Always noticing the florals.',
    eventsCount: 2,
    postsCount: 0,
    friendsCount: 12,
  ),
  PlannerProfile(
    id: 'james',
    name: 'James Okonkwo',
    role: 'Planner',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
    location: 'Yaoundé',
    bio: 'Collaborations welcome — corporate and cultural celebrations.',
    eventsCount: 9,
    postsCount: 0,
    friendsCount: 27,
  ),
  PlannerProfile(
    id: 'sofia',
    name: 'Sofia Reyes',
    role: 'Lighting Designer',
    avatarUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
    location: 'Douala',
    bio: 'Light that guests still talk about the next morning.',
    eventsCount: 17,
    postsCount: 0,
    friendsCount: 39,
  ),
];
