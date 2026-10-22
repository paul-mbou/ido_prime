import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prestataire lié à un événement (après acceptation de contact).
///
/// [budgetLineIds] vide = contacté seulement ; non vide = working with.
class EventVendorLink {
  const EventVendorLink({
    required this.id,
    required this.eventId,
    required this.vendorId,
    this.budgetLineIds = const [],
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final String vendorId;
  final List<String> budgetLineIds;
  final DateTime createdAt;

  bool get isWorkingWith => budgetLineIds.isNotEmpty;

  EventVendorLink copyWith({List<String>? budgetLineIds, DateTime? createdAt}) {
    return EventVendorLink(
      id: id,
      eventId: eventId,
      vendorId: vendorId,
      budgetLineIds: budgetLineIds ?? this.budgetLineIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'vendorId': vendorId,
    'budgetLineIds': budgetLineIds,
    'createdAt': createdAt.toIso8601String(),
  };

  factory EventVendorLink.fromJson(Map<String, dynamic> json) {
    final rawIds = json['budgetLineIds'];
    return EventVendorLink(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      budgetLineIds: rawIds is List
          ? rawIds.map((e) => e.toString()).toList(growable: false)
          : const [],
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

final eventVendorLinksProvider =
    NotifierProvider<EventVendorLinksNotifier, List<EventVendorLink>>(
      EventVendorLinksNotifier.new,
    );

class EventVendorLinksNotifier extends Notifier<List<EventVendorLink>> {
  static const _prefsKey = 'ido_event_vendor_links_v1';

  @override
  List<EventVendorLink> build() {
    Future.microtask(_hydrate);
    return _seedLinks;
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      await _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      state = [
        for (final item in list)
          EventVendorLink.fromJson(Map<String, dynamic>.from(item as Map)),
      ];
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode([for (final link in state) link.toJson()]),
    );
  }

  List<EventVendorLink> forEvent(String eventId) =>
      state.where((l) => l.eventId == eventId).toList(growable: false);

  EventVendorLink? find({required String eventId, required String vendorId}) {
    for (final link in state) {
      if (link.eventId == eventId && link.vendorId == vendorId) return link;
    }
    return null;
  }

  List<EventVendorLink> forBudgetLine({
    required String eventId,
    required String budgetLineId,
  }) {
    return state
        .where(
          (l) => l.eventId == eventId && l.budgetLineIds.contains(budgetLineId),
        )
        .toList(growable: false);
  }

  /// Creates the link if missing (e.g. after connection accept).
  Future<EventVendorLink> ensureLink({
    required String eventId,
    required String vendorId,
  }) async {
    final existing = find(eventId: eventId, vendorId: vendorId);
    if (existing != null) return existing;

    final link = EventVendorLink(
      id: 'evl_${eventId}_$vendorId',
      eventId: eventId,
      vendorId: vendorId,
      budgetLineIds: const [],
      createdAt: DateTime.now(),
    );
    state = [link, ...state];
    await _persist();
    return link;
  }

  Future<void> setBudgetLineIds({
    required String eventId,
    required String vendorId,
    required List<String> budgetLineIds,
  }) async {
    final unique = budgetLineIds.toSet().toList(growable: false);
    final existing = find(eventId: eventId, vendorId: vendorId);
    if (existing == null) {
      final link = EventVendorLink(
        id: 'evl_${eventId}_$vendorId',
        eventId: eventId,
        vendorId: vendorId,
        budgetLineIds: unique,
        createdAt: DateTime.now(),
      );
      state = [link, ...state];
    } else {
      state = [
        for (final link in state)
          if (link.id == existing.id)
            link.copyWith(budgetLineIds: unique)
          else
            link,
      ];
    }
    await _persist();
  }

  Future<void> addBudgetLine({
    required String eventId,
    required String vendorId,
    required String budgetLineId,
  }) async {
    await ensureLink(eventId: eventId, vendorId: vendorId);
    final current = find(eventId: eventId, vendorId: vendorId)!;
    if (current.budgetLineIds.contains(budgetLineId)) return;
    await setBudgetLineIds(
      eventId: eventId,
      vendorId: vendorId,
      budgetLineIds: [...current.budgetLineIds, budgetLineId],
    );
  }

  Future<void> removeBudgetLine({
    required String eventId,
    required String vendorId,
    required String budgetLineId,
  }) async {
    final current = find(eventId: eventId, vendorId: vendorId);
    if (current == null) return;
    await setBudgetLineIds(
      eventId: eventId,
      vendorId: vendorId,
      budgetLineIds: [
        for (final id in current.budgetLineIds)
          if (id != budgetLineId) id,
      ],
    );
  }

  Future<void> clearBudgetLines({
    required String eventId,
    required String vendorId,
  }) async {
    await setBudgetLineIds(
      eventId: eventId,
      vendorId: vendorId,
      budgetLineIds: const [],
    );
  }

  Future<void> removeLink({
    required String eventId,
    required String vendorId,
  }) async {
    state = [
      for (final link in state)
        if (!(link.eventId == eventId && link.vendorId == vendorId)) link,
    ];
    await _persist();
  }
}

/// Demo links for Summer Wedding (event id `1`).
final _seedLinks = <EventVendorLink>[
  EventVendorLink(
    id: 'evl_1_1',
    eventId: '1',
    vendorId: '1',
    budgetLineIds: const ['b1'],
    createdAt: DateTime(2026, 7, 20),
  ),
  EventVendorLink(
    id: 'evl_1_2',
    eventId: '1',
    vendorId: '2',
    budgetLineIds: const [],
    createdAt: DateTime(2026, 7, 22),
  ),
];
