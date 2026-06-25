class SupportNote {
  final String id;
  final String ticketId;
  final String assetId;
  final String handledBy;
  final String content;
  final DateTime createdAt;

  const SupportNote({
    required this.id,
    required this.ticketId,
    required this.assetId,
    required this.handledBy,
    required this.content,
    required this.createdAt,
  });

  factory SupportNote.fromJson(Map<String, dynamic> json) {
    return SupportNote(
      id: json['id'] as String? ?? '',
      ticketId: json['ticketId'] as String? ?? '',
      assetId: json['assetId'] as String? ?? '',
      handledBy: json['handledBy'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'assetId': assetId,
      'handledBy': handledBy,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
