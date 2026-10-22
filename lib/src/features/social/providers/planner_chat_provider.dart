import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerChatMessage {
  const PlannerChatMessage({
    required this.id,
    required this.body,
    required this.fromMe,
    required this.sentAt,
  });

  final String id;
  final String body;
  final bool fromMe;
  final DateTime sentAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'body': body,
    'fromMe': fromMe,
    'sentAt': sentAt.toIso8601String(),
  };

  factory PlannerChatMessage.fromJson(Map<String, dynamic> json) {
    return PlannerChatMessage(
      id: json['id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      fromMe: json['fromMe'] as bool? ?? true,
      sentAt:
          DateTime.tryParse(json['sentAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Planner ↔ planner chat. UI must gate on accepted friendship.
final plannerChatProvider =
    NotifierProvider.family<
      PlannerChatNotifier,
      List<PlannerChatMessage>,
      String
    >(PlannerChatNotifier.new);

class PlannerChatNotifier extends Notifier<List<PlannerChatMessage>> {
  PlannerChatNotifier(this.plannerId);

  final String plannerId;

  String get _key => 'ido_planner_chat_$plannerId';

  @override
  List<PlannerChatMessage> build() {
    Future.microtask(_hydrate);
    return const [];
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = (jsonDecode(raw) as List<dynamic>)
          .map(
            (e) => PlannerChatMessage.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
      state = list;
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((m) => m.toJson()).toList()),
    );
  }

  Future<void> send(String body) async {
    final text = body.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    state = [
      ...state,
      PlannerChatMessage(
        id: 'm_${now.millisecondsSinceEpoch}',
        body: text,
        fromMe: true,
        sentAt: now,
      ),
    ];
    await _persist();
  }
}
