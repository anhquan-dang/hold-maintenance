import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../../domain/models/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class ApiNotificationRepository implements NotificationRepository {
  final ApiClient _apiClient;

  ApiNotificationRepository(this._apiClient);

  @override
  Future<List<Notification>> getNotifications(String userId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/notifications/$userId');
      if (response.data == null) return [];
      return response.data!
          .map((json) => Notification.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải thông báo';
      throw Exception(msg);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.dio.put<void>('/notifications/$notificationId/read');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi cập nhật thông báo';
      throw Exception(msg);
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _apiClient.dio.put<void>('/notifications/read-all/$userId');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi cập nhật tất cả thông báo';
      throw Exception(msg);
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _apiClient.dio.get<int>('/notifications/$userId/unread-count');
      return response.data ?? 0;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tải số lượng thông báo chưa đọc';
      throw Exception(msg);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.dio.delete<void>('/notifications/$notificationId');
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi xóa thông báo';
      throw Exception(msg);
    }
  }

  @override
  Future<void> createNotification(Notification notification) async {
    try {
      await _apiClient.dio.post<void>(
        '/notifications',
        data: notification.toJson(),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi tạo thông báo';
      throw Exception(msg);
    }
  }
}
