import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/enums/payment_mode.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.eventId,
    required super.categoryId,
    required super.description,
    required super.amount,
    required super.paidTo,
    required super.paymentMode,
    required super.date,
    super.remark,
    super.billUrl,
    super.voucherUrl,
    super.voucherPath,
    required super.status,
    required super.addedBy,
    required super.createdAt,
    required super.updatedAt,
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

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final billUrlVal = data['voucherUrl'] ?? data['billUrl'];
    return ExpenseModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      categoryId: data['categoryId'] ?? 'other',
      description: data['description'] ?? '',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      paidTo: data['paidTo'] ?? '',
      paymentMode: PaymentMode.fromId(data['paymentMode']),
      date: _parseDate(data['date']),
      remark: data['remark'],
      billUrl: billUrlVal,
      voucherUrl: billUrlVal,
      voucherPath: data['voucherPath'],
      status: data['status'] ?? 'PENDING',
      addedBy: data['addedBy'] ?? '',
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      approvedBy: data['approvedBy'],
      approvedAt: _parseNullableDate(data['approvedAt']),
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'eventId': eventId,
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'paidTo': paidTo,
      'paymentMode': paymentMode.id,
      'date': Timestamp.fromDate(date),
      'remark': remark,
      'billUrl': voucherUrl ?? billUrl,
      'voucherUrl': voucherUrl ?? billUrl,
      'voucherPath': voucherPath,
      'status': status,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectionReason': rejectionReason,
    };
  }

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      eventId: entity.eventId,
      categoryId: entity.categoryId,
      description: entity.description,
      amount: entity.amount,
      paidTo: entity.paidTo,
      paymentMode: entity.paymentMode,
      date: entity.date,
      remark: entity.remark,
      billUrl: entity.voucherUrl ?? entity.billUrl,
      voucherUrl: entity.voucherUrl ?? entity.billUrl,
      voucherPath: entity.voucherPath,
      status: entity.status,
      addedBy: entity.addedBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      approvedBy: entity.approvedBy,
      approvedAt: entity.approvedAt,
      rejectionReason: entity.rejectionReason,
    );
  }
}
