class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // COLLECTION_ADDED, EXPENSE_ADDED, COLLECTION_APPROVED, COLLECTION_REJECTED, EXPENSE_APPROVED, EXPENSE_REJECTED, APPROVAL_REQUIRED
  final String entityType; // COLLECTION, EXPENSE
  final String entityId;
  final String eventId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.eventId,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    String? entityType,
    String? entityId,
    String? eventId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      eventId: eventId ?? this.eventId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
