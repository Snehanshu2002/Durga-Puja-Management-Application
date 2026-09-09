import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.type,
    required super.entityType,
    required super.entityId,
    required super.eventId,
    required super.isRead,
    required super.createdAt,
  });

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is DateTime) return val;
    return DateTime.now();
  }

  factory AppNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      entityType: data['entityType'] ?? '',
      entityId: data['entityId'] ?? '',
      eventId: data['eventId'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'entityType': entityType,
      'entityId': entityId,
      'eventId': eventId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppNotificationModel.fromEntity(AppNotification entity) {
    return AppNotificationModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      entityType: entity.entityType,
      entityId: entity.entityId,
      eventId: entity.eventId,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }
}
