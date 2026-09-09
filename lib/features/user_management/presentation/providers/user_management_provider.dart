import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/error/app_exception.dart';
import 'package:durgapuja_manager/features/audit/domain/entities/audit_log.dart';
import 'package:durgapuja_manager/features/audit/presentation/providers/audit_provider.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/app_role.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';

final allUsersProvider = StreamProvider<List<AppUser>>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.watchAllUsers();
});

final userManagementSearchQueryProvider = StateProvider<String>((ref) => '');
final userManagementRoleFilterProvider = StateProvider<AppRole?>((ref) => null);
final userManagementStatusFilterProvider = StateProvider<String?>((ref) => null);

class UserManagementController {
  final Ref ref;

  UserManagementController(this.ref);

  /// Check if user has permission for user management operations (Super Admin only)
  bool _canManageUsers(AppUser user) {
    return user.role == AppRole.superAdmin;
  }

  Future<void> updateUserRole({
    required AppUser targetUser,
    required AppRole newRole,
    required AppUser currentUser,
  }) async {
    if (!_canManageUsers(currentUser)) {
      throw AppException('Only Super Admin can change user roles.');
    }

    final allUsers = await ref.read(userRepositoryProvider).getAllUsers();

    if (targetUser.role == AppRole.superAdmin && newRole != AppRole.superAdmin) {
      final activeSuperAdmins = allUsers.where(
        (u) => u.role == AppRole.superAdmin && u.status.toUpperCase() == 'ACTIVE',
      );
      if (activeSuperAdmins.length <= 1) {
        throw AppException('At least one active Super Admin must remain.');
      }
    }

    final updated = targetUser.copyWith(
      role: newRole,
      updatedAt: DateTime.now(),
    );

    await ref.read(userRepositoryProvider).updateUser(updated);
    ref.invalidate(allUsersProvider);
  }

  /// Deactivate user (ACTIVE -> DEACTIVATED)
  Future<void> deactivateUser({
    required AppUser targetUser,
    required AppUser currentUser,
  }) async {
    if (!_canManageUsers(currentUser)) {
      throw AppException('Only Super Admin can deactivate members.');
    }

    if (targetUser.role == AppRole.superAdmin) {
      final allUsers = await ref.read(userRepositoryProvider).getAllUsers();
      final activeSuperAdmins = allUsers.where(
        (u) => u.role == AppRole.superAdmin && u.status.toUpperCase() == 'ACTIVE',
      );
      if (activeSuperAdmins.length <= 1) {
        throw AppException('At least one active Super Admin must remain.');
      }
    }

    // Direct Firestore update to invalidate activeSessionId & set status to DEACTIVATED
    await FirebaseFirestore.instance.collection('users').doc(targetUser.uid).update({
      'status': 'DEACTIVATED',
      'activeSessionId': null,
      'isOnline': false,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await _writeAuditLog(
      performer: currentUser,
      targetUser: targetUser,
      action: AuditLog.actionUserDeactivated,
      reason: 'Account deactivated by ${currentUser.name}',
    );

    ref.invalidate(allUsersProvider);
  }

  /// Remove user association (Status -> REMOVED)
  Future<void> removeUserAssociation({
    required AppUser targetUser,
    required AppUser currentUser,
  }) async {
    if (!_canManageUsers(currentUser)) {
      throw AppException('Only Super Admin can remove member associations.');
    }

    if (targetUser.role == AppRole.superAdmin) {
      final allUsers = await ref.read(userRepositoryProvider).getAllUsers();
      final activeSuperAdmins = allUsers.where(
        (u) => u.role == AppRole.superAdmin && u.status.toUpperCase() == 'ACTIVE',
      );
      if (activeSuperAdmins.length <= 1) {
        throw AppException('At least one active Super Admin must remain.');
      }
    }

    // Reset activeSessionId & clear device session while keeping account ACTIVE for re-login
    await FirebaseFirestore.instance.collection('users').doc(targetUser.uid).update({
      'status': 'ACTIVE',
      'activeSessionId': null,
      'isOnline': false,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await _writeAuditLog(
      performer: currentUser,
      targetUser: targetUser,
      action: AuditLog.actionUserAssociationRemoved,
      reason: 'Member association removed by ${currentUser.name}',
    );

    ref.invalidate(allUsersProvider);
  }

  Future<void> toggleUserStatus({
    required AppUser targetUser,
    required AppUser currentUser,
  }) async {
    if (targetUser.status.toUpperCase() == 'ACTIVE') {
      await deactivateUser(targetUser: targetUser, currentUser: currentUser);
    } else {
      if (!_canManageUsers(currentUser)) {
        throw AppException('Only Super Admin can activate members.');
      }
      final updated = targetUser.copyWith(
        status: 'ACTIVE',
        updatedAt: DateTime.now(),
      );
      await ref.read(userRepositoryProvider).updateUser(updated);
      ref.invalidate(allUsersProvider);
    }
  }

  Future<void> addNewUser({
    required String name,
    required String email,
    required String password,
    String? mobile,
    required AppRole role,
    required AppUser currentUser,
  }) async {
    if (!_canManageUsers(currentUser)) {
      throw AppException('Only Super Admin can add new members.');
    }

    if (password.trim().length < 6) {
      throw AppException('Password must be at least 6 characters.');
    }

    final allUsers = await ref.read(userRepositoryProvider).getAllUsers();
    final existing = allUsers.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (existing) {
      throw AppException('A user with email "${email.trim()}" already exists.');
    }

    final newUid = 'user_${DateTime.now().millisecondsSinceEpoch}';

    final newUser = AppUser(
      uid: newUid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password.trim(),
      mobile: mobile?.trim().isEmpty ?? true ? null : mobile?.trim(),
      role: role,
      status: 'ACTIVE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: currentUser.uid,
    );

    await ref.read(userRepositoryProvider).createUser(newUser);
    ref.invalidate(allUsersProvider);
  }

  Future<void> _writeAuditLog({
    required AppUser performer,
    required AppUser targetUser,
    required String action,
    required String reason,
  }) async {
    try {
      final auditRepo = ref.read(auditRepositoryProvider);
      final log = AuditLog(
        id: 'audit_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}',
        eventId: 'global',
        userId: performer.uid,
        userName: performer.name,
        action: action,
        entityType: 'USER',
        entityId: targetUser.uid,
        timestamp: DateTime.now(),
        metadata: {
          'targetEmail': targetUser.email,
          'targetName': targetUser.name,
          'targetRole': targetUser.role.id,
          'reason': reason,
        },
      );
      await auditRepo.logAction(log);
    } catch (e) {
      debugPrint('Audit logging failed: $e');
    }
  }
}

final userManagementControllerProvider = Provider<UserManagementController>((ref) {
  return UserManagementController(ref);
});
