import 'package:durgapuja_manager/features/roles/domain/entities/app_role.dart';
import 'event_access.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? password;
  final String? mobile;
  final AppRole role;
  final String status;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? activeSessionId;
  final DateTime? lastActiveAt;
  final bool isOnline;
  final DateTime? sessionUpdatedAt;
  final String? lastPlatform;
  final List<EventAccess>? eventAccess;
  final List<String>? assignedEventIds;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.password,
    this.mobile,
    required this.role,
    required this.status,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.activeSessionId,
    this.lastActiveAt,
    this.isOnline = false,
    this.sessionUpdatedAt,
    this.lastPlatform,
    this.eventAccess,
    this.assignedEventIds,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  bool hasAccessToEvent(String eventId) {
    if (role.isSuperAdmin) return true;

    if (assignedEventIds != null) {
      if (assignedEventIds!.contains(eventId)) return true;
      if ((eventId == 'bhasani_utsab_2026' || eventId == 'event_2026') &&
          (assignedEventIds!.contains('bhasani_utsab_2026') || assignedEventIds!.contains('event_2026'))) {
        return true;
      }
      return false;
    }

    if (eventAccess != null) {
      if (eventAccess!.any((e) => e.eventId == eventId)) return true;
      if ((eventId == 'bhasani_utsab_2026' || eventId == 'event_2026') &&
          eventAccess!.any((e) => e.eventId == 'bhasani_utsab_2026' || e.eventId == 'event_2026')) {
        return true;
      }
      return false;
    }

    // Default fallback when eventAccess is not specified (e.g. unit tests / legacy mock users)
    return true;
  }

  AppRole getEffectiveRoleForEvent(String? eventId) {
    if (role.isSuperAdmin) return AppRole.superAdmin;
    if (eventId == null || eventAccess == null || eventAccess!.isEmpty) {
      return role;
    }

    for (final access in eventAccess!) {
      if (access.eventId == eventId ||
          ((eventId == 'bhasani_utsab_2026' || eventId == 'event_2026') &&
           (access.eventId == 'bhasani_utsab_2026' || access.eventId == 'event_2026'))) {
        if (access.roleId != null && access.roleId!.isNotEmpty) {
          return AppRole.fromId(access.roleId);
        }
      }
    }

    return role;
  }

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? password,
    String? mobile,
    AppRole? role,
    String? status,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? activeSessionId,
    DateTime? lastActiveAt,
    bool? isOnline,
    DateTime? sessionUpdatedAt,
    String? lastPlatform,
    List<EventAccess>? eventAccess,
    List<String>? assignedEventIds,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isOnline: isOnline ?? this.isOnline,
      sessionUpdatedAt: sessionUpdatedAt ?? this.sessionUpdatedAt,
      lastPlatform: lastPlatform ?? this.lastPlatform,
      eventAccess: eventAccess ?? this.eventAccess,
      assignedEventIds: assignedEventIds ?? this.assignedEventIds,
    );
  }
}
