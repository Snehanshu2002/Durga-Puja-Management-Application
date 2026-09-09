import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/utils/dev_seeder.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_category.dart';

void main() {
  group('DEV Dataset Seeder Integrity & Schema Tests', () {
    test('DEV Events list contains all 3 required events with correct IDs and organization names', () {
      final events = DevBootstrapSeeder.devEvents;
      expect(events.length, equals(3));

      final eventIds = events.map((e) => e['id'] as String).toList();
      expect(eventIds, containsAll(['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026']));

      final bhasani = events.firstWhere((e) => e['id'] == 'bhasani_utsab_2026');
      expect(bhasani['organizationName'], equals('Maa Durga Debi Bhashani Ustav SamitI'));
      expect(bhasani['year'], equals(2026));
      expect(bhasani['eventType'], equals('BHASANI_UTSAB'));
      expect(bhasani['status'], equals('ACTIVE'));

      final opera25 = events.firstWhere((e) => e['id'] == 'opera_jatra_2025');
      expect(opera25['organizationName'], equals('MAA DURGA DEVI YOUTH ASSOCIATION'));
      expect(opera25['year'], equals(2025));
      expect(opera25['status'], equals('COMPLETED'));

      final opera26 = events.firstWhere((e) => e['id'] == 'opera_jatra_2026');
      expect(opera26['organizationName'], equals('MAA DURGA DEVI YOUTH ASSOCIATION'));
      expect(opera26['year'], equals(2026));
      expect(opera26['status'], equals('ACTIVE'));
    });

    test('DEV Users list contains Super Admin, President, Treasurer, Manager, Collector, Viewer', () {
      final users = DevBootstrapSeeder.devUsers;
      expect(users.length, greaterThanOrEqualTo(6));

      final roles = users.map((u) => u['roleId'] as String).toSet();
      expect(roles, containsAll(['super_admin', 'president', 'treasurer', 'manager', 'collection_member', 'viewer']));

      final superAdmin = users.firstWhere((u) => u['roleId'] == 'super_admin');
      expect(superAdmin['email'], equals('admin.dev@durgapuja.org'));
      expect(superAdmin['status'], equals('ACTIVE'));
      expect((superAdmin['assignedEventIds'] as List).length, equals(3));

      final president = users.firstWhere((u) => u['roleId'] == 'president');
      expect(president['email'], equals('president.dev@durgapuja.org'));
      expect((president['assignedEventIds'] as List).length, equals(3));

      final treasurer = users.firstWhere((u) => u['roleId'] == 'treasurer');
      expect(treasurer['email'], equals('treasurer.dev@durgapuja.org'));
      expect((treasurer['assignedEventIds'] as List).length, equals(3));

      final manager = users.firstWhere((u) => u['email'] == 'manager.dev@durgapuja.org');
      expect((manager['assignedEventIds'] as List), equals(['opera_jatra_2026']));

      final collector = users.firstWhere((u) => u['email'] == 'collector.dev@durgapuja.org');
      expect((collector['assignedEventIds'] as List), equals(['opera_jatra_2026']));

      final viewer = users.firstWhere((u) => u['email'] == 'viewer.dev@durgapuja.org');
      expect((viewer['assignedEventIds'] as List), equals(['bhasani_utsab_2026']));
    });

    test('DEV Chanda targets include all 23 Bhasani 2026 members and Opera target', () {
      final targets = DevBootstrapSeeder.devChandaTargets;
      expect(targets.length, equals(24));

      final pendingTarget = targets.firstWhere((t) => t['personName'] == 'Subhasish Bhola');
      expect(pendingTarget['targetAmount'], equals(10000));
      expect(pendingTarget['eventId'], equals('bhasani_utsab_2026'));

      final birenTarget = targets.firstWhere((t) => t['personName'] == 'BirenRaj Pradhan');
      expect(birenTarget['targetAmount'], equals(10000));
      expect(birenTarget['eventId'], equals('bhasani_utsab_2026'));

      final excessTarget = targets.firstWhere((t) => t['id'] == 'target_opera26_chandan');
      expect(excessTarget['targetAmount'], equals(5000));
      expect(excessTarget['eventId'], equals('opera_jatra_2026'));
      expect(excessTarget['status'], equals('PAID'));
    });

    test('DEV Collections contain multiple payment modes and statuses', () {
      final collections = DevBootstrapSeeder.devCollections;
      expect(collections.length, greaterThanOrEqualTo(5));

      final modes = collections.map((c) => c['paymentMode'] as String).toSet();
      expect(modes, containsAll(['cash', 'upi', 'bank_transfer', 'cheque']));

      final statuses = collections.map((c) => c['status'] as String).toSet();
      expect(statuses, containsAll(['APPROVED', 'PENDING', 'REJECTED']));

      final approvedCollections = collections.where((c) => c['status'] == 'APPROVED').toList();
      for (final col in approvedCollections) {
        expect(col['approvedBy'], isNotNull);
        expect(col['approvedAt'], isNotNull);
      }
    });

    test('DEV Expenses contain valid categories and statuses', () {
      final expenses = DevBootstrapSeeder.devExpenses;
      expect(expenses.length, greaterThanOrEqualTo(4));

      final categories = expenses.map((e) => e['categoryId'] as String).toSet();
      expect(categories, containsAll(['tent', 'puja_material', 'electricity', 'other']));

      final approvedExpenses = expenses.where((e) => e['status'] == 'APPROVED').toList();
      expect(approvedExpenses.length, equals(2));

      final pendingExpenses = expenses.where((e) => e['status'] == 'PENDING').toList();
      expect(pendingExpenses.length, equals(1));

      final rejectedExpenses = expenses.where((e) => e['status'] == 'REJECTED').toList();
      expect(rejectedExpenses.length, equals(1));
      expect(rejectedExpenses.first['rejectionReason'], isNotEmpty);
    });

    test('DEV Custody records cover cash handover, bank deposit, and pending states', () {
      final custody = DevBootstrapSeeder.devCustody;
      expect(custody.length, greaterThanOrEqualTo(3));

      final handover = custody.firstWhere((c) => c['id'] == 'custody_bhasani_handover_1');
      expect(handover['handoverType'], equals('CASH_HANDOVER'));
      expect(handover['status'], equals('RECEIVED'));
      expect(handover['amount'], equals(2000));
      expect(handover['receivedAt'], isNotNull);

      final bankDep = custody.firstWhere((c) => c['id'] == 'custody_bhasani_bank_dep_1');
      expect(bankDep['handoverType'], equals('BANK_DEPOSIT'));
      expect(bankDep['status'], equals('DEPOSITED'));
      expect(bankDep['amount'], equals(1500));

      final pending = custody.firstWhere((c) => c['id'] == 'custody_bhasani_pending_handover');
      expect(pending['status'], equals('PENDING'));
      expect(pending['amount'], equals(500));
    });

    test('DEV Expense Categories include all 11 default categories', () {
      final categories = ExpenseCategory.defaultCategories;
      expect(categories.length, equals(11));
    });
  });
}
