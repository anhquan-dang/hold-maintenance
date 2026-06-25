enum TicketPriority { low, medium, high, urgent }

extension TicketPriorityExtension on TicketPriority {
  String get priorityLabel {
    switch (this) {
      case TicketPriority.low:
        return 'Thấp';
      case TicketPriority.medium:
        return 'Trung bình';
      case TicketPriority.high:
        return 'Cao';
      case TicketPriority.urgent:
        return 'Khẩn cấp';
    }
  }

  String get priorityColor {
    switch (this) {
      case TicketPriority.low:
        return 'success';
      case TicketPriority.medium:
        return 'info';
      case TicketPriority.high:
        return 'warning';
      case TicketPriority.urgent:
        return 'error';
    }
  }
}

enum TicketStatus { pending, inProgress, completed }

extension TicketStatusExtension on TicketStatus {
  String get statusLabel {
    switch (this) {
      case TicketStatus.pending:
        return 'Chờ xử lý';
      case TicketStatus.inProgress:
        return 'Đang xử lý';
      case TicketStatus.completed:
        return 'Hoàn thành';
    }
  }

  String get statusColor {
    switch (this) {
      case TicketStatus.pending:
        return 'warning';
      case TicketStatus.inProgress:
        return 'info';
      case TicketStatus.completed:
        return 'success';
    }
  }
}

class SupportTicket {
  final String id;
  final String title;
  final String description;
  final TicketPriority priority;
  final TicketStatus status;
  final String requester;
  final String? assignedTo;
  final String assetId;
  final String assetName;
  final DateTime createdAt;
  final DateTime? completedAt;

  const SupportTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.requester,
    this.assignedTo,
    required this.assetId,
    required this.assetName,
    required this.createdAt,
    this.completedAt,
  });

  String get priorityLabel {
    switch (priority) {
      case TicketPriority.low:
        return 'Thấp';
      case TicketPriority.medium:
        return 'Trung bình';
      case TicketPriority.high:
        return 'Cao';
      case TicketPriority.urgent:
        return 'Khẩn cấp';
    }
  }

  String get priorityColor {
    switch (priority) {
      case TicketPriority.low:
        return 'success';
      case TicketPriority.medium:
        return 'info';
      case TicketPriority.high:
        return 'warning';
      case TicketPriority.urgent:
        return 'error';
    }
  }

  String get statusLabel {
    switch (status) {
      case TicketStatus.pending:
        return 'Chờ xử lý';
      case TicketStatus.inProgress:
        return 'Đang xử lý';
      case TicketStatus.completed:
        return 'Hoàn thành';
    }
  }

  String get statusColor {
    switch (status) {
      case TicketStatus.pending:
        return 'warning';
      case TicketStatus.inProgress:
        return 'info';
      case TicketStatus.completed:
        return 'success';
    }
  }

  SupportTicket copyWith({
    String? id,
    String? title,
    String? description,
    TicketPriority? priority,
    TicketStatus? status,
    String? requester,
    String? assignedTo,
    String? assetId,
    String? assetName,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      requester: requester ?? this.requester,
      assignedTo: assignedTo ?? this.assignedTo,
      assetId: assetId ?? this.assetId,
      assetName: assetName ?? this.assetName,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: _parsePriority(json['priority']),
      status: _parseStatus(json['status']),
      requester: json['requester'] as String? ?? '',
      assignedTo: json['assignedTo'] as String?,
      assetId: json['assetId'] as String? ?? '',
      assetName: json['assetName'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.index,
      'status': status.index,
      'requester': requester,
      'assignedTo': assignedTo,
      'assetId': assetId,
      'assetName': assetName,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  static TicketPriority _parsePriority(dynamic p) {
    if (p is int) {
      return TicketPriority.values[p];
    }
    final pStr = (p as String? ?? '').toLowerCase();
    if (pStr == 'low') return TicketPriority.low;
    if (pStr == 'high') return TicketPriority.high;
    if (pStr == 'urgent') return TicketPriority.urgent;
    return TicketPriority.medium;
  }

  static TicketStatus _parseStatus(dynamic s) {
    if (s is int) {
      return TicketStatus.values[s];
    }
    final sStr = (s as String? ?? '').toLowerCase();
    if (sStr == 'inprogress') return TicketStatus.inProgress;
    if (sStr == 'completed') return TicketStatus.completed;
    return TicketStatus.pending;
  }
}
