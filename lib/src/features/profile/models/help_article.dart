import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum HelpTopic { all, gettingStarted, events, vendors, inspiration, account }

extension HelpTopicX on HelpTopic {
  String get label => switch (this) {
    HelpTopic.all => 'All',
    HelpTopic.gettingStarted => 'Getting started',
    HelpTopic.events => 'Events',
    HelpTopic.vendors => 'Vendors',
    HelpTopic.inspiration => 'Inspiration',
    HelpTopic.account => 'Account',
  };

  IconData get icon => switch (this) {
    HelpTopic.all => LucideIcons.layoutGrid,
    HelpTopic.gettingStarted => LucideIcons.sparkles,
    HelpTopic.events => LucideIcons.calendarDays,
    HelpTopic.vendors => LucideIcons.store,
    HelpTopic.inspiration => LucideIcons.images,
    HelpTopic.account => LucideIcons.userRound,
  };
}

class HelpArticle {
  const HelpArticle({
    required this.id,
    required this.topic,
    required this.question,
    required this.answer,
  });

  final String id;
  final HelpTopic topic;
  final String question;
  final String answer;
}

const helpArticles = <HelpArticle>[
  HelpArticle(
    id: 'gs-1',
    topic: HelpTopic.gettingStarted,
    question: 'What is IDO?',
    answer:
        'IDO is your celebration companion — plan events, discover vendors, '
        'save inspiration looks, share moments with the community, and ask the '
        'AI co-pilot when you need ideas.',
  ),
  HelpArticle(
    id: 'gs-2',
    topic: HelpTopic.gettingStarted,
    question: 'Planner vs Vendor space — what’s the difference?',
    answer:
        'Planner space is for guests and hosts planning celebrations. '
        'Vendor space unlocks business tools once your vendor profile is '
        'approved. Switch spaces anytime from Profile.',
  ),
  HelpArticle(
    id: 'ev-1',
    topic: HelpTopic.events,
    question: 'How do I create an event?',
    answer:
        'Open the Events tab and tap the gold + button (or “Plan an event”). '
        'You’ll set a name, date, cover, visibility, free or paid entry, and '
        'budget. For paid events, set up a ticket page (price & quantity). '
        'Drafts are saved if you leave midway. Entry (tickets) is separate '
        'from your planning budget.',
  ),
  HelpArticle(
    id: 'ev-1b',
    topic: HelpTopic.events,
    question: 'What’s the difference between free, paid, and budget?',
    answer:
        'Free or paid is how guests get in: free RSVP via invites, or paid '
        'tickets on a ticket page. Your budget is what you plan to spend '
        'organizing the event (venue, catering, etc.) — it is not the ticket '
        'price guests pay.',
  ),
  HelpArticle(
    id: 'ev-2',
    topic: HelpTopic.events,
    question: 'Can I share an invitation card?',
    answer:
        'Yes. On your event detail, open Invitations and use Share card to '
        'export a PNG with your RSVP link. Guests can reply from the link.',
  ),
  HelpArticle(
    id: 'ev-3',
    topic: HelpTopic.events,
    question: 'Who can see my private events?',
    answer:
        'Private events stay off the social feed and are only visible to you '
        'and people you invite. Public and friends-only events can appear in '
        'the feed when you choose.',
  ),
  HelpArticle(
    id: 'vn-1',
    topic: HelpTopic.vendors,
    question: 'How do I contact a vendor?',
    answer:
        'Open a vendor profile and tap Contact for event (Planner space only). '
        'Pick one of your events, send a connection request, and chat unlocks '
        'after the vendor accepts. Vendors can’t message other vendors — switch '
        'to Planner space first. Anyone can Follow a vendor without contacting.',
  ),
  HelpArticle(
    id: 'vn-2',
    topic: HelpTopic.vendors,
    question: 'How do I become a vendor on IDO?',
    answer:
        'From Profile, tap Become a vendor and complete identity, services, '
        'and KYC. When approved, switch to Vendor space to manage your business '
        'profile and offers.',
  ),
  HelpArticle(
    id: 'in-1',
    topic: HelpTopic.inspiration,
    question: 'What are mood boards?',
    answer:
        'Mood boards collect looks (décor, attire, florals, venues, and more) '
        'so you can decide a vibe before booking. Link a board to an event and '
        'jump to matching vendors or Ask AI.',
  ),
  HelpArticle(
    id: 'in-2',
    topic: HelpTopic.inspiration,
    question: 'How do I save a look?',
    answer:
        'Open any inspiration look and tap Save. Choose an existing board or '
        'create a new one. Looks saved from a board return there when you go '
        'back.',
  ),
  HelpArticle(
    id: 'ac-0',
    topic: HelpTopic.account,
    question: 'Follow vs friends — what’s the difference?',
    answer:
        'Follow is only for vendors (prestataires) so you can keep their '
        'portfolio close. Friendship is only between planner accounts: send a '
        'request, they accept or decline (like LinkedIn). You can message a '
        'planner only after they accept. Vendor chat stays separate and always '
        'tied to an event connection.',
  ),
  HelpArticle(
    id: 'ac-1',
    topic: HelpTopic.account,
    question: 'How do I edit my profile?',
    answer:
        'Go to Profile → Edit Profile to update your photo, display name, '
        'role, location, bio, email, and phone. Changes show on your public '
        'planner profile.',
  ),
  HelpArticle(
    id: 'ac-2',
    topic: HelpTopic.account,
    question: 'How do I change my password?',
    answer:
        'Open Profile → Privacy & Security → Change password. You’ll need your '
        'current password, then set a new one with at least 6 characters.',
  ),
  HelpArticle(
    id: 'ac-3',
    topic: HelpTopic.account,
    question: 'How do I delete my account?',
    answer:
        'Profile → Privacy & Security → Delete account. This permanently '
        'removes your profile, posts, and event plans. Contact support if you '
        'need help recovering data first.',
  ),
];
