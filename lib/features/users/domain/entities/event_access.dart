class EventAccess {
  final String eventId;
  final String eventType;
  final int year;
  final String organizationName;
  final String? roleId;

  const EventAccess({
    required this.eventId,
    required this.eventType,
    required this.year,
    required this.organizationName,
    this.roleId,
  });

  factory EventAccess.fromMap(Map<String, dynamic> map) {
    return EventAccess(
      eventId: map['eventId'] ?? '',
      eventType: map['eventType'] ?? '',
      year: (map['year'] as num?)?.toInt() ?? 0,
      organizationName: map['organizationName'] ?? '',
      roleId: map['roleId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventType': eventType,
      'year': year,
      'organizationName': organizationName,
      if (roleId != null) 'roleId': roleId,
    };
  }
}
