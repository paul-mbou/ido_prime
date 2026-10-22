import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Follow applies only to **vendors** (prestataires). Planners use friendship.
final vendorFollowProvider =
    NotifierProvider<VendorFollowNotifier, Set<String>>(
      VendorFollowNotifier.new,
    );

class VendorFollowNotifier extends Notifier<Set<String>> {
  static const _key = 'ido_vendor_follows_v1';

  @override
  Set<String> build() {
    Future.microtask(_hydrate);
    return {};
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = (jsonDecode(raw) as List<dynamic>).cast<String>();
      state = list.toSet();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toList()));
  }

  bool isFollowing(String vendorId) => state.contains(vendorId);

  Future<void> toggle(String vendorId) async {
    final id = vendorId.trim();
    if (id.isEmpty) return;
    final next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    await _persist();
  }

  Future<void> follow(String vendorId) async {
    final id = vendorId.trim();
    if (id.isEmpty || state.contains(id)) return;
    state = {...state, id};
    await _persist();
  }

  Future<void> unfollow(String vendorId) async {
    if (!state.contains(vendorId)) return;
    state = {...state}..remove(vendorId);
    await _persist();
  }
}
