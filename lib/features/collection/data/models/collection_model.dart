import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/payment_mode.dart';
import '../../domain/entities/collection_entity.dart';

class CollectionModel extends CollectionEntity {
  const CollectionModel({
    required super.id,
    required super.eventId,
    super.userId,
    required super.donorName,
    super.mobileNumber,
    required super.amount,
    required super.paymentMode,
    super.transactionId,
    required super.purpose,
    required super.collectedBy,
    required super.date,
    super.remark,
    super.paymentScreenshotUrl,
    super.paymentScreenshotPath,
    required super.status,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.chandaTargetId,
    super.custodyId,
    super.approvedBy,
    super.approvedAt,
    super.rejectionReason,
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

  factory CollectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectionModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'],
      donorName: data['donorName'] ?? '',
      mobileNumber: data['mobileNumber'],
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      paymentMode: PaymentMode.fromId(data['paymentMode']),
      transactionId: data['transactionId'],
      purpose: data['purpose'] ?? 'Durga Puja Donation',
      collectedBy: data['collectedBy'] ?? '',
      date: _parseDate(data['date']),
      remark: data['remark'],
      paymentScreenshotUrl: data['paymentScreenshotUrl'],
      paymentScreenshotPath: data['paymentScreenshotPath'],
      status: data['status'] ?? 'PENDING',
      createdBy: data['createdBy'] ?? '',
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      chandaTargetId: data['chandaTargetId'],
      custodyId: data['custodyId'],
      approvedBy: data['approvedBy'],
      approvedAt: _parseNullableDate(data['approvedAt']),
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'donorName': donorName,
      'mobileNumber': mobileNumber,
      'amount': amount,
      'paymentMode': paymentMode.id,
      'transactionId': transactionId,
      'purpose': purpose,
      'collectedBy': collectedBy,
      'date': Timestamp.fromDate(date),
      'remark': remark,
      'paymentScreenshotUrl': paymentScreenshotUrl,
      'paymentScreenshotPath': paymentScreenshotPath,
      'status': status,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'chandaTargetId': chandaTargetId,
      'custodyId': custodyId,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectionReason': rejectionReason,
    };
  }

  factory CollectionModel.fromEntity(CollectionEntity entity) {
    return CollectionModel(
      id: entity.id,
      eventId: entity.eventId,
      userId: entity.userId,
      donorName: entity.donorName,
      mobileNumber: entity.mobileNumber,
      amount: entity.amount,
      paymentMode: entity.paymentMode,
      transactionId: entity.transactionId,
      purpose: entity.purpose,
      collectedBy: entity.collectedBy,
      date: entity.date,
      remark: entity.remark,
      paymentScreenshotUrl: entity.paymentScreenshotUrl,
      paymentScreenshotPath: entity.paymentScreenshotPath,
      status: entity.status,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      chandaTargetId: entity.chandaTargetId,
      custodyId: entity.custodyId,
      approvedBy: entity.approvedBy,
      approvedAt: entity.approvedAt,
      rejectionReason: entity.rejectionReason,
    );
  }
}
