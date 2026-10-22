/// LinkedIn-style friendship between planner accounts (not vendors).
enum FriendshipStatus {
  /// No request yet.
  none,

  /// Current user sent a request; waiting on the other planner.
  pendingOutgoing,

  /// Other planner sent a request; current user can accept / decline.
  pendingIncoming,

  /// Mutual friends — planner chat unlocked.
  accepted,

  /// Request was declined (can send again after reset).
  declined,
}

class PlannerFriendship {
  const PlannerFriendship({
    required this.plannerId,
    required this.status,
    required this.updatedAt,
    this.message = '',
  });

  final String plannerId;
  final FriendshipStatus status;
  final DateTime updatedAt;
  final String message;

  bool get canChat => status == FriendshipStatus.accepted;

  bool get isPending =>
      status == FriendshipStatus.pendingOutgoing ||
      status == FriendshipStatus.pendingIncoming;

  PlannerFriendship copyWith({
    FriendshipStatus? status,
    DateTime? updatedAt,
    String? message,
  }) {
    return PlannerFriendship(
      plannerId: plannerId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() => {
    'plannerId': plannerId,
    'status': status.name,
    'updatedAt': updatedAt.toIso8601String(),
    'message': message,
  };

  factory PlannerFriendship.fromJson(Map<String, dynamic> json) {
    return PlannerFriendship(
      plannerId: json['plannerId'] as String? ?? '',
      status: FriendshipStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => FriendshipStatus.none,
      ),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      message: json['message'] as String? ?? '',
    );
  }
}
