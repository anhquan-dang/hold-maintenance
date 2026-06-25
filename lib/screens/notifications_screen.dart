import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/notification_provider.dart';
import '../presentation/widgets/empty_state.dart';
import '../presentation/widgets/error_state.dart';
import '../presentation/widgets/loading_state.dart';
import '../presentation/widgets/notification_item.dart';
import '../utils/colors.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsyncValue = ref.watch(userNotificationsProvider);
    final unreadCountAsyncValue = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        elevation: 0,
        actions: [
          unreadCountAsyncValue.when(
            data: (unreadCount) {
              if (unreadCount == 0) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(notificationNotifierProvider.notifier)
                          .markAllAsRead();
                    },
                    child: const Text(
                      'Đánh dấu tất cả đã đọc',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsyncValue.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              title: 'Không có thông báo',
              message: 'Bạn không có thông báo nào lúc này',
              icon: Icons.notifications_off,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userNotificationsProvider);
              ref.invalidate(unreadNotificationCountProvider);
              await ref.read(userNotificationsProvider.future);
            },
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationItem(
                  notification: notification,
                  onTap: () {
                    if (!notification.isRead) {
                      ref
                          .read(notificationNotifierProvider.notifier)
                          .markAsRead(notification.id);
                    }
                  },
                  onMarkAsRead: !notification.isRead
                      ? () {
                          ref
                              .read(notificationNotifierProvider.notifier)
                              .markAsRead(notification.id);
                        }
                      : null,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: LoadingState()),
        error: (error, stackTrace) => Center(
          child: ErrorState(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(userNotificationsProvider);
            },
          ),
        ),
      ),
    );
  }
}
