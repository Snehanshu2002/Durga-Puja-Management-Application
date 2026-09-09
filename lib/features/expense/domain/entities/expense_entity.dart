import '../../../../core/enums/payment_mode.dart';

class ExpenseEntity {
  final String id;
  final String eventId;
  final String categoryId;
  final String description;
  final int amount; // Stored in rupees or minor units
  final String paidTo;
  final PaymentMode paymentMode;
  final DateTime date;
  final String? remark;
  final String? billUrl;
  final String? voucherUrl;
  final String? voucherPath;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final String addedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;

  const ExpenseEntity({
    required this.id,
    required this.eventId,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.paidTo,
    required this.paymentMode,
    required this.date,
    this.remark,
    this.billUrl,
    this.voucherUrl,
    this.voucherPath,
    required this.status,
    required this.addedBy,
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
  });

  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  ExpenseEntity copyWith({
    String? id,
    String? eventId,
    String? categoryId,
    String? description,
    int? amount,
    String? paidTo,
    PaymentMode? paymentMode,
    DateTime? date,
    String? remark,
    String? billUrl,
    String? voucherUrl,
    String? voucherPath,
    String? status,
    String? addedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidTo: paidTo ?? this.paidTo,
      paymentMode: paymentMode ?? this.paymentMode,
      date: date ?? this.date,
      remark: remark ?? this.remark,
      billUrl: billUrl ?? this.billUrl,
      voucherUrl: voucherUrl ?? this.voucherUrl,
      voucherPath: voucherPath ?? this.voucherPath,
      status: status ?? this.status,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
