import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/app_role.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';

void main() {
  group('Roles & Permission Matrix Tests', () {
    final permissionService = PermissionService();

    test('SUPER_ADMIN has all permissions', () {
      for (final permission in Permission.values) {
        expect(
          permissionService.hasPermission(AppRole.superAdmin, permission),
          isTrue,
          reason: 'SUPER_ADMIN should have ${permission.name}',
        );
      }
    });

    test('VIEWER cannot addCollection', () {
      expect(
        permissionService.hasPermission(AppRole.viewer, Permission.addCollection),
        isFalse,
      );
    });

    test('COLLECTION_MEMBER can addCollection but cannot approve', () {
      expect(
        permissionService.hasPermission(AppRole.collectionMember, Permission.addCollection),
        isTrue,
      );
      expect(
        permissionService.hasPermission(AppRole.collectionMember, Permission.approveCollection),
        isFalse,
      );
    });

    test('TREASURER can approveCollection and approveExpense', () {
      expect(
        permissionService.hasPermission(AppRole.treasurer, Permission.approveCollection),
        isTrue,
      );
      expect(
        permissionService.hasPermission(AppRole.treasurer, Permission.approveExpense),
        isTrue,
      );
    });

    test('MANAGER cannot manageUsers', () {
      expect(
        permissionService.hasPermission(AppRole.manager, Permission.manageUsers),
        isFalse,
      );
    });

    test('PRESIDENT cannot manageUsers (Super Admin only)', () {
      expect(
        permissionService.hasPermission(AppRole.president, Permission.manageUsers),
        isFalse,
      );
    });

    test('canDeactivateUser is true only for SUPER_ADMIN', () {
      expect(permissionService.canDeactivateUser(AppRole.superAdmin), isTrue);
      expect(permissionService.canDeactivateUser(AppRole.president), isFalse);
      expect(permissionService.canDeactivateUser(AppRole.treasurer), isFalse);
      expect(permissionService.canDeactivateUser(AppRole.manager), isFalse);
      expect(permissionService.canDeactivateUser(AppRole.collectionMember), isFalse);
      expect(permissionService.canDeactivateUser(AppRole.viewer), isFalse);
    });

    test('Role string conversion works correctly', () {
      expect(AppRole.fromId('super_admin'), AppRole.superAdmin);
      expect(AppRole.fromId('president'), AppRole.president);
      expect(AppRole.fromId('treasurer'), AppRole.treasurer);
      expect(AppRole.fromId('manager'), AppRole.manager);
      expect(AppRole.fromId('collection_member'), AppRole.collectionMember);
      expect(AppRole.fromId('viewer'), AppRole.viewer);
      expect(AppRole.fromId('unknown_role'), AppRole.viewer);
    });
  });
}
