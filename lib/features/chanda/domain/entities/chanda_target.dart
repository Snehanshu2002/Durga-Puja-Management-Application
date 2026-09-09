class ChandaTarget {
  final String id;
  final String? userId; // Linked user ID from master users collection
  final String personName;
  final String? mobileNumber;
  final int targetAmount;
  final String eventId;
  final String eventType;
  final int eventYear;
  final String organizationName;
  final String status; // 'PENDING', 'PARTIAL', 'PAID', 'CANCELLED'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const ChandaTarget({
    required this.id,
    this.userId,
    required this.personName,
    this.mobileNumber,
    required this.targetAmount,
    required this.eventId,
    required this.eventType,
    required this.eventYear,
    required this.organizationName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  bool get isPaid => status.toUpperCase() == 'PAID';
  bool get isPartial => status.toUpperCase() == 'PARTIAL';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';

  ChandaTarget copyWith({
    String? id,
    String? userId,
    String? personName,
    String? mobileNumber,
    int? targetAmount,
    String? eventId,
    String? eventType,
    int? eventYear,
    String? organizationName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ChandaTarget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      personName: personName ?? this.personName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      targetAmount: targetAmount ?? this.targetAmount,
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      eventYear: eventYear ?? this.eventYear,
      organizationName: organizationName ?? this.organizationName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
