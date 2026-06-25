enum AssetStatus { inUse, inMaintenance, available, retired }

extension AssetStatusExtension on AssetStatus {
  String get statusLabel {
    switch (this) {
      case AssetStatus.inUse:
        return 'Đang sử dụng';
      case AssetStatus.inMaintenance:
        return 'Đang bảo trì';
      case AssetStatus.available:
        return 'Sẵn sàng cấp phát';
      case AssetStatus.retired:
        return 'Ngừng sử dụng';
    }
  }

  String get statusColor {
    switch (this) {
      case AssetStatus.inUse:
        return 'success';
      case AssetStatus.inMaintenance:
        return 'warning';
      case AssetStatus.available:
        return 'info';
      case AssetStatus.retired:
        return 'secondary';
    }
  }
}

class Asset {
  final String id;
  final String assetCode;
  final String assetName;
  final String assetType;
  final String department;
  final String assignedUser;
  final DateTime purchaseDate;
  final DateTime warrantyExpiry;
  final AssetStatus status;
  final String note;

  const Asset({
    required this.id,
    required this.assetCode,
    required this.assetName,
    required this.assetType,
    required this.department,
    required this.assignedUser,
    required this.purchaseDate,
    required this.warrantyExpiry,
    required this.status,
    required this.note,
  });

  String get statusLabel {
    switch (status) {
      case AssetStatus.inUse:
        return 'Đang sử dụng';
      case AssetStatus.inMaintenance:
        return 'Đang bảo trì';
      case AssetStatus.available:
        return 'Sẵn sàng cấp phát';
      case AssetStatus.retired:
        return 'Ngừng sử dụng';
    }
  }

  String get statusColor {
    switch (status) {
      case AssetStatus.inUse:
        return 'success';
      case AssetStatus.inMaintenance:
        return 'warning';
      case AssetStatus.available:
        return 'info';
      case AssetStatus.retired:
        return 'secondary';
    }
  }

  Asset copyWith({
    String? id,
    String? assetCode,
    String? assetName,
    String? assetType,
    String? department,
    String? assignedUser,
    DateTime? purchaseDate,
    DateTime? warrantyExpiry,
    AssetStatus? status,
    String? note,
  }) {
    return Asset(
      id: id ?? this.id,
      assetCode: assetCode ?? this.assetCode,
      assetName: assetName ?? this.assetName,
      assetType: assetType ?? this.assetType,
      department: department ?? this.department,
      assignedUser: assignedUser ?? this.assignedUser,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String? ?? '',
      assetCode: json['assetCode'] as String? ?? '',
      assetName: json['assetName'] as String? ?? '',
      assetType: json['assetType'] as String? ?? '',
      department: json['department'] as String? ?? '',
      assignedUser: json['assignedUser'] as String? ?? '',
      purchaseDate: json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate'] as String) : DateTime.now(),
      warrantyExpiry: json['warrantyExpiry'] != null ? DateTime.parse(json['warrantyExpiry'] as String) : DateTime.now(),
      status: _parseAssetStatus(json['status']),
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetCode': assetCode,
      'assetName': assetName,
      'assetType': assetType,
      'department': department,
      'assignedUser': assignedUser,
      'purchaseDate': purchaseDate.toIso8601String(),
      'warrantyExpiry': warrantyExpiry.toIso8601String(),
      'status': status.index,
      'note': note,
    };
  }

  static AssetStatus _parseAssetStatus(dynamic status) {
    if (status is int) {
      return AssetStatus.values[status];
    }
    final statusStr = (status as String? ?? '').toLowerCase();
    if (statusStr == 'inuse') return AssetStatus.inUse;
    if (statusStr == 'inmaintenance') return AssetStatus.inMaintenance;
    if (statusStr == 'retired') return AssetStatus.retired;
    return AssetStatus.available;
  }
}
