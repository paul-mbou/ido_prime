/// RSVP status for a person who opened / responded to an invite link.
enum InviteeStatus { pending, accepted, rejected }

extension InviteeStatusX on InviteeStatus {
  String get label => switch (this) {
    InviteeStatus.pending => 'Pending',
    InviteeStatus.accepted => 'Accepted',
    InviteeStatus.rejected => 'Rejected',
  };
}

/// Visual style for the shareable invitation card.
enum InvitationCardStyle { classicGold, midnightGarden, softLavender }

extension InvitationCardStyleX on InvitationCardStyle {
  String get label => switch (this) {
    InvitationCardStyle.classicGold => 'Classic gold',
    InvitationCardStyle.midnightGarden => 'Midnight garden',
    InvitationCardStyle.softLavender => 'Soft lavender',
  };

  String get subtitle => switch (this) {
    InvitationCardStyle.classicGold => 'Warm gold frame · formal',
    InvitationCardStyle.midnightGarden => 'Deep purple · botanical',
    InvitationCardStyle.softLavender => 'Light mist · airy',
  };
}

class EventInvitee {
  const EventInvitee({
    required this.id,
    required this.name,
    required this.status,
    this.email = '',
    this.avatarUrl = '',
    this.plusOnes = 0,
    this.note = '',
    this.respondedAt,
  });

  final String id;
  final String name;
  final InviteeStatus status;
  final String email;
  final String avatarUrl;
  final int plusOnes;
  final String note;
  final DateTime? respondedAt;

  EventInvitee copyWith({
    String? name,
    InviteeStatus? status,
    String? email,
    String? avatarUrl,
    int? plusOnes,
    String? note,
    DateTime? respondedAt,
    bool clearRespondedAt = false,
  }) {
    return EventInvitee(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      plusOnes: plusOnes ?? this.plusOnes,
      note: note ?? this.note,
      respondedAt: clearRespondedAt ? null : (respondedAt ?? this.respondedAt),
    );
  }
}

/// Invitation settings + guest responses for one event.
class EventInvitation {
  const EventInvitation({
    this.autoAccept = false,
    this.cardStyle = InvitationCardStyle.classicGold,
    this.headline = '',
    this.message =
        'You are warmly invited. Open the link to RSVP and celebrate with us.',
    this.invitees = const [],
  });

  /// When true, new RSVPs land as [InviteeStatus.accepted] automatically.
  final bool autoAccept;
  final InvitationCardStyle cardStyle;
  final String headline;
  final String message;
  final List<EventInvitee> invitees;

  int get pendingCount =>
      invitees.where((i) => i.status == InviteeStatus.pending).length;

  int get acceptedCount =>
      invitees.where((i) => i.status == InviteeStatus.accepted).length;

  int get rejectedCount =>
      invitees.where((i) => i.status == InviteeStatus.rejected).length;

  int get acceptedHeadcount => invitees
      .where((i) => i.status == InviteeStatus.accepted)
      .fold<int>(0, (sum, i) => sum + 1 + i.plusOnes);

  EventInvitation copyWith({
    bool? autoAccept,
    InvitationCardStyle? cardStyle,
    String? headline,
    String? message,
    List<EventInvitee>? invitees,
  }) {
    return EventInvitation(
      autoAccept: autoAccept ?? this.autoAccept,
      cardStyle: cardStyle ?? this.cardStyle,
      headline: headline ?? this.headline,
      message: message ?? this.message,
      invitees: invitees ?? this.invitees,
    );
  }
}

String eventInviteLink(String eventId) => 'https://ido.app/e/$eventId/invite';
