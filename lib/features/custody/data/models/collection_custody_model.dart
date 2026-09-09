import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/collection_custody.dart';

class CollectionCustodyModel extends CollectionCustody {
  const CollectionCustodyModel({
    required super.id,
    super.collectionId,
    required super.eventId,
    required super.eventType,
    required super.eventYear,
    required super.organizationName,
    required super.amount,
    required super.fromUserId,
    required super.fromUserName,
    required super.toUserId,
    required super.toUserName,
    required super.handoverType,
    required super.status,
    required super.handedOverAt,
    super.receivedAt,
    super.notes,
    required super.createdBy,
    required super.createdAt,
  });

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic val) {
    if (val == null) return null;
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val);
    return null;
  }

  factory CollectionCustodyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectionCustodyModel(
      id: doc.id,
      collectionId: data['collectionId'],
      eventId: data['eventId'] ?? '',
      eventType: data['eventType'] ?? 'BHASANI_UTSAB',
      eventYear: (data['eventYear'] as num?)?.toInt() ?? 2026,
      organizationName: data['organizationName'] ?? 'Maa Durga Debi Bhashani Ustav SamitI',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? '',
      toUserId: data['toUserId'] ?? '',
      toUserName: data['toUserName'] ?? '',
      handoverType: data['handoverType'] ?? CollectionCustody.typeCashHandover,
      status: data['status'] ?? CollectionCustody.statusReceived,
      handedOverAt: _parseDate(data['handedOverAt']),
      receivedAt: _parseNullableDate(data['receivedAt']),
      notes: data['notes'],
      createdBy: data['createdBy'] ?? '',
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'collectionId': collectionId,
      'eventId': eventId,
      'eventType': eventType,
      'eventYear': eventYear,
      'organizationName': organizationName,
      'amount': amount,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'handoverType': handoverType,
      'status': status,
      'handedOverAt': Timestamp.fromDate(handedOverAt),
      'receivedAt': receivedAt != null ? Timestamp.fromDate(receivedAt!) : null,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CollectionCustodyModel.fromEntity(CollectionCustody entity) {
    return CollectionCustodyModel(
      id: entity.id,
      collectionId: entity.collectionId,
      eventId: entity.eventId,
      eventType: entity.eventType,
      eventYear: entity.eventYear,
      organizationName: entity.organizationName,
      amount: entity.amount,
      fromUserId: entity.fromUserId,
      fromUserName: entity.fromUserName,
      toUserId: entity.toUserId,
      toUserName: entity.toUserName,
      handoverType: entity.handoverType,
      status: entity.status,
      handedOverAt: entity.handedOverAt,
      receivedAt: entity.receivedAt,
      notes: entity.notes,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
    );
  }
}
