import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/puja_event.dart';

class PujaEventModel extends PujaEvent {
  const PujaEventModel({
    required super.id,
    required super.name,
    required super.year,
    super.eventType,
    super.organizationName,
    required super.startDate,
    required super.endDate,
    required super.location,
    required super.description,
    required super.status,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  static DateTime _parseDate(dynamic val, DateTime fallback) {
    if (val == null) return fallback;
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? fallback;
    return fallback;
  }

  factory PujaEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final eventId = data['eventId'] as String? ?? doc.id;
    return PujaEventModel(
      id: eventId,
      name: data['eventName'] ?? data['name'] ?? '',
      year: (data['year'] as num?)?.toInt() ?? DateTime.now().year,
      eventType: data['eventType'] ?? 'BHASANI_UTSAB',
      organizationName: data['organizationName'] ?? 'Maa Durga Debi Bhashani Ustav SamitI',
      startDate: _parseDate(data['startDate'], DateTime(2026, 10, 1)),
      endDate: _parseDate(data['endDate'], DateTime(2026, 10, 10)),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'ACTIVE',
      createdBy: data['createdBy'] ?? '',
      createdAt: _parseDate(data['createdAt'], DateTime.now()),
      updatedAt: _parseDate(data['updatedAt'], DateTime.now()),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'eventId': id,
      'name': name,
      'eventName': name,
      'year': year,
      'eventType': eventType,
      'organizationName': organizationName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'location': location,
      'description': description,
      'status': status,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PujaEventModel.fromEntity(PujaEvent entity) {
    return PujaEventModel(
      id: entity.id,
      name: entity.name,
      year: entity.year,
      eventType: entity.eventType,
      organizationName: entity.organizationName,
      startDate: entity.startDate,
      endDate: entity.endDate,
      location: entity.location,
      description: entity.description,
      status: entity.status,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
