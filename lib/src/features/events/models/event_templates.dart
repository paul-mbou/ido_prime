import 'package:ido_prime/src/features/events/models/event.dart';

class _BudgetPct {
  const _BudgetPct(this.label, this.percent);
  final String label;
  final double percent;
}

/// Selectable budget category with a short purpose description.
class BudgetCategoryOption {
  const BudgetCategoryOption({
    required this.label,
    required this.description,
  });

  final String label;
  final String description;
}

/// Default budget % + checklist seeds keyed by [EventType].
abstract final class EventTemplates {
  /// Full catalog for “Add category” picker (name + purpose).
  static const List<BudgetCategoryOption> budgetCategoryCatalog = [
    BudgetCategoryOption(
      label: 'Venue',
      description: 'Location hire, deposit, and room fees',
    ),
    BudgetCategoryOption(
      label: 'Catering',
      description: 'Food, drinks, service staff, and tasting',
    ),
    BudgetCategoryOption(
      label: 'Photography',
      description: 'Photo and video coverage of the day',
    ),
    BudgetCategoryOption(
      label: 'Florals & décor',
      description: 'Flowers, centerpieces, and styling props',
    ),
    BudgetCategoryOption(
      label: 'Florals',
      description: 'Bouquets, arrangements, and greenery',
    ),
    BudgetCategoryOption(
      label: 'Decor',
      description: 'Lighting, linens, signage, and setup props',
    ),
    BudgetCategoryOption(
      label: 'Decor & branding',
      description: 'Brand visuals, stage look, and printed assets',
    ),
    BudgetCategoryOption(
      label: 'Music',
      description: 'DJ, live band, or playlist & sound',
    ),
    BudgetCategoryOption(
      label: 'Entertainment',
      description: 'Performers, activities, and guest experiences',
    ),
    BudgetCategoryOption(
      label: 'AV & tech',
      description: 'Screens, mics, streaming, and tech crew',
    ),
    BudgetCategoryOption(
      label: 'Attire',
      description: 'Outfits, fittings, and accessories',
    ),
    BudgetCategoryOption(
      label: 'Cake',
      description: 'Celebration cake and dessert table',
    ),
    BudgetCategoryOption(
      label: 'Transportation',
      description: 'Guest shuttles, cars, and parking',
    ),
    BudgetCategoryOption(
      label: 'Invitations & stationery',
      description: 'Save-the-dates, invites, and menus',
    ),
    BudgetCategoryOption(
      label: 'Gifts & favors',
      description: 'Guest gifts, welcome bags, and thank-yous',
    ),
    BudgetCategoryOption(
      label: 'Misc / contingency',
      description: 'Buffer for surprises and last-minute costs',
    ),
  ];

  static List<BudgetCategoryOption> availableCategoriesFor(
    List<BudgetLine> current,
  ) {
    final used = {
      for (final line in current) line.label.trim().toLowerCase(),
    };
    return [
      for (final option in budgetCategoryCatalog)
        if (!used.contains(option.label.trim().toLowerCase())) option,
    ];
  }

  static List<BudgetLine> budgetLinesFor({
    required EventType type,
    required double totalBudget,
    String idPrefix = 'b',
  }) {
    final template = _budgetPercents(type);
    return [
      for (var i = 0; i < template.length; i++)
        BudgetLine(
          id: '$idPrefix$i',
          label: template[i].label,
          amount: (totalBudget * template[i].percent / 100).roundToDouble(),
        ),
    ];
  }

  /// Alternate “AI” split — same categories, redistributed weights.
  static List<BudgetLine> aiProposedBudgetLines({
    required EventType type,
    required double totalBudget,
    required List<BudgetLine> current,
  }) {
    final alt = _aiBudgetPercents(type);
    final byLabel = {for (final p in alt) p.label: p.percent};

    if (current.isEmpty) {
      return budgetLinesFor(
        type: type,
        totalBudget: totalBudget,
        idPrefix: 'ai',
      );
    }

    // Keep user labels when possible; fall back to AI template.
    final labels = current.map((l) => l.label).toList();
    final known = labels.where(byLabel.containsKey).toList();
    if (known.length != labels.length) {
      return [
        for (var i = 0; i < alt.length; i++)
          BudgetLine(
            id: current.length > i ? current[i].id : 'ai$i',
            label: alt[i].label,
            amount: (totalBudget * alt[i].percent / 100).roundToDouble(),
          ),
      ];
    }

    // Normalize known percents across current labels.
    final raw = [for (final l in labels) byLabel[l] ?? (100 / labels.length)];
    final sum = raw.fold<double>(0, (a, b) => a + b);
    return [
      for (var i = 0; i < labels.length; i++)
        BudgetLine(
          id: current[i].id,
          label: labels[i],
          amount: (totalBudget * (raw[i] / sum)).roundToDouble(),
        ),
    ];
  }

  static List<EventTask> tasksFor(EventType type, {String idPrefix = 't'}) {
    final titles = _taskTitles(type);
    return [
      for (var i = 0; i < titles.length; i++)
        EventTask(id: '$idPrefix$i', title: titles[i]),
    ];
  }

  static List<String> aiTipsFor(Event event) {
    final tips = <String>[
      'For a ${event.type.label.toLowerCase()}, keep a 5–8% contingency inside Misc.',
      'Lock venue and catering first — they usually drive 50%+ of the spend.',
    ];

    switch (event.budgetHealth) {
      case BudgetHealth.overAllocated:
        tips.insert(
          0,
          'Your line items exceed the total budget by '
          '${formatEventMoney(event.allocatedBudget - event.totalBudget)}. '
          'Raise the total or trim the largest categories.',
        );
      case BudgetHealth.belowRecommended:
        tips.insert(
          0,
          'For ~${event.guestCount} guests, IDO suggests around '
          '${formatEventMoney(event.recommendedBudget)}. '
          'Consider increasing the total budget.',
        );
      case BudgetHealth.underAllocated:
        tips.insert(
          0,
          'You still have ${formatEventMoney(event.remainingBudget)} unassigned. '
          'Spread it across high-impact categories or keep it as contingency.',
        );
      case BudgetHealth.healthy:
        tips.insert(
          0,
          'Your budget looks balanced for this ${event.type.label.toLowerCase()}. '
          'Next: confirm vendor quotes against each line.',
        );
    }

    if (event.doneTaskCount < event.tasks.length) {
      tips.add(
        '${event.tasks.length - event.doneTaskCount} tasks left — '
        'prioritize venue deposit and guest list next.',
      );
    }

    return tips;
  }

  static List<_BudgetPct> _budgetPercents(EventType type) => switch (type) {
    EventType.wedding => const [
      _BudgetPct('Venue', 30),
      _BudgetPct('Catering', 25),
      _BudgetPct('Photography', 10),
      _BudgetPct('Florals & décor', 8),
      _BudgetPct('Music', 7),
      _BudgetPct('Attire', 10),
      _BudgetPct('Misc / contingency', 10),
    ],
    EventType.birthday => const [
      _BudgetPct('Venue', 25),
      _BudgetPct('Catering', 30),
      _BudgetPct('Decor', 15),
      _BudgetPct('Entertainment', 15),
      _BudgetPct('Cake', 10),
      _BudgetPct('Misc / contingency', 5),
    ],
    EventType.corporate => const [
      _BudgetPct('Venue', 35),
      _BudgetPct('Catering', 30),
      _BudgetPct('AV & tech', 15),
      _BudgetPct('Entertainment', 10),
      _BudgetPct('Decor & branding', 5),
      _BudgetPct('Misc / contingency', 5),
    ],
    EventType.brunch => const [
      _BudgetPct('Venue', 20),
      _BudgetPct('Catering', 45),
      _BudgetPct('Florals', 15),
      _BudgetPct('Music', 10),
      _BudgetPct('Misc / contingency', 10),
    ],
    EventType.engagement => const [
      _BudgetPct('Venue', 25),
      _BudgetPct('Catering', 30),
      _BudgetPct('Photography', 15),
      _BudgetPct('Florals', 15),
      _BudgetPct('Misc / contingency', 15),
    ],
    EventType.other => const [
      _BudgetPct('Venue', 30),
      _BudgetPct('Catering', 30),
      _BudgetPct('Entertainment', 15),
      _BudgetPct('Decor', 15),
      _BudgetPct('Misc / contingency', 10),
    ],
  };

  static List<_BudgetPct> _aiBudgetPercents(EventType type) => switch (type) {
    EventType.wedding => const [
      _BudgetPct('Venue', 28),
      _BudgetPct('Catering', 28),
      _BudgetPct('Photography', 12),
      _BudgetPct('Florals & décor', 10),
      _BudgetPct('Music', 6),
      _BudgetPct('Attire', 8),
      _BudgetPct('Misc / contingency', 8),
    ],
    EventType.birthday => const [
      _BudgetPct('Venue', 20),
      _BudgetPct('Catering', 28),
      _BudgetPct('Decor', 18),
      _BudgetPct('Entertainment', 18),
      _BudgetPct('Cake', 8),
      _BudgetPct('Misc / contingency', 8),
    ],
    EventType.corporate => const [
      _BudgetPct('Venue', 32),
      _BudgetPct('Catering', 28),
      _BudgetPct('AV & tech', 18),
      _BudgetPct('Entertainment', 12),
      _BudgetPct('Decor & branding', 5),
      _BudgetPct('Misc / contingency', 5),
    ],
    EventType.brunch => const [
      _BudgetPct('Venue', 18),
      _BudgetPct('Catering', 48),
      _BudgetPct('Florals', 12),
      _BudgetPct('Music', 12),
      _BudgetPct('Misc / contingency', 10),
    ],
    EventType.engagement => const [
      _BudgetPct('Venue', 22),
      _BudgetPct('Catering', 28),
      _BudgetPct('Photography', 18),
      _BudgetPct('Florals', 18),
      _BudgetPct('Misc / contingency', 14),
    ],
    EventType.other => const [
      _BudgetPct('Venue', 28),
      _BudgetPct('Catering', 28),
      _BudgetPct('Entertainment', 18),
      _BudgetPct('Decor', 16),
      _BudgetPct('Misc / contingency', 10),
    ],
  };

  static List<String> _taskTitles(EventType type) => switch (type) {
    EventType.wedding => const [
      'Set guest list & save-the-dates',
      'Book venue & pay deposit',
      'Taste & book catering',
      'Hire photographer / videographer',
      'Choose florist & décor plan',
      'Book DJ or live band',
      'Order attire & fittings',
      'Finalize seating chart',
    ],
    EventType.birthday => const [
      'Confirm guest count',
      'Book venue or home setup',
      'Order cake',
      'Plan menu / catering',
      'Arrange décor & lights',
      'Book entertainment or playlist',
      'Send invitations',
    ],
    EventType.corporate => const [
      'Define agenda & speakers',
      'Book venue & AV package',
      'Confirm catering headcount',
      'Prepare branding & signage',
      'Invite guests / RSVP tracking',
      'Run tech rehearsal',
    ],
    EventType.brunch => const [
      'Pick date & guest list',
      'Reserve terrace / venue',
      'Finalize seasonal menu',
      'Order florals',
      'Arrange acoustic playlist',
      'Confirm rentals (tables, linens)',
    ],
    EventType.engagement => const [
      'Choose location & time',
      'Send invitations',
      'Book photographer',
      'Plan catering / picnic spread',
      'Order florals & setup',
      'Prepare speech / playlist',
    ],
    EventType.other => const [
      'Define event goals',
      'Set budget & guest list',
      'Book venue',
      'Arrange catering',
      'Confirm entertainment',
      'Send invitations',
    ],
  };
}
