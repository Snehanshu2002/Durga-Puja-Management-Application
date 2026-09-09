import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/audit_log.dart';

class AuditLogModel extends AuditLog {
  const AuditLogModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.userName,
    required super.action,
    required super.entityType,
    required super.entityId,
    required super.timestamp,
    super.metadata,
  });

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  factory AuditLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLogModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      action: data['action'] ?? '',
      entityType: data['entityType'] ?? '',
      entityId: data['entityId'] ?? '',
      timestamp: _parseDate(data['timestamp']),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  factory AuditLogModel.fromEntity(AuditLog entity) {
    return AuditLogModel(
      id: entity.id,
      eventId: entity.eventId,
      userId: entity.userId,
      userName: entity.userName,
      action: entity.action,
      entityType: entity.entityType,
      entityId: entity.entityId,
      timestamp: entity.timestamp,
      metadata: entity.metadata,
    );
  }
}
