import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/event_access.dart';
import '../../domain/entities/user.dart';
import '../../../roles/domain/entities/app_role.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.password,
    super.mobile,
    required super.role,
    required super.status,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    super.activeSessionId,
    super.lastActiveAt,
    super.isOnline,
    super.sessionUpdatedAt,
    super.lastPlatform,
    super.eventAccess,
    super.assignedEventIds,
  });

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is DateTime) return val;
    return DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic val) {
    if (val == null) return null;
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val);
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    if (val is DateTime) return val;
    return null;
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawEventAccess = data['eventAccess'] as List<dynamic>?;
    final List<EventAccess>? parsedEventAccess = rawEventAccess
        ?.map((e) => EventAccess.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    final rawAssignedEventIds = data['assignedEventIds'] as List<dynamic>?;
    final List<String>? parsedAssignedEventIds = rawAssignedEventIds
        ?.map((e) => e.toString())
        .toList() ??
        parsedEventAccess?.map((e) => e.eventId).toList();

    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'],
      mobile: data['mobile'],
      role: AppRole.fromId(data['roleId'] ?? 'viewer'),
      status: data['status'] ?? 'ACTIVE',
      profileImageUrl: data['profileImageUrl'],
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      createdBy: data['createdBy'] ?? '',
      activeSessionId: data['activeSessionId'],
      lastActiveAt: _parseNullableDate(data['lastActiveAt']),
      isOnline: data['isOnline'] ?? false,
      sessionUpdatedAt: _parseNullableDate(data['sessionUpdatedAt']),
      lastPlatform: data['lastPlatform'] ?? data['platform'],
      eventAccess: parsedEventAccess,
      assignedEventIds: parsedAssignedEventIds,
    );
  }

  Map<String, dynamic> toFirestore() {
    final List<Map<String, dynamic>>? serializedEventAccess =
        eventAccess?.map((e) => e.toMap()).toList();
    final List<String>? eventIds = assignedEventIds ??
        eventAccess?.map((e) => e.eventId).toList();

    return {
      'uid': uid,
      'name': name,
      'email': email,
      if (password != null) 'password': password,
      'mobile': mobile,
      'roleId': role.id,
      'status': status,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'activeSessionId': activeSessionId,
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'isOnline': isOnline,
      'sessionUpdatedAt': sessionUpdatedAt != null ? Timestamp.fromDate(sessionUpdatedAt!) : null,
      'lastPlatform': lastPlatform,
      'eventAccess': ?serializedEventAccess,
      'assignedEventIds': ?eventIds,
    };
  }
}
