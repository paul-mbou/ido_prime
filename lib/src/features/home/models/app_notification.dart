enum AppNotificationKind {
  like,
  comment,
  follow,
  friendRequest,
  message,
  event,
  budget,
  tasks,
  invites,
}

/// User-facing category tag shown on notification tiles.
enum AppNotificationCategory {
  events,
  budget,
  tasks,
  invites,
  social,
  messages,
}

extension AppNotificationKindX on AppNotificationKind {
  AppNotificationCategory get category => switch (this) {
    AppNotificationKind.event => AppNotificationCategory.events,
    AppNotificationKind.budget => AppNotificationCategory.budget,
    AppNotificationKind.tasks => AppNotificationCategory.tasks,
    AppNotificationKind.invites => AppNotificationCategory.invites,
    AppNotificationKind.message => AppNotificationCategory.messages,
    AppNotificationKind.like ||
    AppNotificationKind.comment ||
    AppNotificationKind.follow ||
    AppNotificationKind.friendRequest => AppNotificationCategory.social,
  };
}

extension AppNotificationCategoryX on AppNotificationCategory {
  String get label => switch (this) {
    AppNotificationCategory.events => 'Events',
    AppNotificationCategory.budget => 'Budget',
    AppNotificationCategory.tasks => 'Tasks',
    AppNotificationCategory.invites => 'Invites',
    AppNotificationCategory.social => 'Social',
    AppNotificationCategory.messages => 'Messages',
  };
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
    required this.kind,
    this.avatarUrl = '',
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final AppNotificationKind kind;
  final String avatarUrl;

  AppNotificationCategory get category => kind.category;

  String get tagLabel => category.label;

  AppNotification copyWith({bool? unread}) => AppNotification(
    id: id,
    title: title,
    body: body,
    time: time,
    unread: unread ?? this.unread,
    kind: kind,
    avatarUrl: avatarUrl,
  );
}
