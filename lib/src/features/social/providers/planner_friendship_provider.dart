import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/social/models/planner_friendship.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Friendship graph for planner ↔ planner only (LinkedIn-style accept/decline).
final plannerFriendshipProvider =
    NotifierProvider.family<
      PlannerFriendshipNotifier,
      PlannerFriendship,
      String
    >(PlannerFriendshipNotifier.new);

/// Convenience: accepted friend ids for the signed-in planner.
final acceptedFriendIdsProvider = Provider<Set<String>>((ref) {
  // Family providers are per-id; we keep a mirror set on the notifier via
  // SharedPreferences aggregate. Prefer reading the aggregate provider below.
  return ref.watch(friendshipGraphProvider).acceptedIds;
});

final friendshipGraphProvider =
    NotifierProvider<FriendshipGraphNotifier, FriendshipGraph>(
      FriendshipGraphNotifier.new,
    );

class FriendshipGraph {
  const FriendshipGraph({this.byPlannerId = const {}});

  final Map<String, PlannerFriendship> byPlannerId;

  Set<String> get acceptedIds => {
    for (final e in byPlannerId.entries)
      if (e.value.status == FriendshipStatus.accepted) e.key,
  };

  int get friendsCount => acceptedIds.length;

  PlannerFriendship forPlanner(String plannerId) {
    return byPlannerId[plannerId] ??
        PlannerFriendship(
          plannerId: plannerId,
          status: FriendshipStatus.none,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        );
  }

  FriendshipGraph copyWithEntry(PlannerFriendship friendship) {
    return FriendshipGraph(
      byPlannerId: {...byPlannerId, friendship.plannerId: friendship},
    );
  }
}

class FriendshipGraphNotifier extends Notifier<FriendshipGraph> {
  static const _key = 'ido_planner_friendships_v1';

  @override
  FriendshipGraph build() {
    Future.microtask(_hydrate);
    return const FriendshipGraph();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      // Seed one incoming request so Accept / Decline is demoable.
      state = FriendshipGraph(
        byPlannerId: {
          'alex': PlannerFriendship(
            plannerId: 'alex',
            status: FriendshipStatus.pendingIncoming,
            updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
            message: 'Loved your garden brunch inspo — let’s connect!',
          ),
        },
      );
      await _persist();
      return;
    }
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final byId = <String, PlannerFriendship>{};
      for (final entry in map.entries) {
        byId[entry.key] = PlannerFriendship.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
      state = FriendshipGraph(byPlannerId: byId);
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = <String, dynamic>{
      for (final e in state.byPlannerId.entries) e.key: e.value.toJson(),
    };
    await prefs.setString(_key, jsonEncode(encoded));
  }

  Future<void> sendRequest(String plannerId, {String message = ''}) async {
    final id = plannerId.trim();
    if (id.isEmpty) return;
    final current = state.forPlanner(id);
    if (current.status == FriendshipStatus.accepted ||
        current.status == FriendshipStatus.pendingOutgoing ||
        current.status == FriendshipStatus.pendingIncoming) {
      return;
    }
    final next = PlannerFriendship(
      plannerId: id,
      status: FriendshipStatus.pendingOutgoing,
      updatedAt: DateTime.now(),
      message: message.trim(),
    );
    state = state.copyWithEntry(next);
    await _persist();
  }

  Future<void> accept(String plannerId) async {
    final current = state.forPlanner(plannerId);
    if (current.status != FriendshipStatus.pendingIncoming) return;
    state = state.copyWithEntry(
      current.copyWith(
        status: FriendshipStatus.accepted,
        updatedAt: DateTime.now(),
      ),
    );
    await _persist();
  }

  Future<void> decline(String plannerId) async {
    final current = state.forPlanner(plannerId);
    if (current.status != FriendshipStatus.pendingIncoming) return;
    state = state.copyWithEntry(
      current.copyWith(
        status: FriendshipStatus.declined,
        updatedAt: DateTime.now(),
      ),
    );
    await _persist();
  }

  Future<void> unfriend(String plannerId) async {
    final current = state.forPlanner(plannerId);
    if (current.status != FriendshipStatus.accepted) return;
    state = state.copyWithEntry(
      PlannerFriendship(
        plannerId: plannerId,
        status: FriendshipStatus.none,
        updatedAt: DateTime.now(),
      ),
    );
    await _persist();
  }

  Future<void> cancelOutgoing(String plannerId) async {
    final current = state.forPlanner(plannerId);
    if (current.status != FriendshipStatus.pendingOutgoing) return;
    state = state.copyWithEntry(
      PlannerFriendship(
        plannerId: plannerId,
        status: FriendshipStatus.none,
        updatedAt: DateTime.now(),
      ),
    );
    await _persist();
  }

  Future<void> resetDeclined(String plannerId) async {
    final current = state.forPlanner(plannerId);
    if (current.status != FriendshipStatus.declined) return;
    state = state.copyWithEntry(
      PlannerFriendship(
        plannerId: plannerId,
        status: FriendshipStatus.none,
        updatedAt: DateTime.now(),
      ),
    );
    await _persist();
  }
}

/// Per-planner view that stays in sync with [friendshipGraphProvider].
class PlannerFriendshipNotifier extends Notifier<PlannerFriendship> {
  PlannerFriendshipNotifier(this.plannerId);

  final String plannerId;

  @override
  PlannerFriendship build() {
    return ref.watch(friendshipGraphProvider).forPlanner(plannerId);
  }

  Future<void> sendRequest({String message = ''}) => ref
      .read(friendshipGraphProvider.notifier)
      .sendRequest(plannerId, message: message);

  Future<void> accept() =>
      ref.read(friendshipGraphProvider.notifier).accept(plannerId);

  Future<void> decline() =>
      ref.read(friendshipGraphProvider.notifier).decline(plannerId);

  Future<void> unfriend() =>
      ref.read(friendshipGraphProvider.notifier).unfriend(plannerId);

  Future<void> cancelOutgoing() =>
      ref.read(friendshipGraphProvider.notifier).cancelOutgoing(plannerId);

  Future<void> resetDeclined() =>
      ref.read(friendshipGraphProvider.notifier).resetDeclined(plannerId);
}
