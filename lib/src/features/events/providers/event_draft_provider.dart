import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/events/models/event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventCreateDraft {
  const EventCreateDraft({
    this.step = 0,
    this.type = EventType.wedding,
    this.title = '',
    this.place = '',
    this.description = '',
    this.dateIso,
    this.guests = 80,
    this.budget = 2_000_000,
    this.visibility = EventVisibility.private,
    this.coverPath = '',
    this.entryType = EventEntryType.free,
    this.ticketTitle = '',
    this.ticketDescription = '',
    this.ticketPrice = 0,
    this.ticketQuantity = 0,
  });

  final int step;
  final EventType type;
  final String title;
  final String place;
  final String description;
  final String? dateIso;
  final int guests;
  final double budget;
  final EventVisibility visibility;

  /// Local file path for optional cover (empty = use type default).
  final String coverPath;
  final EventEntryType entryType;
  final String ticketTitle;
  final String ticketDescription;
  final double ticketPrice;
  final int ticketQuantity;

  DateTime? get date =>
      dateIso == null ? null : DateTime.tryParse(dateIso!);

  bool get hasProgress =>
      step > 0 ||
      title.trim().isNotEmpty ||
      place.trim().isNotEmpty ||
      description.trim().isNotEmpty ||
      dateIso != null ||
      visibility != EventVisibility.private ||
      type != EventType.wedding ||
      coverPath.trim().isNotEmpty ||
      entryType != EventEntryType.free ||
      ticketTitle.trim().isNotEmpty ||
      ticketPrice > 0;

  EventCreateDraft copyWith({
    int? step,
    EventType? type,
    String? title,
    String? place,
    String? description,
    String? dateIso,
    bool clearDate = false,
    int? guests,
    double? budget,
    EventVisibility? visibility,
    String? coverPath,
    bool clearCover = false,
    EventEntryType? entryType,
    String? ticketTitle,
    String? ticketDescription,
    double? ticketPrice,
    int? ticketQuantity,
  }) {
    return EventCreateDraft(
      step: step ?? this.step,
      type: type ?? this.type,
      title: title ?? this.title,
      place: place ?? this.place,
      description: description ?? this.description,
      dateIso: clearDate ? null : (dateIso ?? this.dateIso),
      guests: guests ?? this.guests,
      budget: budget ?? this.budget,
      visibility: visibility ?? this.visibility,
      coverPath: clearCover ? '' : (coverPath ?? this.coverPath),
      entryType: entryType ?? this.entryType,
      ticketTitle: ticketTitle ?? this.ticketTitle,
      ticketDescription: ticketDescription ?? this.ticketDescription,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      ticketQuantity: ticketQuantity ?? this.ticketQuantity,
    );
  }

  Map<String, dynamic> toJson() => {
    'step': step,
    'type': type.name,
    'title': title,
    'place': place,
    'description': description,
    'dateIso': dateIso,
    'guests': guests,
    'budget': budget,
    'visibility': visibility.name,
    'coverPath': coverPath,
    'entryType': entryType.name,
    'ticketTitle': ticketTitle,
    'ticketDescription': ticketDescription,
    'ticketPrice': ticketPrice,
    'ticketQuantity': ticketQuantity,
  };

  factory EventCreateDraft.fromJson(Map<String, dynamic> json) {
    return EventCreateDraft(
      step: json['step'] as int? ?? 0,
      type: EventType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => EventType.wedding,
      ),
      title: json['title'] as String? ?? '',
      place: json['place'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dateIso: json['dateIso'] as String?,
      guests: json['guests'] as int? ?? 80,
      budget: (json['budget'] as num?)?.toDouble() ?? 2_000_000,
      visibility: EventVisibility.values.firstWhere(
        (v) => v.name == json['visibility'],
        orElse: () => EventVisibility.private,
      ),
      coverPath: json['coverPath'] as String? ?? '',
      entryType: EventEntryType.values.firstWhere(
        (e) => e.name == json['entryType'],
        orElse: () => EventEntryType.free,
      ),
      ticketTitle: json['ticketTitle'] as String? ?? '',
      ticketDescription: json['ticketDescription'] as String? ?? '',
      ticketPrice: (json['ticketPrice'] as num?)?.toDouble() ?? 0,
      ticketQuantity: json['ticketQuantity'] as int? ?? 0,
    );
  }
}

final eventCreateDraftProvider =
    NotifierProvider<EventCreateDraftNotifier, EventCreateDraft?>(
      EventCreateDraftNotifier.new,
    );

class EventCreateDraftNotifier extends Notifier<EventCreateDraft?> {
  static const _key = 'ido_event_create_draft_v2';

  @override
  EventCreateDraft? build() {
    Future.microtask(load);
    return null;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      state = null;
      return;
    }
    try {
      state = EventCreateDraft.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      state = null;
    }
  }

  Future<void> save(EventCreateDraft draft) async {
    state = draft;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(draft.toJson()));
  }

  Future<void> clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
