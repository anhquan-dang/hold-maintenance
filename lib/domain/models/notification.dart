enum NotificationType { newRequest, completed, reminder, assigned }

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case NotificationType.newRequest:
        return 'Yêu cầu mới';
      case NotificationType.completed:
        return 'Hoàn thành';
      case NotificationType.reminder:
        return 'Nhắc nhở';
      case NotificationType.assigned:
        return 'Được giao công việc';
    }
  }

  String get typeIcon {
    switch (type) {
      case NotificationType.newRequest:
        return '📋';
      case NotificationType.completed:
        return '✅';
      case NotificationType.reminder:
        return '🔔';
      case NotificationType.assigned:
        return '👤';
    }
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values[json['type'] as int],
      relatedId: json['relatedId'] as String?,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.index,
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    String? relatedId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
