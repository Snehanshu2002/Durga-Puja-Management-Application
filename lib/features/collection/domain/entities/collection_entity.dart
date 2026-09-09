import '../../../../core/enums/payment_mode.dart';

class CollectionEntity {
  final String id;
  final String eventId;
  final String? userId; // Link to user from master users collection
  final String donorName;
  final String? mobileNumber;
  final int amount; // Stored in rupees (or minor units if designated)
  final PaymentMode paymentMode;
  final String? transactionId;
  final String purpose;
  final String collectedBy;
  final DateTime date;
  final String? remark;
  final String? paymentScreenshotUrl;
  final String? paymentScreenshotPath;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? chandaTargetId;
  final String? custodyId;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;

  const CollectionEntity({
    required this.id,
    required this.eventId,
    this.userId,
    required this.donorName,
    this.mobileNumber,
    required this.amount,
    required this.paymentMode,
    this.transactionId,
    required this.purpose,
    required this.collectedBy,
    required this.date,
    this.remark,
    this.paymentScreenshotUrl,
    this.paymentScreenshotPath,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.chandaTargetId,
    this.custodyId,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
  });

  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get isCustodyLinked => custodyId != null && custodyId!.isNotEmpty;

  CollectionEntity copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? donorName,
    String? mobileNumber,
    int? amount,
    PaymentMode? paymentMode,
    String? transactionId,
    String? purpose,
    String? collectedBy,
    DateTime? date,
    String? remark,
    String? paymentScreenshotUrl,
    String? paymentScreenshotPath,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? chandaTargetId,
    String? custodyId,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
  }) {
    return CollectionEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      donorName: donorName ?? this.donorName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      transactionId: transactionId ?? this.transactionId,
      purpose: purpose ?? this.purpose,
      collectedBy: collectedBy ?? this.collectedBy,
      date: date ?? this.date,
      remark: remark ?? this.remark,
      paymentScreenshotUrl: paymentScreenshotUrl ?? this.paymentScreenshotUrl,
      paymentScreenshotPath: paymentScreenshotPath ?? this.paymentScreenshotPath,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chandaTargetId: chandaTargetId ?? this.chandaTargetId,
      custodyId: custodyId ?? this.custodyId,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
