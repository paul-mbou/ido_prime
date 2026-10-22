import 'package:ido_prime/src/features/events/models/event_invitation.dart';
import 'package:intl/intl.dart';

enum EventStatus { planning, upcoming, past }

enum EventType { wedding, birthday, corporate, brunch, engagement, other }

/// Who can see this event.
enum EventVisibility {
  /// Only the organizer.
  private,

  /// Visible to friends / relations (and in their feeds).
  friends,

  /// Visible to everyone (and in the public feed).
  public,
}

extension EventVisibilityX on EventVisibility {
  String get label => switch (this) {
    EventVisibility.private => 'Private',
    EventVisibility.friends => 'Friends',
    EventVisibility.public => 'Public',
  };

  String get subtitle => switch (this) {
    EventVisibility.private => 'Only you can see this event',
    EventVisibility.friends => 'Visible to your friends & relations',
    EventVisibility.public => 'Anyone on IDO can discover it',
  };
}

/// Whether guests pay for entry (tickets) or attend free via invites.
enum EventEntryType {
  /// Guests RSVP free — no ticket purchase.
  free,

  /// Guests buy tickets on a dedicated ticket page.
  paid,
}

extension EventEntryTypeX on EventEntryType {
  String get label => switch (this) {
    EventEntryType.free => 'Free',
    EventEntryType.paid => 'Paid',
  };

  String get subtitle => switch (this) {
    EventEntryType.free =>
      'Guests RSVP via invites — no ticket purchase required',
    EventEntryType.paid =>
      'Set up a ticket page so guests can buy entry to your event',
  };
}

/// Public ticket page for a paid event (guest purchase, not organizer budget).
class EventTicketPage {
  const EventTicketPage({
    this.title = '',
    this.description = '',
    this.price = 0,
    this.quantity = 0,
    this.isPublished = false,
  });

  final String title;
  final String description;
  final double price;
  final int quantity;
  final bool isPublished;

  bool get isConfigured => price > 0 && title.trim().isNotEmpty;

  EventTicketPage copyWith({
    String? title,
    String? description,
    double? price,
    int? quantity,
    bool? isPublished,
  }) {
    return EventTicketPage(
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

extension EventTypeX on EventType {
  String get label => switch (this) {
    EventType.wedding => 'Wedding',
    EventType.birthday => 'Birthday',
    EventType.corporate => 'Corporate',
    EventType.brunch => 'Brunch',
    EventType.engagement => 'Engagement',
    EventType.other => 'Other',
  };

  String get defaultCoverUrl => switch (this) {
    EventType.wedding =>
      'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
    EventType.birthday =>
      'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80',
    EventType.corporate =>
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80',
    EventType.brunch =>
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&q=80',
    EventType.engagement =>
      'https://images.unsplash.com/photo-1522673607200-164a2e1b4950?w=800&q=80',
    EventType.other =>
      'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800&q=80',
  };
}

class BudgetLine {
  const BudgetLine({
    required this.id,
    required this.label,
    required this.amount,
  });

  final String id;
  final String label;
  final double amount;

  BudgetLine copyWith({String? label, double? amount}) {
    return BudgetLine(
      id: id,
      label: label ?? this.label,
      amount: amount ?? this.amount,
    );
  }
}

class EventTask {
  const EventTask({required this.id, required this.title, this.isDone = false});

  final String id;
  final String title;
  final bool isDone;

  EventTask copyWith({String? title, bool? isDone}) {
    return EventTask(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}

enum BudgetHealth { healthy, overAllocated, belowRecommended, underAllocated }

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.place,
    required this.coverUrl,
    required this.status,
    required this.type,
    this.eventDate,
    this.visibility = EventVisibility.private,
    this.guestCount = 0,
    this.vendorCount = 0,
    this.description = '',
    this.theme = '',
    this.isMine = true,
    this.hostName = '',
    this.hostAvatarUrl = '',
    this.totalBudget = 0,
    this.currency = 'XAF',
    this.budgetLines = const [],
    this.tasks = const [],
    this.invitation = const EventInvitation(),
    this.entryType = EventEntryType.free,
    this.ticketPage = const EventTicketPage(),
  });

  final String id;
  final String title;
  final String dateLabel;
  final DateTime? eventDate;
  final String place;
  final String coverUrl;
  final EventStatus status;
  final EventType type;
  final EventVisibility visibility;
  final int guestCount;
  final int vendorCount;
  final String description;
  final String theme;
  final bool isMine;
  final String hostName;
  final String hostAvatarUrl;
  final double totalBudget;
  final String currency;
  final List<BudgetLine> budgetLines;
  final List<EventTask> tasks;
  final EventInvitation invitation;
  final EventEntryType entryType;
  final EventTicketPage ticketPage;

  bool get isPaidEntry => entryType == EventEntryType.paid;

  /// Status shown in UI: always [EventStatus.past] once [eventDate] is before today.
  EventStatus get effectiveStatus {
    final d = eventDate;
    if (d != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final day = DateTime(d.year, d.month, d.day);
      if (day.isBefore(today)) return EventStatus.past;
    }
    return status;
  }

  String get statusLabel => switch (effectiveStatus) {
    EventStatus.planning => 'Planning',
    EventStatus.upcoming => 'Upcoming',
    EventStatus.past => 'Past',
  };

  double get allocatedBudget =>
      budgetLines.fold<double>(0, (sum, line) => sum + line.amount);

  double get remainingBudget => totalBudget - allocatedBudget;

  int get doneTaskCount => tasks.where((t) => t.isDone).length;

  bool get appearsInFeed =>
      visibility == EventVisibility.public ||
      visibility == EventVisibility.friends;

  double get recommendedBudget {
    final perGuest = switch (type) {
      EventType.wedding => 45000.0,
      EventType.birthday => 18000.0,
      EventType.corporate => 35000.0,
      EventType.brunch => 12000.0,
      EventType.engagement => 22000.0,
      EventType.other => 15000.0,
    };
    final guests = guestCount <= 0 ? 50 : guestCount;
    return perGuest * guests;
  }

  BudgetHealth get budgetHealth {
    if (allocatedBudget > totalBudget + 0.5) return BudgetHealth.overAllocated;
    if (totalBudget + 0.5 < recommendedBudget) {
      return BudgetHealth.belowRecommended;
    }
    if (remainingBudget > totalBudget * 0.05 && remainingBudget > 1000) {
      return BudgetHealth.underAllocated;
    }
    return BudgetHealth.healthy;
  }

  double percentOfTotal(BudgetLine line) {
    if (totalBudget <= 0) return 0;
    return (line.amount / totalBudget) * 100;
  }

  bool isOnDay(DateTime day) {
    final d = eventDate;
    if (d == null) return false;
    return d.year == day.year && d.month == day.month && d.day == day.day;
  }

  Event copyWith({
    String? title,
    String? dateLabel,
    DateTime? eventDate,
    bool clearEventDate = false,
    String? place,
    String? coverUrl,
    EventStatus? status,
    EventType? type,
    EventVisibility? visibility,
    int? guestCount,
    int? vendorCount,
    String? description,
    String? theme,
    bool? isMine,
    String? hostName,
    String? hostAvatarUrl,
    double? totalBudget,
    String? currency,
    List<BudgetLine>? budgetLines,
    List<EventTask>? tasks,
    EventInvitation? invitation,
    EventEntryType? entryType,
    EventTicketPage? ticketPage,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      dateLabel: dateLabel ?? this.dateLabel,
      eventDate: clearEventDate ? null : (eventDate ?? this.eventDate),
      place: place ?? this.place,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      type: type ?? this.type,
      visibility: visibility ?? this.visibility,
      guestCount: guestCount ?? this.guestCount,
      vendorCount: vendorCount ?? this.vendorCount,
      description: description ?? this.description,
      theme: theme ?? this.theme,
      isMine: isMine ?? this.isMine,
      hostName: hostName ?? this.hostName,
      hostAvatarUrl: hostAvatarUrl ?? this.hostAvatarUrl,
      totalBudget: totalBudget ?? this.totalBudget,
      currency: currency ?? this.currency,
      budgetLines: budgetLines ?? this.budgetLines,
      tasks: tasks ?? this.tasks,
      invitation: invitation ?? this.invitation,
      entryType: entryType ?? this.entryType,
      ticketPage: ticketPage ?? this.ticketPage,
    );
  }
}

final _moneyFormat = NumberFormat.decimalPattern('fr');

/// Formats amounts with grouped digits via [intl] (e.g. `8 100 000 XAF`).
String formatEventMoney(double amount, {String currency = 'XAF'}) {
  final formatted = _moneyFormat.format(amount.round());
  return currency.isEmpty ? formatted : '$formatted $currency';
}

String formatEventDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

String formatEventWeekday(DateTime date) => DateFormat('EEE').format(date);

String formatEventDayNumber(DateTime date) => DateFormat('d').format(date);

bool isSameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
