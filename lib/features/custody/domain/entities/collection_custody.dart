class CollectionCustody {
  static const String typeCashHandover = 'CASH_HANDOVER';
  static const String typeBankDeposit = 'BANK_DEPOSIT';
  static const String typeOther = 'OTHER';

  static const String statusPending = 'PENDING';
  static const String statusReceived = 'RECEIVED';
  static const String statusDeposited = 'DEPOSITED';
  static const String statusCancelled = 'CANCELLED';

  final String id;
  final String? collectionId;
  final String eventId;
  final String eventType;
  final int eventYear;
  final String organizationName;
  final int amount;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final String handoverType;
  final String status;
  final DateTime handedOverAt;
  final DateTime? receivedAt;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;

  const CollectionCustody({
    required this.id,
    this.collectionId,
    required this.eventId,
    required this.eventType,
    required this.eventYear,
    required this.organizationName,
    required this.amount,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.handoverType,
    required this.status,
    required this.handedOverAt,
    this.receivedAt,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isReceived => status == statusReceived;
  bool get isDeposited => status == statusDeposited;
  bool get isPending => status == statusPending;
  bool get isCancelled => status == statusCancelled;
  bool get isBankDeposit => handoverType == typeBankDeposit;

  CollectionCustody copyWith({
    String? id,
    String? collectionId,
    String? eventId,
    String? eventType,
    int? eventYear,
    String? organizationName,
    int? amount,
    String? fromUserId,
    String? fromUserName,
    String? toUserId,
    String? toUserName,
    String? handoverType,
    String? status,
    DateTime? handedOverAt,
    DateTime? receivedAt,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CollectionCustody(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      eventYear: eventYear ?? this.eventYear,
      organizationName: organizationName ?? this.organizationName,
      amount: amount ?? this.amount,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      handoverType: handoverType ?? this.handoverType,
      status: status ?? this.status,
      handedOverAt: handedOverAt ?? this.handedOverAt,
      receivedAt: receivedAt ?? this.receivedAt,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
