import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ido_prime/src/features/home/models/app_notification.dart';

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => n.unread).length;
});

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => List<AppNotification>.from(_seed);

  void markAllRead() {
    state = [for (final n in state) n.unread ? n.copyWith(unread: false) : n];
  }

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id && n.unread) n.copyWith(unread: false) else n,
    ];
  }
}

const _seed = <AppNotification>[
  AppNotification(
    id: 'n1',
    title: 'Alex Chen liked your post',
    body: 'Sweet 16 dreams do come true!',
    time: '2m',
    unread: true,
    kind: AppNotificationKind.like,
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
  ),
  AppNotification(
    id: 'n2',
    title: 'New message from Gourmet Catering',
    body: 'We can hold that Saturday date — reply to confirm.',
    time: '18m',
    unread: true,
    kind: AppNotificationKind.message,
    avatarUrl:
        'https://images.unsplash.com/photo-1555244162-803834f70033?w=200&q=80',
  ),
  AppNotification(
    id: 'n3',
    title: 'Budget alert · Summer Wedding',
    body: 'Catering is over allocated by 120 000 XAF.',
    time: '45m',
    unread: true,
    kind: AppNotificationKind.budget,
  ),
  AppNotification(
    id: 'n4',
    title: 'Alex Chen sent a friend request',
    body: 'Birthday Specialist · Accept to unlock chat',
    time: '1h',
    unread: true,
    kind: AppNotificationKind.friendRequest,
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
  ),
  AppNotification(
    id: 'n4b',
    title: 'Someone followed Bloom & Vine Florals',
    body: 'Your vendor page gained a new follower',
    time: '1h',
    unread: true,
    kind: AppNotificationKind.follow,
    avatarUrl:
        'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=200&q=80',
  ),
  AppNotification(
    id: 'n5',
    title: 'Task due · Book venue deposit',
    body: 'Summer Wedding — due tomorrow.',
    time: '2h',
    unread: true,
    kind: AppNotificationKind.tasks,
  ),
  AppNotification(
    id: 'n6',
    title: 'Reminder · Summer Wedding',
    body: 'Vendor walkthrough tomorrow at 10:00.',
    time: '3h',
    unread: false,
    kind: AppNotificationKind.event,
  ),
  AppNotification(
    id: 'n7',
    title: '3 new RSVP replies',
    body: '2 accepted, 1 pending for Summer Wedding.',
    time: '5h',
    unread: false,
    kind: AppNotificationKind.invites,
  ),
  AppNotification(
    id: 'n8',
    title: 'Sarah Johnson commented',
    body: 'This setup is breathtaking.',
    time: 'Yesterday',
    unread: false,
    kind: AppNotificationKind.comment,
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
  ),
];
