class InspirationLook {
  const InspirationLook({
    required this.id,
    required this.category,
    required this.title,
    required this.copy,
    required this.imageUrl,
    required this.vendorName,
    required this.vendorImageUrl,
    required this.tags,
    this.heightFactor = 1.0,
    this.nearYouPlace,
  });

  final String id;
  final String category;
  final String title;
  final String copy;
  final String imageUrl;
  final String vendorName;
  final String vendorImageUrl;
  final List<String> tags;

  /// Relative tile height for masonry (1.0 = base).
  final double heightFactor;

  /// When set, show in the “Near you” rail.
  final String? nearYouPlace;
}

const inspirationCategories = <String>[
  'All',
  'Décor',
  'Tenues',
  'Tables',
  'Lieux',
  'Fleurs',
  'Menus',
];

const mockInspirationLooks = <InspirationLook>[
  InspirationLook(
    id: 'look-0',
    category: 'Décor',
    title: 'Candlelit forest arch',
    copy:
        'Soft gold candles and greenery for an evening outdoor vow exchange. '
        'Warm, intimate, and easy to scale for 80–200 guests.',
    imageUrl:
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=600&h=800&fit=crop&q=80',
    vendorName: 'Lumina Décor',
    vendorImageUrl:
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=96&h=96&fit=crop&q=80',
    tags: ['Décor', 'Outdoor', 'Douala'],
    heightFactor: 1.15,
    nearYouPlace: 'Bonanjo · Décor',
  ),
  InspirationLook(
    id: 'look-1',
    category: 'Tenues',
    title: 'Ivory & gold traditional',
    copy:
        'Modern cut with local embroidery — statement without overpowering '
        'the celebration palette.',
    imageUrl:
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600&h=900&fit=crop&q=80',
    vendorName: 'Atelier Ngo',
    vendorImageUrl:
        'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=96&h=96&fit=crop&q=80',
    tags: ['Tenues', 'Wedding'],
    heightFactor: 1.35,
  ),
  InspirationLook(
    id: 'look-2',
    category: 'Lieux',
    title: 'Coastal pavilion at dusk',
    copy:
        'Open-air pavilion with sea breeze and string lights — Kribi energy '
        'for vows or cocktail hour.',
    imageUrl:
        'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=600&h=700&fit=crop&q=80',
    vendorName: 'Vista Venues',
    vendorImageUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=96&h=96&fit=crop&q=80',
    tags: ['Lieux', 'Kribi'],
    heightFactor: 0.95,
    nearYouPlace: 'Kribi · Lieux',
  ),
  InspirationLook(
    id: 'look-3',
    category: 'Fleurs',
    title: 'Cascading white bouquet',
    copy:
        'Loose, romantic cascade — pairs with gold & forest boards and low '
        'table meadows.',
    imageUrl:
        'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=600&h=850&fit=crop&q=80',
    vendorName: 'Petale Studio',
    vendorImageUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=96&h=96&fit=crop&q=80',
    tags: ['Fleurs', 'Bridal'],
    heightFactor: 1.2,
  ),
  InspirationLook(
    id: 'look-4',
    category: 'Tables',
    title: 'Long table, gold runners',
    copy:
        'Banquet layout with forest greens and gold chargers — clear path '
        'for family-style service.',
    imageUrl:
        'https://images.unsplash.com/photo-1507504031003-b417219a0fde?w=600&h=750&fit=crop&q=80',
    vendorName: 'Table & Co',
    vendorImageUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=96&h=96&fit=crop&q=80',
    tags: ['Tables', 'Reception'],
    heightFactor: 1.05,
    nearYouPlace: 'Akwa · Tables',
  ),
  InspirationLook(
    id: 'look-5',
    category: 'Menus',
    title: 'Shared platter feast',
    copy:
        'Communal platters, bold spices, elegant plating — celebration food '
        'that feels generous.',
    imageUrl:
        'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&h=880&fit=crop&q=80',
    vendorName: 'Saveurs Douala',
    vendorImageUrl:
        'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=96&h=96&fit=crop&q=80',
    tags: ['Menus', 'Catering'],
    heightFactor: 1.28,
  ),
  InspirationLook(
    id: 'look-6',
    category: 'Décor',
    title: 'Hanging lantern aisle',
    copy:
        'Layered lanterns and soft petals — dramatic entrance without '
        'blocking guest flow.',
    imageUrl:
        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=600&h=780&fit=crop&q=80',
    vendorName: 'Lumina Décor',
    vendorImageUrl:
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=96&h=96&fit=crop&q=80',
    tags: ['Décor', 'Aisle'],
    heightFactor: 1.1,
  ),
  InspirationLook(
    id: 'look-7',
    category: 'Invitations',
    title: 'Minimal gold foil invite',
    copy:
        'Clean typography, soft lavender stock, gold foil — WhatsApp-ready '
        'crop included.',
    imageUrl:
        'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=600&h=650&fit=crop&q=80',
    vendorName: 'Press & Paper',
    vendorImageUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=96&h=96&fit=crop&q=80',
    tags: ['Invitations'],
    heightFactor: 0.9,
  ),
];

InspirationLook? findInspirationLookById(String id) {
  for (final look in mockInspirationLooks) {
    if (look.id == id) return look;
  }
  return null;
}
