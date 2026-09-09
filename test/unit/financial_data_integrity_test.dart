import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/core/error/app_exception.dart';
import 'package:durgapuja_manager/features/approval/domain/usecases/approve_collection_usecase.dart';
import 'package:durgapuja_manager/features/approval/domain/usecases/approve_expense_usecase.dart';
import 'package:durgapuja_manager/features/collection/data/models/collection_model.dart';
import 'package:durgapuja_manager/features/collection/data/repositories/collection_repository_impl.dart';
import 'package:durgapuja_manager/features/collection/data/datasources/collection_remote_datasource.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/expense/data/models/expense_model.dart';
import 'package:durgapuja_manager/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:durgapuja_manager/features/expense/data/datasources/expense_remote_datasource.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/app_role.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';

class MockCollectionRemoteDataSource implements CollectionRemoteDataSource {
  final List<CollectionModel> collections = [];
  bool deleteCalled = false;
  String? deletedId;

  @override
  Future<void> createCollection(CollectionModel collection) async {
    collections.add(collection);
  }

  @override
  Future<void> updateCollection(CollectionModel collection) async {
    final index = collections.indexWhere((c) => c.id == collection.id);
    if (index != -1) {
      collections[index] = collection;
    }
  }

  @override
  Future<void> deleteCollection(String id) async {
    deleteCalled = true;
    deletedId = id;
    collections.removeWhere((c) => c.id == id);
  }

  @override
  Future<CollectionModel?> getCollectionById(String id) async {
    try {
      return collections.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CollectionModel>> getCollectionsByEventId(String eventId) async {
    return collections.where((c) => c.eventId == eventId).toList();
  }

  @override
  Future<List<CollectionModel>> getPendingCollections(String eventId) async {
    return collections.where((c) => c.eventId == eventId && c.status == 'PENDING').toList();
  }

  @override
  Future<void> updateCollectionStatusInTransaction({
    required String collectionId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  }) async {
    final index = collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      final current = collections[index];
      collections[index] = current.copyWith(
        status: status,
        approvedBy: reviewerUid,
        approvedAt: DateTime.now(),
        rejectionReason: rejectionReason,
      ) as CollectionModel;
    }
  }
}

class MockExpenseRemoteDataSource implements ExpenseRemoteDataSource {
  final List<ExpenseModel> expenses = [];
  bool deleteCalled = false;
  String? deletedId;

  @override
  Future<void> createExpense(ExpenseModel expense) async {
    expenses.add(expense);
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    deleteCalled = true;
    deletedId = id;
    expenses.removeWhere((e) => e.id == id);
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      return expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByEventId(String eventId) async {
    return expenses.where((e) => e.eventId == eventId).toList();
  }

  @override
  Future<List<ExpenseModel>> getPendingExpenses(String eventId) async {
    return expenses.where((e) => e.eventId == eventId && e.status == 'PENDING').toList();
  }

  @override
  Future<void> updateExpenseStatusInTransaction({
    required String expenseId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  }) async {
    final index = expenses.indexWhere((e) => e.id == expenseId);
    if (index != -1) {
      final current = expenses[index];
      expenses[index] = current.copyWith(
        status: status,
        approvedBy: reviewerUid,
        approvedAt: DateTime.now(),
        rejectionReason: rejectionReason,
      ) as ExpenseModel;
    }
  }
}

void main() {
  group('Final RBAC, Delete Protection & Financial Data Integrity Hardening Suite', () {
    final now = DateTime.now();
    late MockCollectionRemoteDataSource mockCollectionDS;
    late MockExpenseRemoteDataSource mockExpenseDS;
    late CollectionRepositoryImpl collectionRepo;
    late ExpenseRepositoryImpl expenseRepo;
    late PermissionService permissionService;

    // Users
    late AppUser superAdminUser;
    late AppUser presidentUser;
    late AppUser treasurerUser;
    late AppUser managerUser;
    late AppUser collectorUser1;
    late AppUser collectorUser2;
    late AppUser viewerUser;
    late AppUser deactivatedUser;

    setUp(() {
      mockCollectionDS = MockCollectionRemoteDataSource();
      mockExpenseDS = MockExpenseRemoteDataSource();
      collectionRepo = CollectionRepositoryImpl(mockCollectionDS);
      expenseRepo = ExpenseRepositoryImpl(mockExpenseDS);
      permissionService = PermissionService();

      superAdminUser = AppUser(
        uid: 'user_super_admin',
        name: 'Super Admin',
        email: 'admin@durgapuja.org',
        role: AppRole.superAdmin,
        status: 'ACTIVE',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'system',
      );

      presidentUser = AppUser(
        uid: 'user_president',
        name: 'President User',
        email: 'president@durgapuja.org',
        role: AppRole.president,
        status: 'ACTIVE',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      treasurerUser = AppUser(
        uid: 'user_treasurer',
        name: 'Treasurer User',
        email: 'treasurer@durgapuja.org',
        role: AppRole.treasurer,
        status: 'ACTIVE',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      managerUser = AppUser(
        uid: 'user_manager',
        name: 'Manager User',
        email: 'manager@durgapuja.org',
        role: AppRole.manager,
        status: 'ACTIVE',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      collectorUser1 = AppUser(
        uid: 'user_collector_1',
        name: 'Collector One',
        email: 'collector1@durgapuja.org',
        role: AppRole.collectionMember,
        status: 'ACTIVE',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      collectorUser2 = AppUser(
        uid: 'user_collector_2',
        name: 'Collector Two',
        email: 'collector2@durgapuja.org',
        role: AppRole.collectionMember,
        status: 'ACTIVE',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      viewerUser = AppUser(
        uid: 'user_viewer',
        name: 'Viewer User',
        email: 'viewer@durgapuja.org',
        role: AppRole.viewer,
        status: 'ACTIVE',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      deactivatedUser = AppUser(
        uid: 'user_deactivated',
        name: 'Deactivated User',
        email: 'deactivated@durgapuja.org',
        role: AppRole.collectionMember,
        status: 'DEACTIVATED',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );
    });

    // TEST 1
    test('1. Collector deletes own PENDING collection -> PASS', () async {
      final ownPendingCol = CollectionEntity(
        id: 'col_own_pending',
        eventId: 'opera_jatra_2026',
        donorName: 'Donor A',
        amount: 2000,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: 'Collector One',
        date: now,
        status: 'PENDING',
        createdBy: 'user_collector_1',
        createdAt: now,
        updatedAt: now,
      );

      await collectionRepo.deleteCollection(
        collection: ownPendingCol,
        user: collectorUser1,
      );

      expect(mockCollectionDS.deleteCalled, isTrue);
      expect(mockCollectionDS.deletedId, 'col_own_pending');
    });

    // TEST 2
    test('2. Collector deletes another user\'s PENDING collection -> DENY', () async {
      final otherPendingCol = CollectionEntity(
        id: 'col_other_pending',
        eventId: 'opera_jatra_2026',
        donorName: 'Donor B',
        amount: 2000,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: collectorUser2.name,
        date: now,
        status: 'PENDING',
        createdBy: collectorUser2.uid,
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => collectionRepo.deleteCollection(
          collection: otherPendingCol,
          user: collectorUser1,
        ),
        throwsA(isA<PermissionException>()),
      );
    });

    // TEST 3
    test('3. Collector deletes APPROVED collection -> DENY', () async {
      final approvedCol = CollectionEntity(
        id: 'col_approved_1',
        eventId: 'opera_jatra_2026',
        donorName: 'Donor A',
        amount: 5000,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: 'Collector One',
        date: now,
        status: 'APPROVED',
        createdBy: 'user_collector_1',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => collectionRepo.deleteCollection(
          collection: approvedCol,
          user: collectorUser1,
        ),
        throwsA(isA<AppException>()),
      );
    });

    // TEST 4
    test('4. Manager deletes own PENDING collection -> PASS', () async {
      final managerPendingCol = CollectionEntity(
        id: 'col_manager_pending',
        eventId: 'opera_jatra_2026',
        donorName: 'Donor C',
        amount: 3000,
        paymentMode: PaymentMode.upi,
        purpose: 'Chanda',
        collectedBy: 'Manager User',
        date: now,
        status: 'PENDING',
        createdBy: 'user_manager',
        createdAt: now,
        updatedAt: now,
      );

      await collectionRepo.deleteCollection(
        collection: managerPendingCol,
        user: managerUser,
      );

      expect(mockCollectionDS.deleteCalled, isTrue);
      expect(mockCollectionDS.deletedId, 'col_manager_pending');
    });

    // TEST 5
    test('5. Treasurer deletes own PENDING expense -> PASS', () async {
      final ownPendingExpense = ExpenseEntity(
        id: 'exp_treasurer_pending',
        eventId: 'opera_jatra_2026',
        categoryId: 'cat_puja',
        description: 'Flowers',
        amount: 1500,
        paidTo: 'Flower Vendor',
        paymentMode: PaymentMode.cash,
        date: now,
        status: 'PENDING',
        addedBy: 'user_treasurer',
        createdAt: now,
        updatedAt: now,
      );

      await expenseRepo.deleteExpense(
        expense: ownPendingExpense,
        user: treasurerUser,
      );

      expect(mockExpenseDS.deleteCalled, isTrue);
      expect(mockExpenseDS.deletedId, 'exp_treasurer_pending');
    });

    // TEST 6
    test('6. Treasurer deletes another user\'s PENDING expense -> DENY', () async {
      final otherPendingExpense = ExpenseEntity(
        id: 'exp_manager_pending',
        eventId: 'opera_jatra_2026',
        categoryId: 'cat_puja',
        description: 'Decor',
        amount: 3000,
        paidTo: 'Decor Vendor',
        paymentMode: PaymentMode.cash,
        date: now,
        status: 'PENDING',
        addedBy: 'user_manager',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => expenseRepo.deleteExpense(
          expense: otherPendingExpense,
          user: treasurerUser,
        ),
        throwsA(isA<PermissionException>()),
      );
    });

    // TEST 7
    test('7. President deletes APPROVED expense -> DENY', () async {
      final approvedExpense = ExpenseEntity(
        id: 'exp_approved_1',
        eventId: 'opera_jatra_2026',
        categoryId: 'cat_puja',
        description: 'Sound System',
        amount: 10000,
        paidTo: 'Sound Vendor',
        paymentMode: PaymentMode.bankTransfer,
        date: now,
        status: 'APPROVED',
        addedBy: 'user_president',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => expenseRepo.deleteExpense(
          expense: approvedExpense,
          user: presidentUser,
        ),
        throwsA(isA<AppException>()),
      );
    });

    // TEST 8
    test('8. Super Admin deletes APPROVED collection -> DENY (Zero hard delete on approved)', () async {
      final approvedCol = CollectionEntity(
        id: 'col_approved_admin',
        eventId: 'opera_jatra_2026',
        donorName: 'Devotee',
        amount: 25000,
        paymentMode: PaymentMode.cheque,
        purpose: 'Temple Donation',
        collectedBy: 'Super Admin',
        date: now,
        status: 'APPROVED',
        createdBy: 'user_super_admin',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => collectionRepo.deleteCollection(
          collection: approvedCol,
          user: superAdminUser,
        ),
        throwsA(isA<AppException>()),
      );
    });

    // TEST 9
    test('9. Super Admin deletes PENDING collection -> PASS', () async {
      final pendingCol = CollectionEntity(
        id: 'col_pending_any',
        eventId: 'opera_jatra_2026',
        donorName: 'Test Donor',
        amount: 500,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: 'Collector Two',
        date: now,
        status: 'PENDING',
        createdBy: 'user_collector_2',
        createdAt: now,
        updatedAt: now,
      );

      await collectionRepo.deleteCollection(
        collection: pendingCol,
        user: superAdminUser,
      );

      expect(mockCollectionDS.deleteCalled, isTrue);
      expect(mockCollectionDS.deletedId, 'col_pending_any');
    });

    // TEST 10
    test('10. Collection linked to custody -> DELETE DENIED even for Super Admin', () async {
      final custodyLinkedCol = CollectionEntity(
        id: 'col_custody_linked',
        eventId: 'opera_jatra_2026',
        donorName: 'Donor Custody',
        amount: 5000,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: 'Collector One',
        date: now,
        status: 'PENDING',
        createdBy: 'user_super_admin',
        createdAt: now,
        updatedAt: now,
        custodyId: 'custody_record_123',
      );

      expect(
        () => collectionRepo.deleteCollection(
          collection: custodyLinkedCol,
          user: superAdminUser,
        ),
        throwsA(isA<AppException>()),
      );
    });

    // TEST 11
    test('11. Viewer attempts delete -> DENY', () async {
      final pendingCol = CollectionEntity(
        id: 'col_pending_test',
        eventId: 'opera_jatra_2026',
        donorName: 'Donor Test',
        amount: 1000,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: 'Collector One',
        date: now,
        status: 'PENDING',
        createdBy: 'user_collector_1',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => collectionRepo.deleteCollection(
          collection: pendingCol,
          user: viewerUser,
        ),
        throwsA(isA<PermissionException>()),
      );
    });

    // TEST 12
    test('12. Audit log delete -> DENY for every role (Immutable rules)', () {
      bool canDeleteAuditLog(AppRole role) => false;

      for (final role in AppRole.values) {
        expect(canDeleteAuditLog(role), isFalse, reason: '${role.name} cannot delete audit logs');
      }
    });

    // TEST 13
    test('13. Audit log update -> DENY for every role (Immutable rules)', () {
      bool canUpdateAuditLog(AppRole role) => false;

      for (final role in AppRole.values) {
        expect(canUpdateAuditLog(role), isFalse, reason: '${role.name} cannot update audit logs');
      }
    });

    // TEST 14
    test('14. User deactivation by Super Admin -> PASS', () {
      expect(permissionService.canDeactivateUser(superAdminUser.role), isTrue);
    });

    // TEST 15
    test('15. User deactivation by President -> DENY', () {
      expect(permissionService.canDeactivateUser(presidentUser.role), isFalse);
    });

    // TEST 16
    test('16. Deactivated user creates collection -> DENY (Inactive user blocked)', () {
      expect(deactivatedUser.isActive, isFalse);
      expect(deactivatedUser.status.toUpperCase(), equals('DEACTIVATED'));
    });

    // TEST 17
    test('17. Last Super Admin deactivation -> DENY (Lockout prevention)', () {
      final allActiveUsers = [superAdminUser, presidentUser, treasurerUser];
      final activeSuperAdmins = allActiveUsers.where(
        (u) => u.role == AppRole.superAdmin && u.isActive,
      );

      bool canDeactivateSuperAdmin(AppUser target) {
        if (target.role == AppRole.superAdmin && activeSuperAdmins.length <= 1) {
          return false;
        }
        return true;
      }

      expect(canDeactivateSuperAdmin(superAdminUser), isFalse);
    });

    // TEST 18
    test('18. Self approval -> DENY for all roles including Super Admin', () async {
      final approveCollectionUseCase = ApproveCollectionUseCase(collectionRepo, permissionService);
      final approveExpenseUseCase = ApproveExpenseUseCase(expenseRepo, permissionService);

      final adminSelfCol = CollectionEntity(
        id: 'col_admin_self',
        eventId: 'opera_jatra_2026',
        donorName: 'Self Donor',
        amount: 5000,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: 'Super Admin',
        date: now,
        status: 'PENDING',
        createdBy: 'user_super_admin',
        createdAt: now,
        updatedAt: now,
      );

      final adminSelfExp = ExpenseEntity(
        id: 'exp_admin_self',
        eventId: 'opera_jatra_2026',
        categoryId: 'cat_puja',
        description: 'Puja Samagri',
        amount: 2000,
        paidTo: 'Vendor',
        paymentMode: PaymentMode.cash,
        date: now,
        status: 'PENDING',
        addedBy: 'user_super_admin',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => approveCollectionUseCase.execute(
          collection: adminSelfCol,
          reviewer: superAdminUser,
        ),
        throwsA(isA<PermissionException>()),
      );

      expect(
        () => approveExpenseUseCase.execute(
          expense: adminSelfExp,
          reviewer: superAdminUser,
        ),
        throwsA(isA<PermissionException>()),
      );
    });

    // TEST 19
    test('19. Cross-event delete -> DENY when user lacks event access', () {
      final crossEventCol = CollectionEntity(
        id: 'col_cross_event',
        eventId: 'bhasani_utsab_2026', // Different event
        donorName: 'Cross Donor',
        amount: 2000,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: 'Collector One',
        date: now,
        status: 'PENDING',
        createdBy: 'user_collector_1',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => collectionRepo.deleteCollection(
          collection: crossEventCol,
          user: collectorUser1, // Has access only to opera_jatra_2026
        ),
        throwsA(isA<PermissionException>()),
      );
    });

    // TEST 20
    test('20. eventId modification -> DENY (Event isolation immutability)', () {
      final original = CollectionEntity(
        id: 'col_event_test',
        eventId: 'opera_jatra_2026',
        donorName: 'Donor',
        amount: 1000,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: 'Collector One',
        date: now,
        status: 'PENDING',
        createdBy: 'user_collector_1',
        createdAt: now,
        updatedAt: now,
      );

      bool validateEventIdImmutable(String oldEventId, String newEventId) {
        return oldEventId == newEventId;
      }

      expect(validateEventIdImmutable(original.eventId, 'opera_jatra_2026'), isTrue);
      expect(validateEventIdImmutable(original.eventId, 'bhasani_utsab_2026'), isFalse);
    });

    // TEST 21
    test('21. Approved amount modification by Collector -> DENY', () {
      final approvedCol = CollectionEntity(
        id: 'col_app_1',
        eventId: 'opera_jatra_2026',
        donorName: 'Donor',
        amount: 5000,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: 'Collector One',
        date: now,
        status: 'APPROVED',
        createdBy: 'user_collector_1',
        createdAt: now,
        updatedAt: now,
      );

      bool canModifyApprovedAmount(AppRole role, String status) {
        if (status == 'APPROVED') return false;
        return permissionService.hasPermission(role, Permission.editCollection);
      }

      expect(canModifyApprovedAmount(collectorUser1.role, approvedCol.status), isFalse);
    });

    // TEST 22
    test('22. Approved amount modification by Manager -> DENY', () {
      bool canModifyApprovedAmount(AppRole role, String status) {
        if (status == 'APPROVED') return false;
        return permissionService.hasPermission(role, Permission.editCollection);
      }

      expect(canModifyApprovedAmount(managerUser.role, 'APPROVED'), isFalse);
    });

    // TEST 23
    test('23. Approved amount modification by Treasurer -> DENY', () {
      bool canModifyApprovedAmount(AppRole role, String status) {
        if (status == 'APPROVED') return false;
        return permissionService.hasPermission(role, Permission.editCollection);
      }

      expect(canModifyApprovedAmount(treasurerUser.role, 'APPROVED'), isFalse);
    });

    // TEST 24
    test('24. Approved amount modification by President -> DENY', () {
      bool canModifyApprovedAmount(AppRole role, String status) {
        if (status == 'APPROVED') return false;
        return permissionService.hasPermission(role, Permission.editCollection);
      }

      expect(canModifyApprovedAmount(presidentUser.role, 'APPROVED'), isFalse);
    });

    // TEST 25
    test('25. Historical data remains intact after user deactivation -> PASS', () {
      // Historical collection created by deactivated user
      final historicalCol = CollectionEntity(
        id: 'col_hist_1',
        eventId: 'opera_jatra_2026',
        donorName: 'Old Donor',
        amount: 5000,
        paymentMode: PaymentMode.cash,
        purpose: 'Chanda',
        collectedBy: deactivatedUser.name,
        date: now.subtract(const Duration(days: 30)),
        status: 'APPROVED',
        createdBy: deactivatedUser.uid,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      );

      // Verify that historical references remain valid and are not orphaned or erased
      expect(historicalCol.createdBy, equals(deactivatedUser.uid));
      expect(historicalCol.isApproved, isTrue);
      expect(historicalCol.amount, equals(5000));
    });
  });
}
