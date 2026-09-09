class PujaEvent {
  final String id;
  final String name;
  final int year;
  final String eventType;
  final String organizationName;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String description;
  final String status; // 'ACTIVE', 'COMPLETED', 'ARCHIVED'
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PujaEvent({
    required this.id,
    required this.name,
    required this.year,
    this.eventType = 'BHASANI_UTSAB',
    this.organizationName = 'Maa Durga Debi Bhashani Ustav SamitI',
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.description,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  String get eventId => id;
  String get eventName => name;

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  PujaEvent copyWith({
    String? id,
    String? name,
    int? year,
    String? eventType,
    String? organizationName,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? description,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PujaEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      eventType: eventType ?? this.eventType,
      organizationName: organizationName ?? this.organizationName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      description: description ?? this.description,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
