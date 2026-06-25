import '../models/notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<int> getUnreadCount(String userId);
  Future<void> deleteNotification(String notificationId);
  Future<void> createNotification(Notification notification);
}
