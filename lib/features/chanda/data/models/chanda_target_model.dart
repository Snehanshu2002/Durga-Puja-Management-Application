import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chanda_target.dart';

class ChandaTargetModel extends ChandaTarget {
  const ChandaTargetModel({
    required super.id,
    super.userId,
    required super.personName,
    super.mobileNumber,
    required super.targetAmount,
    required super.eventId,
    required super.eventType,
    required super.eventYear,
    required super.organizationName,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
  });

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  factory ChandaTargetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChandaTargetModel(
      id: doc.id,
      userId: data['userId'],
      personName: data['personName'] ?? '',
      mobileNumber: data['mobileNumber'],
      targetAmount: (data['targetAmount'] as num?)?.toInt() ?? 0,
      eventId: data['eventId'] ?? '',
      eventType: data['eventType'] ?? 'BHASANI_UTSAB',
      eventYear: (data['eventYear'] as num?)?.toInt() ?? 2026,
      organizationName: data['organizationName'] ?? 'Maa Durga Debi Bhashani Ustav SamitI',
      status: data['status'] ?? 'PENDING',
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'personName': personName,
      'mobileNumber': mobileNumber,
      'targetAmount': targetAmount,
      'eventId': eventId,
      'eventType': eventType,
      'eventYear': eventYear,
      'organizationName': organizationName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  factory ChandaTargetModel.fromEntity(ChandaTarget entity) {
    return ChandaTargetModel(
      id: entity.id,
      userId: entity.userId,
      personName: entity.personName,
      mobileNumber: entity.mobileNumber,
      targetAmount: entity.targetAmount,
      eventId: entity.eventId,
      eventType: entity.eventType,
      eventYear: entity.eventYear,
      organizationName: entity.organizationName,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
    );
  }
}
