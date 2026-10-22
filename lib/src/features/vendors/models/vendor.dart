class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.priceLevel,
    this.phone = '',
    this.email = '',
    this.bio = '',
    this.services = const <String>[],
    this.galleryUrls = const <String>[],
    this.yearsExperience = 0,
    this.responseTime = 'Within a day',
    this.isVerified = false,
    this.isAiMatch = false,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String category;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  /// 1–4 dollar signs highlighted (e.g. 1 → `$ $$$`).
  final int priceLevel;
  final String phone;
  final String email;
  final String bio;
  final List<String> services;
  final List<String> galleryUrls;
  final int yearsExperience;
  final String responseTime;
  final bool isVerified;
  final bool isAiMatch;
  final bool isFavorite;

  Vendor copyWith({bool? isFavorite}) {
    return Vendor(
      id: id,
      name: name,
      category: category,
      location: location,
      imageUrl: imageUrl,
      rating: rating,
      reviewCount: reviewCount,
      priceLevel: priceLevel,
      phone: phone,
      email: email,
      bio: bio,
      services: services,
      galleryUrls: galleryUrls,
      yearsExperience: yearsExperience,
      responseTime: responseTime,
      isVerified: isVerified,
      isAiMatch: isAiMatch,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

Vendor? findVendorById(String id) {
  for (final vendor in mockVendors) {
    if (vendor.id == id) return vendor;
  }
  return null;
}

const vendorCategories = <String>[
  'All',
  'Venues',
  'Catering',
  'Photography',
  'Florals',
  'Music',
];

const mockVendors = <Vendor>[
  Vendor(
    id: '1',
    name: 'Gourmet Catering Co.',
    category: 'Catering',
    location: 'Downtown',
    imageUrl:
        'https://images.unsplash.com/photo-1555244162-803834f70033?w=800&q=80',
    rating: 4.9,
    reviewCount: 342,
    priceLevel: 1,
    phone: '+1 555 010 1401',
    email: 'hello@gourmetcatering.co',
    bio:
        'Seasonal menus and plated service for weddings and private celebrations. '
        'We tailor tasting menus to your vibe — elegant, playful, or family-style.',
    services: ['Tasting menu', 'Plated dinner', 'Staffing', 'Bar package'],
    galleryUrls: [
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
      'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=600&q=80',
      'https://images.unsplash.com/photo-1467003909585-2f8a7f19c3a2?w=600&q=80',
    ],
    yearsExperience: 12,
    responseTime: 'Usually under 2 hours',
    isVerified: true,
    isAiMatch: true,
  ),
  Vendor(
    id: '2',
    name: 'Lens & Light Studio',
    category: 'Photography',
    location: 'Westside',
    imageUrl:
        'https://images.unsplash.com/photo-1511285560929-80b456fe3cdb?w=800&q=80',
    rating: 4.8,
    reviewCount: 218,
    priceLevel: 2,
    phone: '+1 555 010 1402',
    email: 'book@lensandlight.studio',
    bio:
        'Documentary-meets-editorial photography for weddings and milestones. '
        'Quiet presence, true color, and a gallery you will actually revisit.',
    services: ['Full day', 'Engagement session', 'Second shooter', 'Albums'],
    galleryUrls: [
      'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&q=80',
      'https://images.unsplash.com/photo-1520854221256-17451cc331bf?w=600&q=80',
      'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=600&q=80',
    ],
    yearsExperience: 9,
    responseTime: 'Same day',
    isVerified: true,
    isAiMatch: true,
  ),
  Vendor(
    id: '3',
    name: 'The Grand Manor',
    category: 'Venues',
    location: 'Garden District',
    imageUrl:
        'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80',
    rating: 4.7,
    reviewCount: 156,
    priceLevel: 3,
    phone: '+1 555 010 1403',
    email: 'events@grandmanor.com',
    bio:
        'Historic manor with garden courtyards and a ballroom for up to 220 guests. '
        'Ideal for ceremonies, dinners, and golden-hour portraits.',
    services: ['Ceremony', 'Reception', 'Bridal suite', 'On-site parking'],
    galleryUrls: [
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=600&q=80',
      'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=600&q=80',
      'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=600&q=80',
    ],
    yearsExperience: 20,
    responseTime: 'Within a day',
    isVerified: true,
    isAiMatch: false,
  ),
  Vendor(
    id: '4',
    name: 'Bloom & Vine Florals',
    category: 'Florals',
    location: 'Midtown',
    imageUrl:
        'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800&q=80',
    rating: 4.9,
    reviewCount: 97,
    priceLevel: 2,
    phone: '+1 555 010 1404',
    email: 'studio@bloomandvine.com',
    bio:
        'Garden-inspired florals with sustainable sourcing. From intimate bouquets '
        'to full venue installs that feel lush without excess.',
    services: ['Bridal bouquet', 'Centerpieces', 'Installs', 'Rentals'],
    galleryUrls: [
      'https://images.unsplash.com/photo-1487530811176-3780de880c2d?w=600&q=80',
      'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?w=600&q=80',
      'https://images.unsplash.com/photo-1455659817273-f9680774158c?w=600&q=80',
    ],
    yearsExperience: 7,
    responseTime: 'Usually under 4 hours',
    isVerified: true,
    isAiMatch: true,
  ),
  Vendor(
    id: '5',
    name: 'Harbor View Hall',
    category: 'Venues',
    location: 'Waterfront',
    imageUrl:
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80',
    rating: 4.6,
    reviewCount: 203,
    priceLevel: 4,
    phone: '+1 555 010 1405',
    email: 'reservations@harborviewhall.com',
    bio:
        'Waterfront hall with panoramic views and flexible floor plans. '
        'Perfect for sunset ceremonies and seated dinners by the water.',
    services: [
      'Waterfront views',
      'In-house AV',
      'Catering partners',
      'Overnight rooms',
    ],
    galleryUrls: [
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&q=80',
      'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=600&q=80',
      'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=600&q=80',
    ],
    yearsExperience: 15,
    responseTime: 'Within 2 days',
    isVerified: false,
    isAiMatch: false,
  ),
  Vendor(
    id: '6',
    name: 'Midnight Sound DJ',
    category: 'Music',
    location: 'Downtown',
    imageUrl:
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&q=80',
    rating: 4.8,
    reviewCount: 412,
    priceLevel: 1,
    phone: '+1 555 010 1406',
    email: 'bookings@midnightsound.dj',
    bio:
        'High-energy sets with thoughtful reading of the room. '
        'We bring lighting, mics, and a playlist consult so the dance floor never stalls.',
    services: ['DJ + MC', 'Lighting', 'Playlist consult', 'Ceremony audio'],
    galleryUrls: [
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&q=80',
      'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600&q=80',
      'https://images.unsplash.com/photo-1459749411175-0476931378b3?w=600&q=80',
    ],
    yearsExperience: 11,
    responseTime: 'Usually under 3 hours',
    isVerified: true,
    isAiMatch: false,
  ),
];
