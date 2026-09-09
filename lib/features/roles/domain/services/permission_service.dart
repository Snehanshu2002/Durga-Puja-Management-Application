import '../entities/app_role.dart';
import '../entities/permission.dart';

class PermissionService {
  static const Map<AppRole, Set<Permission>> _rolePermissions = {
    AppRole.superAdmin: {
      Permission.viewDashboard,
      Permission.viewCollection,
      Permission.addCollection,
      Permission.editCollection,
      Permission.deleteCollection,
      Permission.approveCollection,
      Permission.viewExpense,
      Permission.addExpense,
      Permission.editExpense,
      Permission.deleteExpense,
      Permission.approveExpense,
      Permission.viewReports,
      Permission.exportReports,
      Permission.manageUsers,
      Permission.manageRoles,
      Permission.managePujaEvents,
      Permission.manageCategories,
      Permission.viewAuditLogs,
      Permission.manageSettings,
    },
    AppRole.president: {
      Permission.viewDashboard,
      Permission.viewCollection,
      Permission.addCollection,
      Permission.editCollection,
      Permission.approveCollection,
      Permission.viewExpense,
      Permission.addExpense,
      Permission.editExpense,
      Permission.approveExpense,
      Permission.viewReports,
      Permission.exportReports,
      Permission.managePujaEvents,
      Permission.manageCategories,
      Permission.viewAuditLogs,
    },
    AppRole.treasurer: {
      Permission.viewDashboard,
      Permission.viewCollection,
      Permission.addCollection,
      Permission.editCollection,
      Permission.approveCollection,
      Permission.viewExpense,
      Permission.addExpense,
      Permission.editExpense,
      Permission.approveExpense,
      Permission.viewReports,
      Permission.exportReports,
      Permission.viewAuditLogs,
    },
    AppRole.manager: {
      Permission.viewDashboard,
      Permission.viewCollection,
      Permission.addCollection,
      Permission.viewExpense,
      Permission.addExpense,
      Permission.viewReports,
    },
    AppRole.collectionMember: {
      Permission.viewDashboard,
      Permission.viewCollection,
      Permission.addCollection,
    },
    AppRole.viewer: {
      Permission.viewDashboard,
      Permission.viewCollection,
      Permission.viewExpense,
      Permission.viewReports,
    },
  };

  bool hasPermission(AppRole role, Permission permission) {
    final permissions = _rolePermissions[role];
    return permissions?.contains(permission) ?? false;
  }

  bool hasAnyPermission(AppRole role, List<Permission> permissions) {
    return permissions.any((p) => hasPermission(role, p));
  }

  bool hasAllPermissions(AppRole role, List<Permission> permissions) {
    return permissions.every((p) => hasPermission(role, p));
  }

  /// Evaluates whether a user with given [role] can delete a Collection.
  /// Hard financial rule: APPROVED records and Custody-linked records can NEVER be deleted.
  bool canDeleteCollection({
    required AppRole role,
    required String status,
    required bool isOwner,
    bool isCustodyLinked = false,
  }) {
    if (status.toUpperCase() == 'APPROVED') return false;
    if (isCustodyLinked) return false;
    if (status.toUpperCase() != 'PENDING') return false;

    switch (role) {
      case AppRole.superAdmin:
        return true;
      case AppRole.president:
        return true;
      case AppRole.treasurer:
      case AppRole.manager:
      case AppRole.collectionMember:
        return isOwner;
      case AppRole.viewer:
        return false;
    }
  }

  /// Evaluates whether a user with given [role] can delete an Expense.
  /// Hard financial rule: APPROVED records can NEVER be deleted.
  bool canDeleteExpense({
    required AppRole role,
    required String status,
    required bool isOwner,
  }) {
    if (status.toUpperCase() == 'APPROVED') return false;
    if (status.toUpperCase() != 'PENDING') return false;

    switch (role) {
      case AppRole.superAdmin:
        return true;
      case AppRole.president:
        return true;
      case AppRole.treasurer:
      case AppRole.manager:
        return isOwner;
      case AppRole.collectionMember:
      case AppRole.viewer:
        return false;
    }
  }

  /// Only Super Admin can deactivate / reactivate users.
  bool canDeactivateUser(AppRole role) {
    return role == AppRole.superAdmin;
  }
}
