import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:ido_prime/src/features/events/models/event_invitation.dart';
import 'package:ido_prime/src/features/events/models/event_templates.dart';

final eventsProvider = NotifierProvider<EventsNotifier, List<Event>>(
  EventsNotifier.new,
);

class EventsNotifier extends Notifier<List<Event>> {
  @override
  List<Event> build() => List<Event>.from(_seedEvents);

  Event? byId(String id) {
    for (final event in state) {
      if (event.id == id) return event;
    }
    return null;
  }

  Event createEvent({
    required String title,
    required EventType type,
    required String dateLabel,
    required String place,
    required int guestCount,
    required double totalBudget,
    DateTime? eventDate,
    EventVisibility visibility = EventVisibility.private,
    EventEntryType entryType = EventEntryType.free,
    EventTicketPage ticketPage = const EventTicketPage(),
    String description = '',
    String theme = '',
    String? coverUrl,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final resolvedCover = (coverUrl ?? '').trim().isEmpty
        ? type.defaultCoverUrl
        : coverUrl!.trim();
    final event = Event(
      id: id,
      title: title.trim(),
      dateLabel: dateLabel.trim(),
      eventDate: eventDate,
      place: place.trim(),
      coverUrl: resolvedCover,
      status: EventStatus.planning,
      type: type,
      visibility: visibility,
      entryType: entryType,
      ticketPage: entryType == EventEntryType.paid
          ? ticketPage
          : const EventTicketPage(),
      guestCount: guestCount,
      description: description.trim(),
      theme: theme.trim(),
      hostName: 'You',
      totalBudget: totalBudget,
      budgetLines: EventTemplates.budgetLinesFor(
        type: type,
        totalBudget: totalBudget,
      ),
      tasks: EventTemplates.tasksFor(type),
    );
    state = [event, ...state];
    return event;
  }

  void updateTicketPage(String eventId, EventTicketPage ticketPage) {
    _update(eventId, (event) {
      if (event.entryType != EventEntryType.paid) return event;
      return event.copyWith(ticketPage: ticketPage);
    });
  }

  void updateEntryType(String eventId, EventEntryType entryType) {
    _update(eventId, (event) {
      if (entryType == EventEntryType.free) {
        return event.copyWith(
          entryType: entryType,
          ticketPage: const EventTicketPage(),
        );
      }
      return event.copyWith(entryType: entryType);
    });
  }

  void updateVisibility(String eventId, EventVisibility visibility) {
    _update(eventId, (event) => event.copyWith(visibility: visibility));
  }

  void updateGuestCount(String eventId, int guestCount) {
    _update(eventId, (event) {
      final safe = guestCount < 0 ? 0 : guestCount;
      return event.copyWith(guestCount: safe);
    });
  }

  void updateDescription(String eventId, String description) {
    _update(
      eventId,
      (event) => event.copyWith(description: description.trim()),
    );
  }

  void updateTotalBudget(String eventId, double totalBudget) {
    _update(eventId, (event) {
      final safe = totalBudget < 0 ? 0.0 : totalBudget;
      // Scale existing lines proportionally when total changes.
      final oldTotal = event.totalBudget <= 0 ? 1.0 : event.totalBudget;
      final scaled = [
        for (final line in event.budgetLines)
          line.copyWith(
            amount: ((line.amount / oldTotal) * safe).roundToDouble(),
          ),
      ];
      return event.copyWith(totalBudget: safe, budgetLines: scaled);
    });
  }

  void updateBudgetLineAmount(String eventId, String lineId, double amount) {
    _update(eventId, (event) {
      final safe = amount < 0 ? 0.0 : amount;
      return event.copyWith(
        budgetLines: [
          for (final line in event.budgetLines)
            if (line.id == lineId) line.copyWith(amount: safe) else line,
        ],
      );
    });
  }

  void renameBudgetLine(String eventId, String lineId, String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    _update(eventId, (event) {
      return event.copyWith(
        budgetLines: [
          for (final line in event.budgetLines)
            if (line.id == lineId) line.copyWith(label: trimmed) else line,
        ],
      );
    });
  }

  void addBudgetLine(
    String eventId, {
    String label = 'New category',
    double amount = 0,
  }) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    _update(eventId, (event) {
      final id = 'b${DateTime.now().microsecondsSinceEpoch}';
      final safe = amount < 0 ? 0.0 : amount;
      return event.copyWith(
        budgetLines: [
          ...event.budgetLines,
          BudgetLine(id: id, label: trimmed, amount: safe),
        ],
      );
    });
  }

  void updateBudgetLine(
    String eventId,
    String lineId, {
    String? label,
    double? amount,
  }) {
    _update(eventId, (event) {
      return event.copyWith(
        budgetLines: [
          for (final line in event.budgetLines)
            if (line.id == lineId)
              line.copyWith(
                label: (label ?? line.label).trim().isEmpty
                    ? line.label
                    : (label ?? line.label).trim(),
                amount: amount == null
                    ? line.amount
                    : (amount < 0 ? 0.0 : amount),
              )
            else
              line,
        ],
      );
    });
  }

  void removeBudgetLine(String eventId, String lineId) {
    _update(eventId, (event) {
      return event.copyWith(
        budgetLines: [
          for (final line in event.budgetLines)
            if (line.id != lineId) line,
        ],
      );
    });
  }

  /// Mock AI: redistributes the total across categories for this event type.
  void applyAiBudgetProposal(String eventId) {
    _update(eventId, (event) {
      return event.copyWith(
        budgetLines: EventTemplates.aiProposedBudgetLines(
          type: event.type,
          totalBudget: event.totalBudget,
          current: event.budgetLines,
        ),
      );
    });
  }

  void resetBudgetToDefaults(String eventId) {
    _update(eventId, (event) {
      return event.copyWith(
        budgetLines: EventTemplates.budgetLinesFor(
          type: event.type,
          totalBudget: event.totalBudget,
        ),
      );
    });
  }

  void toggleTask(String eventId, String taskId) {
    _update(eventId, (event) {
      return event.copyWith(
        tasks: [
          for (final task in event.tasks)
            if (task.id == taskId)
              task.copyWith(isDone: !task.isDone)
            else
              task,
        ],
      );
    });
  }

  void updateTaskTitle(String eventId, String taskId, String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    _update(eventId, (event) {
      return event.copyWith(
        tasks: [
          for (final task in event.tasks)
            if (task.id == taskId) task.copyWith(title: trimmed) else task,
        ],
      );
    });
  }

  void deleteTask(String eventId, String taskId) {
    _update(eventId, (event) {
      return event.copyWith(
        tasks: [
          for (final task in event.tasks)
            if (task.id != taskId) task,
        ],
      );
    });
  }

  void addTask(String eventId, String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    _update(eventId, (event) {
      final id = 't${DateTime.now().microsecondsSinceEpoch}';
      return event.copyWith(
        tasks: [
          ...event.tasks,
          EventTask(id: id, title: trimmed),
        ],
      );
    });
  }

  void setInvitationAutoAccept(String eventId, bool autoAccept) {
    _update(
      eventId,
      (event) => event.copyWith(
        invitation: event.invitation.copyWith(autoAccept: autoAccept),
      ),
    );
  }

  void setInvitationCardStyle(String eventId, InvitationCardStyle style) {
    _update(
      eventId,
      (event) => event.copyWith(
        invitation: event.invitation.copyWith(cardStyle: style),
      ),
    );
  }

  void updateInvitationCopy(
    String eventId, {
    required String headline,
    required String message,
  }) {
    _update(
      eventId,
      (event) => event.copyWith(
        invitation: event.invitation.copyWith(
          headline: headline,
          message: message.isEmpty ? event.invitation.message : message,
        ),
      ),
    );
  }

  void setInviteeStatus(
    String eventId,
    String inviteeId,
    InviteeStatus status,
  ) {
    _update(eventId, (event) {
      return event.copyWith(
        invitation: event.invitation.copyWith(
          invitees: [
            for (final invitee in event.invitation.invitees)
              if (invitee.id == inviteeId)
                invitee.copyWith(status: status, respondedAt: DateTime.now())
              else
                invitee,
          ],
        ),
      );
    });
  }

  /// Simulates a guest opening the invite link and RSVPing.
  void rsvpViaInviteLink({
    required String eventId,
    required String name,
    String email = '',
    int plusOnes = 0,
    String note = '',
    InviteeStatus? forcedStatus,
  }) {
    _update(eventId, (event) {
      final status =
          forcedStatus ??
          (event.invitation.autoAccept
              ? InviteeStatus.accepted
              : InviteeStatus.pending);
      final invitee = EventInvitee(
        id: 'i${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        email: email.trim(),
        plusOnes: plusOnes < 0 ? 0 : plusOnes,
        note: note.trim(),
        status: status,
        respondedAt: DateTime.now(),
      );
      return event.copyWith(
        invitation: event.invitation.copyWith(
          invitees: [invitee, ...event.invitation.invitees],
        ),
      );
    });
  }

  void _update(String eventId, Event Function(Event) transform) {
    state = [
      for (final event in state)
        if (event.id == eventId) transform(event) else event,
    ];
  }
}

Event? findEventById(String id) {
  for (final event in _seedEvents) {
    if (event.id == id) return event;
  }
  return null;
}

/// Seed data used by feed / search and as the provider's initial state.
List<EventTask> _seedTasks(EventType type, {int doneCount = 0}) {
  final tasks = EventTemplates.tasksFor(type);
  return [
    for (var i = 0; i < tasks.length; i++)
      tasks[i].copyWith(isDone: i < doneCount),
  ];
}

EventInvitation _seedWeddingInvitation() => EventInvitation(
  autoAccept: false,
  cardStyle: InvitationCardStyle.classicGold,
  headline: 'Amina & Jean',
  message:
      'With joy we invite you to celebrate our wedding. '
      'Open the link to RSVP — we can’t wait to share this day with you.',
  invitees: [
    EventInvitee(
      id: 'inv1',
      name: 'Marie Nguemo',
      email: 'marie@email.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
      status: InviteeStatus.accepted,
      plusOnes: 1,
      note: 'Needs vegetarian plate',
      respondedAt: DateTime(2026, 7, 20),
    ),
    EventInvitee(
      id: 'inv2',
      name: 'Paul Fotso',
      email: 'paul.fotso@email.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
      status: InviteeStatus.pending,
      plusOnes: 0,
    ),
    EventInvitee(
      id: 'inv3',
      name: 'Léa Mbarga',
      email: 'lea.m@email.com',
      status: InviteeStatus.pending,
      plusOnes: 2,
      note: 'Traveling from Yaoundé',
    ),
    EventInvitee(
      id: 'inv4',
      name: 'Eric Owona',
      email: 'eric.o@email.com',
      status: InviteeStatus.rejected,
      note: 'Out of town',
      respondedAt: DateTime(2026, 7, 18),
    ),
    EventInvitee(
      id: 'inv5',
      name: 'Sophie Kamga',
      email: 'sophie.k@email.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
      status: InviteeStatus.accepted,
      plusOnes: 0,
      respondedAt: DateTime(2026, 7, 22),
    ),
  ],
);

EventInvitation _seedBrunchInvitation() => EventInvitation(
  autoAccept: true,
  cardStyle: InvitationCardStyle.classicGold,
  message: 'Join us for a sunlit brunch by the coast. Link to RSVP inside.',
  invitees: [
    EventInvitee(
      id: 'b1',
      name: 'Nadia Tchou',
      email: 'nadia@email.com',
      status: InviteeStatus.accepted,
      plusOnes: 1,
    ),
    EventInvitee(id: 'b2', name: 'Chris Manga', status: InviteeStatus.accepted),
  ],
);

final _seedEvents = <Event>[
  Event(
    id: '1',
    title: 'Summer Wedding',
    dateLabel: 'Aug 12, 2026',
    eventDate: DateTime(2026, 8, 12),
    place: 'Douala · The Grand Manor',
    coverUrl: EventType.wedding.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.wedding,
    visibility: EventVisibility.friends,
    guestCount: 180,
    vendorCount: 8,
    description:
        'An intimate garden ceremony followed by a golden-hour reception. '
        'Soft peach florals, live jazz cocktail hour, and a dance floor under string lights.',
    theme: 'Garden romance',
    hostName: 'You',
    totalBudget: 8_100_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.wedding,
      totalBudget: 8_100_000,
    ),
    tasks: _seedTasks(EventType.wedding, doneCount: 2),
    invitation: _seedWeddingInvitation(),
  ),
  Event(
    id: '2',
    title: 'Corporate Gala',
    dateLabel: 'Sep 3, 2026',
    eventDate: DateTime(2026, 9, 3),
    place: 'Yaoundé · Harbor View Hall',
    coverUrl: EventType.corporate.defaultCoverUrl,
    status: EventStatus.planning,
    type: EventType.corporate,
    visibility: EventVisibility.private,
    guestCount: 320,
    vendorCount: 5,
    description:
        'Annual partner appreciation night — seated dinner, awards, and a late lounge set.',
    theme: 'Midnight gold',
    hostName: 'You',
    totalBudget: 11_200_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.corporate,
      totalBudget: 11_200_000,
    ),
    tasks: _seedTasks(EventType.corporate),
    invitation: const EventInvitation(
      message:
          'You’re invited to our partner appreciation gala. Kindly RSVP via the link.',
    ),
  ),
  Event(
    id: '3',
    title: 'Garden Brunch',
    dateLabel: 'Jul 31, 2026',
    eventDate: DateTime(2026, 7, 31),
    place: 'Limbe · Coastal Terrace',
    coverUrl: EventType.brunch.defaultCoverUrl,
    status: EventStatus.planning,
    type: EventType.brunch,
    visibility: EventVisibility.public,
    guestCount: 48,
    vendorCount: 3,
    description:
        'Sunday brunch for close friends — seasonal plates, soft florals, and acoustic playlist.',
    theme: 'Coastal light',
    hostName: 'You',
    totalBudget: 576_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.brunch,
      totalBudget: 576_000,
    ),
    tasks: _seedTasks(EventType.brunch),
    invitation: _seedBrunchInvitation(),
  ),
  Event(
    id: '4',
    title: 'Maya’s Birthday Soirée',
    dateLabel: 'Jul 4, 2026',
    eventDate: DateTime(2026, 7, 4),
    place: 'Douala · Private villa',
    coverUrl: EventType.birthday.defaultCoverUrl,
    status: EventStatus.past,
    type: EventType.birthday,
    visibility: EventVisibility.friends,
    guestCount: 65,
    vendorCount: 4,
    description: 'A warm evening of music, cake, and lantern-lit tables.',
    theme: 'Candle glow',
    hostName: 'You',
    totalBudget: 1_170_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.birthday,
      totalBudget: 1_170_000,
    ),
    tasks: _seedTasks(EventType.birthday, doneCount: 99),
  ),
  Event(
    id: '5',
    title: 'Engagement Picnic',
    dateLabel: 'Aug 1, 2026',
    eventDate: DateTime(2026, 8, 1),
    place: 'Kribi · Beach gardens',
    coverUrl: EventType.engagement.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.engagement,
    visibility: EventVisibility.public,
    guestCount: 90,
    vendorCount: 0,
    description:
        'Community celebration open to IDO planners looking for coastal inspiration.',
    theme: 'Barefoot chic',
    isMine: false,
    hostName: 'Sarah Johnson',
    hostAvatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    totalBudget: 1_980_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.engagement,
      totalBudget: 1_980_000,
    ),
    tasks: _seedTasks(EventType.engagement),
  ),
  Event(
    id: '6',
    title: 'Friends Rooftop Night',
    dateLabel: 'Aug 2, 2026',
    eventDate: DateTime(2026, 8, 2),
    place: 'Douala · Akwa rooftop',
    coverUrl: EventType.other.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.other,
    visibility: EventVisibility.friends,
    guestCount: 40,
    vendorCount: 2,
    description: 'Sunset drinks with the planners circle — DJ set at 8.',
    theme: 'City lights',
    isMine: false,
    hostName: 'Alex Chen',
    hostAvatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
    totalBudget: 650_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.other,
      totalBudget: 650_000,
    ),
    tasks: _seedTasks(EventType.other),
  ),

  // ── Extra mine (private / friends / public) ─────────────────────────────
  Event(
    id: '7',
    title: 'Rehearsal Dinner',
    dateLabel: formatEventDate(DateTime(2026, 7, 31)),
    eventDate: DateTime(2026, 7, 31),
    place: 'Douala · Bonanjo bistro',
    coverUrl: EventType.wedding.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.wedding,
    visibility: EventVisibility.private,
    guestCount: 28,
    vendorCount: 2,
    description: 'Intimate rehearsal dinner the night of the garden brunch.',
    theme: 'Candle tables',
    hostName: 'You',
    totalBudget: 420_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.wedding,
      totalBudget: 420_000,
    ),
    tasks: _seedTasks(EventType.wedding, doneCount: 4),
  ),
  Event(
    id: '8',
    title: 'Anniversary Dinner',
    dateLabel: formatEventDate(DateTime(2026, 8, 3)),
    eventDate: DateTime(2026, 8, 3),
    place: 'Douala · Bonapriso',
    coverUrl: EventType.other.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.other,
    visibility: EventVisibility.friends,
    guestCount: 12,
    vendorCount: 1,
    description: 'Ten years — tasting menu and a private terrace toast.',
    theme: 'Quiet gold',
    hostName: 'You',
    totalBudget: 380_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.other,
      totalBudget: 380_000,
    ),
    tasks: _seedTasks(EventType.other, doneCount: 1),
  ),
  Event(
    id: '9',
    title: 'Baby Shower Brunch',
    dateLabel: formatEventDate(DateTime(2026, 8, 5)),
    eventDate: DateTime(2026, 8, 5),
    place: 'Yaoundé · Bastos garden',
    coverUrl: EventType.brunch.defaultCoverUrl,
    status: EventStatus.planning,
    type: EventType.brunch,
    visibility: EventVisibility.private,
    guestCount: 35,
    vendorCount: 3,
    description: 'Soft florals, fruit towers, and a keepsake guestbook.',
    theme: 'Soft sage',
    hostName: 'You',
    totalBudget: 510_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.brunch,
      totalBudget: 510_000,
    ),
    tasks: _seedTasks(EventType.brunch),
  ),
  Event(
    id: '10',
    title: 'Launch Night Mixer',
    dateLabel: formatEventDate(DateTime(2026, 8, 8)),
    eventDate: DateTime(2026, 8, 8),
    place: 'Douala · Waterfront loft',
    coverUrl: EventType.corporate.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.corporate,
    visibility: EventVisibility.public,
    guestCount: 110,
    vendorCount: 4,
    description: 'Open mixer for creators and vendors — RSVP on IDO.',
    theme: 'Neon dusk',
    hostName: 'You',
    totalBudget: 2_400_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.corporate,
      totalBudget: 2_400_000,
    ),
    tasks: _seedTasks(EventType.corporate, doneCount: 3),
  ),
  Event(
    id: '11',
    title: 'Family Sunday Lunch',
    dateLabel: formatEventDate(DateTime(2026, 8, 10)),
    eventDate: DateTime(2026, 8, 10),
    place: 'Limbe · Hillside terrace',
    coverUrl: EventType.brunch.defaultCoverUrl,
    status: EventStatus.planning,
    type: EventType.brunch,
    visibility: EventVisibility.private,
    guestCount: 22,
    vendorCount: 1,
    description: 'Extended family lunch with grilled catch and soft jazz.',
    theme: 'Sea breeze',
    hostName: 'You',
    totalBudget: 290_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.brunch,
      totalBudget: 290_000,
    ),
    tasks: _seedTasks(EventType.brunch, doneCount: 2),
  ),
  Event(
    id: '12',
    title: 'Twilight Engagement Toast',
    dateLabel: formatEventDate(DateTime(2026, 8, 14)),
    eventDate: DateTime(2026, 8, 14),
    place: 'Kribi · Cliff pavilion',
    coverUrl: EventType.engagement.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.engagement,
    visibility: EventVisibility.friends,
    guestCount: 55,
    vendorCount: 3,
    description: 'Friends-only toast at golden hour before the picnic weekend.',
    theme: 'Salt & silk',
    hostName: 'You',
    totalBudget: 980_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.engagement,
      totalBudget: 980_000,
    ),
    tasks: _seedTasks(EventType.engagement, doneCount: 1),
  ),
  Event(
    id: '13',
    title: 'Nora’s 30th',
    dateLabel: formatEventDate(DateTime(2026, 8, 16)),
    eventDate: DateTime(2026, 8, 16),
    place: 'Douala · Private courtyard',
    coverUrl: EventType.birthday.defaultCoverUrl,
    status: EventStatus.planning,
    type: EventType.birthday,
    visibility: EventVisibility.friends,
    guestCount: 70,
    vendorCount: 5,
    description: 'Dinner, dancing, and a late cake reveal under lanterns.',
    theme: 'Indigo night',
    hostName: 'You',
    totalBudget: 1_450_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.birthday,
      totalBudget: 1_450_000,
    ),
    tasks: _seedTasks(EventType.birthday),
  ),

  // ── Around me / public discoveries (not mine) ───────────────────────────
  Event(
    id: '14',
    title: 'Open Jazz Night',
    dateLabel: formatEventDate(DateTime(2026, 8, 3)),
    eventDate: DateTime(2026, 8, 3),
    place: 'Douala · Akwa jazz club',
    coverUrl: EventType.other.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.other,
    visibility: EventVisibility.public,
    guestCount: 85,
    vendorCount: 2,
    description: 'Public live set — planners welcome. Free entry before 8.',
    theme: 'Smoke & brass',
    isMine: false,
    hostName: 'Mira Okala',
    hostAvatarUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
    totalBudget: 720_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.other,
      totalBudget: 720_000,
    ),
    tasks: _seedTasks(EventType.other),
  ),
  Event(
    id: '15',
    title: 'Vendor Pop-up Market',
    dateLabel: formatEventDate(DateTime(2026, 8, 4)),
    eventDate: DateTime(2026, 8, 4),
    place: 'Yaoundé · Mvog-Betsi commons',
    coverUrl: EventType.corporate.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.corporate,
    visibility: EventVisibility.public,
    guestCount: 200,
    vendorCount: 18,
    description: 'Florists, caterers, DJs — meet vendors for your next event.',
    theme: 'Market day',
    isMine: false,
    hostName: 'IDO Collective',
    hostAvatarUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80',
    totalBudget: 3_100_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.corporate,
      totalBudget: 3_100_000,
    ),
    tasks: _seedTasks(EventType.corporate),
  ),
  Event(
    id: '16',
    title: 'Friends Garden Party',
    dateLabel: formatEventDate(DateTime(2026, 8, 6)),
    eventDate: DateTime(2026, 8, 6),
    place: 'Douala · Bonamoussadi',
    coverUrl: EventType.birthday.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.birthday,
    visibility: EventVisibility.friends,
    guestCount: 50,
    vendorCount: 2,
    description: 'Casual garden hang — bring a dish, stay for the playlist.',
    theme: 'Lemon leaf',
    isMine: false,
    hostName: 'Grace Ndi',
    hostAvatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&q=80',
    totalBudget: 410_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.birthday,
      totalBudget: 410_000,
    ),
    tasks: _seedTasks(EventType.birthday),
  ),
  Event(
    id: '17',
    title: 'Coastal Wedding Showcase',
    dateLabel: formatEventDate(DateTime(2026, 8, 7)),
    eventDate: DateTime(2026, 8, 7),
    place: 'Limbe · Botanical lawn',
    coverUrl: EventType.wedding.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.wedding,
    visibility: EventVisibility.public,
    guestCount: 140,
    vendorCount: 9,
    description:
        'Styled shoot open to the public — décor ideas and vendor booths.',
    theme: 'Botanical white',
    isMine: false,
    hostName: 'Bloom Studio',
    hostAvatarUrl:
        'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=200&q=80',
    totalBudget: 4_200_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.wedding,
      totalBudget: 4_200_000,
    ),
    tasks: _seedTasks(EventType.wedding),
  ),
  Event(
    id: '18',
    title: 'Buea Hills Picnic',
    dateLabel: formatEventDate(DateTime(2026, 8, 9)),
    eventDate: DateTime(2026, 8, 9),
    place: 'Buea · Mountain meadow',
    coverUrl: EventType.brunch.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.brunch,
    visibility: EventVisibility.public,
    guestCount: 60,
    vendorCount: 1,
    description: 'Public picnic with mountain views — not in Douala metro.',
    theme: 'Mist green',
    isMine: false,
    hostName: 'Outdoor Club',
    hostAvatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
    totalBudget: 280_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.brunch,
      totalBudget: 280_000,
    ),
    tasks: _seedTasks(EventType.brunch),
  ),
  Event(
    id: '19',
    title: 'Art & Champagne Gala',
    dateLabel: formatEventDate(DateTime(2026, 8, 11)),
    eventDate: DateTime(2026, 8, 11),
    place: 'Yaoundé · National gallery annex',
    coverUrl: EventType.corporate.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.corporate,
    visibility: EventVisibility.public,
    guestCount: 160,
    vendorCount: 6,
    description: 'Public cultural night — art, champagne, late string quartet.',
    theme: 'Gallery black',
    isMine: false,
    hostName: 'Culture Desk',
    hostAvatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
    totalBudget: 5_600_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.corporate,
      totalBudget: 5_600_000,
    ),
    tasks: _seedTasks(EventType.corporate),
  ),
  Event(
    id: '20',
    title: 'Kribi Full Moon Dinner',
    dateLabel: formatEventDate(DateTime(2026, 8, 15)),
    eventDate: DateTime(2026, 8, 15),
    place: 'Kribi · Beach tables',
    coverUrl: EventType.engagement.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.engagement,
    visibility: EventVisibility.public,
    guestCount: 75,
    vendorCount: 4,
    description: 'Public seaside dinner under the full moon — book a seat.',
    theme: 'Moon silver',
    isMine: false,
    hostName: 'Salt & Cedar',
    hostAvatarUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
    totalBudget: 1_800_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.engagement,
      totalBudget: 1_800_000,
    ),
    tasks: _seedTasks(EventType.engagement),
  ),
  Event(
    id: '21',
    title: 'Planners Circle Meetup',
    dateLabel: formatEventDate(DateTime(2026, 8, 17)),
    eventDate: DateTime(2026, 8, 17),
    place: 'Douala · Co-working loft',
    coverUrl: EventType.corporate.defaultCoverUrl,
    status: EventStatus.upcoming,
    type: EventType.corporate,
    visibility: EventVisibility.friends,
    guestCount: 32,
    vendorCount: 0,
    description: 'Invite-only circle — share budgets, vendors, and AI tips.',
    theme: 'Studio clean',
    isMine: false,
    hostName: 'Alex Chen',
    hostAvatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
    totalBudget: 180_000,
    budgetLines: EventTemplates.budgetLinesFor(
      type: EventType.corporate,
      totalBudget: 180_000,
    ),
    tasks: _seedTasks(EventType.corporate),
  ),
];

/// Feed / search still read the immutable seed (discoverable events).
List<Event> get mockEvents => List.unmodifiable(_seedEvents);
