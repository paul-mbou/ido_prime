class MoodBoardVendor {
  const MoodBoardVendor({required this.name, required this.imageUrl});

  final String name;
  final String imageUrl;
}

class MoodBoard {
  const MoodBoard({
    required this.id,
    required this.name,
    required this.coverUrls,
    required this.lookIds,
    this.eventId,
    this.eventTitle,
    this.blurb = '',
    this.tags = const [],
    this.vendors = const [],
  });

  final String id;
  final String name;
  final List<String> coverUrls;
  final List<String> lookIds;
  final String? eventId;
  final String? eventTitle;
  final String blurb;
  final List<String> tags;
  final List<MoodBoardVendor> vendors;

  String get countLabel {
    final n = lookIds.length;
    return n == 1 ? '1 look' : '$n looks';
  }

  MoodBoard copyWith({
    String? name,
    List<String>? coverUrls,
    List<String>? lookIds,
    String? eventId,
    String? eventTitle,
    String? blurb,
    List<String>? tags,
    List<MoodBoardVendor>? vendors,
    bool clearEvent = false,
  }) {
    return MoodBoard(
      id: id,
      name: name ?? this.name,
      coverUrls: coverUrls ?? this.coverUrls,
      lookIds: lookIds ?? this.lookIds,
      eventId: clearEvent ? null : (eventId ?? this.eventId),
      eventTitle: clearEvent ? null : (eventTitle ?? this.eventTitle),
      blurb: blurb ?? this.blurb,
      tags: tags ?? this.tags,
      vendors: vendors ?? this.vendors,
    );
  }
}

final seedMoodBoards = <MoodBoard>[
  MoodBoard(
    id: 'gold-forest',
    name: 'Gold & forest',
    coverUrls: const [
      'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&h=800&fit=crop&q=80',
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400&h=400&fit=crop&q=80',
      'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=400&h=400&fit=crop&q=80',
      'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400&h=400&fit=crop&q=80',
    ],
    lookIds: const [
      'look-0',
      'look-3',
      'look-4',
      'look-6',
      'look-1',
      'look-5',
    ],
    eventId: '1',
    eventTitle: 'Summer Wedding',
    blurb:
        'Warm gold, deep greens, candlelight — the palette for outdoor '
        'evening vows in Douala.',
    tags: const ['Décor', 'Fleurs', 'Tables'],
    vendors: const [
      MoodBoardVendor(
        name: 'Lumina Décor',
        imageUrl:
            'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=96&h=96&fit=crop&q=80',
      ),
      MoodBoardVendor(
        name: 'Petale Studio',
        imageUrl:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=96&h=96&fit=crop&q=80',
      ),
      MoodBoardVendor(
        name: 'Table & Co',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=96&h=96&fit=crop&q=80',
      ),
    ],
  ),
  MoodBoard(
    id: 'dot-yaounde',
    name: 'Dot Yaoundé',
    coverUrls: const [
      'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600&h=800&fit=crop&q=80',
      'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?w=400&h=400&fit=crop&q=80',
      'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?w=400&h=400&fit=crop&q=80',
      'https://images.unsplash.com/photo-1519677100203-a0e668c92439?w=400&h=400&fit=crop&q=80',
    ],
    lookIds: const ['look-1', 'look-5', 'look-7', 'look-4', 'look-2'],
    eventId: '7',
    eventTitle: 'Rehearsal Dinner',
    blurb:
        'Bold color, traditional silhouettes, generous tables — celebration '
        'that feels like home.',
    tags: const ['Tenues', 'Menus', 'Traditional'],
    vendors: const [
      MoodBoardVendor(
        name: 'Atelier Ngo',
        imageUrl:
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=96&h=96&fit=crop&q=80',
      ),
      MoodBoardVendor(
        name: 'Saveurs Douala',
        imageUrl:
            'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=96&h=96&fit=crop&q=80',
      ),
      MoodBoardVendor(
        name: 'Press & Paper',
        imageUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=96&h=96&fit=crop&q=80',
      ),
    ],
  ),
  MoodBoard(
    id: 'kids-birthday',
    name: 'Kids birthday',
    coverUrls: const [
      'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=600&h=800&fit=crop&q=80',
      'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=400&h=400&fit=crop&q=80',
      'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?w=400&h=400&fit=crop&q=80',
    ],
    lookIds: const ['look-7', 'look-5', 'look-4'],
    blurb:
        'Playful color, soft balloons, cake-first tables — keep it joyful '
        'and easy to execute.',
    tags: const ['Menus', 'Tables'],
    vendors: const [
      MoodBoardVendor(
        name: 'Saveurs Douala',
        imageUrl:
            'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=96&h=96&fit=crop&q=80',
      ),
    ],
  ),
];
