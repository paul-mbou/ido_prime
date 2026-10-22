import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorChatMessage {
  const VendorChatMessage({
    required this.id,
    required this.body,
    required this.fromPlanner,
    required this.sentAt,
  });

  final String id;
  final String body;
  final bool fromPlanner;
  final DateTime sentAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'body': body,
    'fromPlanner': fromPlanner,
    'sentAt': sentAt.toIso8601String(),
  };

  factory VendorChatMessage.fromJson(Map<String, dynamic> json) {
    return VendorChatMessage(
      id: json['id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      fromPlanner: json['fromPlanner'] as bool? ?? true,
      sentAt:
          DateTime.tryParse(json['sentAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

final vendorChatProvider =
    NotifierProvider.family<
      VendorChatNotifier,
      List<VendorChatMessage>,
      String
    >(VendorChatNotifier.new);

class VendorChatNotifier extends Notifier<List<VendorChatMessage>> {
  VendorChatNotifier(this.vendorId);

  final String vendorId;

  String get _key => 'ido_vendor_chat_$vendorId';

  @override
  List<VendorChatMessage> build() {
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
            (e) => VendorChatMessage.fromJson(
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

  /// Seed chat with the original connection request after accept.
  Future<void> bootstrapFromRequest(String requestMessage) async {
    if (state.isNotEmpty) return;
    final text = requestMessage.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    state = [
      VendorChatMessage(
        id: 'req_${now.millisecondsSinceEpoch}',
        body: text,
        fromPlanner: true,
        sentAt: now,
      ),
      VendorChatMessage(
        id: 'welcome_${now.millisecondsSinceEpoch}',
        body:
            'Thanks for reaching out — happy to continue here. '
            'What dates are you looking at?',
        fromPlanner: false,
        sentAt: now.add(const Duration(seconds: 1)),
      ),
    ];
    await _persist();
  }

  Future<void> send(String body) async {
    final text = body.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    state = [
      ...state,
      VendorChatMessage(
        id: 'm_${now.millisecondsSinceEpoch}',
        body: text,
        fromPlanner: true,
        sentAt: now,
      ),
    ];
    await _persist();
  }
}
