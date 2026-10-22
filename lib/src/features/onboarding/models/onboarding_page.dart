import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.unsplashId,
    this.alignment = Alignment.center,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;

  /// Unsplash photo id, e.g. `photo-1519741497674-611481863552`.
  final String unsplashId;

  /// Focal point when cropping full-bleed on tall/wide screens.
  final Alignment alignment;

  /// High-res CDN URL sized to the current display (physical pixels).
  String imageUrlFor(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final longestLogical = math.max(size.width, size.height);
    final targetPx = (longestLogical * dpr).round();
    // Prefer sharp full-bleed: min 1600, up to 3200 on large / high-DPR screens.
    final width = targetPx.clamp(1600, 3200);
    final height = (width * 1.35).round().clamp(1800, 4200);
    return 'https://images.unsplash.com/$unsplashId'
        '?auto=format&fit=crop&w=$width&h=$height&q=90';
  }
}

/// Product tour pages — celebration lifestyle, not generic SaaS.
///
/// Photo IDs verified live (HTTP 200). Prefer sharp, well-lit subjects.
const onboardingPages = <OnboardingPageData>[
  OnboardingPageData(
    icon: LucideIcons.calendarHeart,
    eyebrow: 'Plan',
    title: 'Celebrate on your terms',
    body:
        'Weddings, birthdays, brunches — build the day with a calm plan, '
        'budget, and checklist that stays yours.',
    // High-res wedding (replaces broken 404 photo).
    unsplashId: 'photo-1519741497674-611481863552',
    alignment: Alignment(0, -0.12),
  ),
  OnboardingPageData(
    icon: LucideIcons.store,
    eyebrow: 'Discover',
    title: 'Vendors that match the mood',
    body:
        'Browse florists, venues, DJs, and more — with AI-matched ideas '
        'tied to the celebration you’re planning.',
    unsplashId: 'photo-1606800052052-a08af7148866',
    alignment: Alignment.center,
  ),
  OnboardingPageData(
    icon: LucideIcons.palette,
    eyebrow: 'Inspire',
    title: 'Collect looks & vibes',
    body:
        'Save décor, tables, and outfits to boards. Shape the feeling of '
        'your event before you book a single detail.',
    unsplashId: 'photo-1519167758481-83f550bb49b3',
    alignment: Alignment(0, -0.18),
  ),
  OnboardingPageData(
    icon: LucideIcons.mic,
    eyebrow: 'Share & ask',
    title: 'Moments, friends, and a co-pilot',
    body:
        'Share celebration posts, invite guests, and ask IDO’s AI — '
        'with your voice if you like — when you need a faster decision.',
    unsplashId: 'photo-1511795409834-ef04bbd61622',
    alignment: Alignment.center,
  ),
];
