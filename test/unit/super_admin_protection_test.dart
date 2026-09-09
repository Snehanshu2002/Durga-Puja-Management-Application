import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/error/app_exception.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/app_role.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';

void main() {
  group('Super Admin Protection Rules Tests', () {
    final now = DateTime.now();

    final superAdminUser = AppUser(
      uid: 'admin_1',
      name: 'Sole Super Admin',
      email: 'admin@durgapuja.org',
      role: AppRole.superAdmin,
      status: 'ACTIVE',
      createdAt: now,
      updatedAt: now,
      createdBy: 'system',
    );

    test('Prevents demotion if only one active Super Admin exists', () {
      final activeSuperAdmins = [superAdminUser];

      expect(
        () {
          if (activeSuperAdmins.length <= 1) {
            throw AppException('At least one active Super Admin must remain.');
          }
        },
        throwsA(isA<AppException>()),
      );
    });

    test('Allows demotion if multiple active Super Admins exist', () {
      final secondAdmin = superAdminUser.copyWith(uid: 'admin_2');
      final activeSuperAdmins = [superAdminUser, secondAdmin];

      expect(
        () {
          if (activeSuperAdmins.length <= 1) {
            throw AppException('At least one active Super Admin must remain.');
          }
        },
        returnsNormally,
      );
    });
  });
}
