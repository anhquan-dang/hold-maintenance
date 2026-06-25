import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../data/repositories/api_notification_repository.dart';
import '../../domain/models/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'user_provider.dart';

// Repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiNotificationRepository(apiClient);
});

// User notifications provider
final userNotificationsProvider = FutureProvider<List<Notification>>((
  ref,
) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  if (currentUser == null) return [];

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications(currentUser.id);
});

// Unread count provider
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  if (currentUser == null) return 0;

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount(currentUser.id);
});

// Notification notifier
final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, bool>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationNotifier(repository, ref);
    });

class NotificationNotifier extends StateNotifier<bool> {
  final NotificationRepository _repository;
  final Ref _ref;

  NotificationNotifier(this._repository, this._ref) : super(false);

  Future<void> markAsRead(String notificationId) async {
    state = true;
    try {
      await _repository.markAsRead(notificationId);
      _ref.invalidate(userNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
    } finally {
      state = false;
    }
  }

  Future<void> markAllAsRead() async {
    state = true;
    try {
      final currentUser = await _ref.read(currentUserProvider.future);
      if (currentUser != null) {
        await _repository.markAllAsRead(currentUser.id);
        _ref.invalidate(userNotificationsProvider);
        _ref.invalidate(unreadNotificationCountProvider);
      }
    } finally {
      state = false;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    state = true;
    try {
      await _repository.deleteNotification(notificationId);
      _ref.invalidate(userNotificationsProvider);
    } finally {
      state = false;
    }
  }

  Future<void> createNotification(Notification notification) async {
    state = true;
    try {
      await _repository.createNotification(notification);
      _ref.invalidate(userNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
    } finally {
      state = false;
    }
  }
}
