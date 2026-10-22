class PostComment {
  const PostComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.body,
    required this.timeAgo,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String body;
  final String timeAgo;
}

const mockPostComments = <PostComment>[
  PostComment(
    id: 'c1',
    authorId: 'emma-davis',
    authorName: 'Emma Davis',
    authorAvatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
    body: 'This is absolutely stunning! The floral arrangements are perfection 😍',
    timeAgo: '1 hour ago',
  ),
  PostComment(
    id: 'c2',
    authorId: 'james',
    authorName: 'James Okonkwo',
    authorAvatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
    body: 'Incredible production value. Would love to collaborate next year!',
    timeAgo: '3 hours ago',
  ),
  PostComment(
    id: 'c3',
    authorId: 'sofia',
    authorName: 'Sofia Reyes',
    authorAvatarUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
    body: 'The lighting setup was chef’s kiss. Guests are still talking about it.',
    timeAgo: '5 hours ago',
  ),
];
