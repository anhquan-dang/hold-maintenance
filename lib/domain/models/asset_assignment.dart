class AssetAssignment {
  final String id;
  final String assetId;
  final String userId;
  final String userName; // Helper field for presentation
  final DateTime assignedDate;
  final DateTime? returnedDate;
  final String note;

  const AssetAssignment({
    required this.id,
    required this.assetId,
    required this.userId,
    required this.userName,
    required this.assignedDate,
    this.returnedDate,
    required this.note,
  });

  AssetAssignment copyWith({
    String? id,
    String? assetId,
    String? userId,
    String? userName,
    DateTime? assignedDate,
    DateTime? returnedDate,
    String? note,
  }) {
    return AssetAssignment(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      assignedDate: assignedDate ?? this.assignedDate,
      returnedDate: returnedDate ?? this.returnedDate,
      note: note ?? this.note,
    );
  }

  factory AssetAssignment.fromJson(Map<String, dynamic> json) {
    return AssetAssignment(
      id: json['id'] as String? ?? '',
      assetId: json['assetId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      assignedDate: json['assignedDate'] != null ? DateTime.parse(json['assignedDate'] as String) : DateTime.now(),
      returnedDate: json['returnedDate'] != null ? DateTime.parse(json['returnedDate'] as String) : null,
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'userId': userId,
      'userName': userName,
      'assignedDate': assignedDate.toIso8601String(),
      'returnedDate': returnedDate?.toIso8601String(),
      'note': note,
    };
  }
}
