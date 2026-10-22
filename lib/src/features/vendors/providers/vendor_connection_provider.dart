import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/events/providers/event_vendor_links_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VendorConnectionStatus { none, pending, accepted, declined }

class VendorConnectionRequest {
  const VendorConnectionRequest({
    required this.vendorId,
    required this.eventName,
    required this.message,
    this.eventId,
    this.prompt,
    this.status = VendorConnectionStatus.pending,
    required this.sentAt,
    this.respondedAt,
  });

  final String vendorId;
  final String eventName;
  final String? eventId;
  final String message;
  final String? prompt;
  final VendorConnectionStatus status;
  final DateTime sentAt;
  final DateTime? respondedAt;

  VendorConnectionRequest copyWith({
    String? eventName,
    String? eventId,
    String? message,
    String? prompt,
    VendorConnectionStatus? status,
    DateTime? sentAt,
    DateTime? respondedAt,
  }) {
    return VendorConnectionRequest(
      vendorId: vendorId,
      eventName: eventName ?? this.eventName,
      eventId: eventId ?? this.eventId,
      message: message ?? this.message,
      prompt: prompt ?? this.prompt,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'vendorId': vendorId,
    'eventName': eventName,
    'eventId': eventId,
    'message': message,
    'prompt': prompt,
    'status': status.name,
    'sentAt': sentAt.toIso8601String(),
    'respondedAt': respondedAt?.toIso8601String(),
  };

  factory VendorConnectionRequest.fromJson(Map<String, dynamic> json) {
    return VendorConnectionRequest(
      vendorId: json['vendorId'] as String? ?? '',
      eventName: json['eventName'] as String? ?? '',
      eventId: json['eventId'] as String?,
      message: json['message'] as String? ?? '',
      prompt: json['prompt'] as String?,
      status: VendorConnectionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => VendorConnectionStatus.pending,
      ),
      sentAt:
          DateTime.tryParse(json['sentAt'] as String? ?? '') ?? DateTime.now(),
      respondedAt: DateTime.tryParse(json['respondedAt'] as String? ?? ''),
    );
  }
}

final vendorConnectionProvider =
    NotifierProvider.family<
      VendorConnectionNotifier,
      VendorConnectionRequest?,
      String
    >(VendorConnectionNotifier.new);

class VendorConnectionNotifier extends Notifier<VendorConnectionRequest?> {
  VendorConnectionNotifier(this.vendorId);

  final String vendorId;

  String get _key => 'ido_vendor_connection_$vendorId';

  @override
  VendorConnectionRequest? build() {
    Future.microtask(_hydrate);
    return null;
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      state = VendorConnectionRequest.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final value = state;
    if (value == null) {
      await prefs.remove(_key);
      return;
    }
    await prefs.setString(_key, jsonEncode(value.toJson()));
  }

  Future<void> sendRequest({
    required String eventName,
    required String message,
    String? eventId,
    String? prompt,
  }) async {
    state = VendorConnectionRequest(
      vendorId: vendorId,
      eventName: eventName,
      eventId: eventId,
      message: message.trim(),
      prompt: prompt,
      status: VendorConnectionStatus.pending,
      sentAt: DateTime.now(),
    );
    await _persist();
  }

  Future<void> accept() async {
    final current = state;
    if (current == null || current.status != VendorConnectionStatus.pending) {
      return;
    }
    state = current.copyWith(
      status: VendorConnectionStatus.accepted,
      respondedAt: DateTime.now(),
    );
    await _persist();

    final eventId = state?.eventId?.trim();
    if (eventId != null && eventId.isNotEmpty) {
      await ref
          .read(eventVendorLinksProvider.notifier)
          .ensureLink(eventId: eventId, vendorId: vendorId);
    }
  }

  Future<void> decline() async {
    final current = state;
    if (current == null || current.status != VendorConnectionStatus.pending) {
      return;
    }
    state = current.copyWith(
      status: VendorConnectionStatus.declined,
      respondedAt: DateTime.now(),
    );
    await _persist();
  }

  Future<void> reset() async {
    state = null;
    await _persist();
  }
}
