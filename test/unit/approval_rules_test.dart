import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/core/error/app_exception.dart';
import 'package:durgapuja_manager/features/approval/domain/usecases/approve_collection_usecase.dart';
import 'package:durgapuja_manager/features/approval/domain/usecases/reject_collection_usecase.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/collection/domain/repositories/collection_repository.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/app_role.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';

class MockCollectionRepository implements CollectionRepository {
  CollectionEntity? updatedCollection;
  String? updatedStatus;
  String? updatedReviewerUid;
  String? updatedRejectionReason;

  @override
  Future<void> createCollection(CollectionEntity collection) async {}

  @override
  Future<void> updateCollection(CollectionEntity collection) async {
    updatedCollection = collection;
  }

  @override
  Future<CollectionEntity?> getCollectionById(String id) async => null;

  @override
  Future<List<CollectionEntity>> getCollectionsByEventId(String eventId) async => [];

  @override
  Future<List<CollectionEntity>> getPendingCollections(String eventId) async => [];

  @override
  Future<void> deleteCollection({
    required CollectionEntity collection,
    required AppUser user,
  }) async {}

  @override
  Future<void> updateCollectionStatus({
    required String collectionId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  }) async {
    updatedStatus = status;
    updatedReviewerUid = reviewerUid;
    updatedRejectionReason = rejectionReason;
  }
}

void main() {
  group('Approval Rules Tests', () {
    late MockCollectionRepository mockRepo;
    late PermissionService permissionService;
    late ApproveCollectionUseCase approveUseCase;
    late RejectCollectionUseCase rejectUseCase;
    final now = DateTime.now();

    late CollectionEntity pendingCollection;
    late AppUser treasurerUser;
    late AppUser collectionMemberUser;

    setUp(() {
      mockRepo = MockCollectionRepository();
      permissionService = PermissionService();
      approveUseCase = ApproveCollectionUseCase(mockRepo, permissionService);
      rejectUseCase = RejectCollectionUseCase(mockRepo, permissionService);

      pendingCollection = CollectionEntity(
        id: 'col_123',
        eventId: 'e1',
        donorName: 'Rahul',
        amount: 5000,
        paymentMode: PaymentMode.upi,
        purpose: 'Donation',
        collectedBy: 'user_titu',
        date: now,
        status: 'PENDING',
        createdBy: 'user_titu',
        createdAt: now,
        updatedAt: now,
      );

      treasurerUser = AppUser(
        uid: 'user_treasurer',
        name: 'Treasurer User',
        email: 'treasurer@test.org',
        role: AppRole.treasurer,
        status: 'ACTIVE',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      collectionMemberUser = AppUser(
        uid: 'user_titu',
        name: 'Titu',
        email: 'titu@test.org',
        role: AppRole.collectionMember,
        status: 'ACTIVE',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );
    });

    test('Authorized Treasurer can approve collection', () async {
      await approveUseCase.execute(
        collection: pendingCollection,
        reviewer: treasurerUser,
      );

      expect(mockRepo.updatedStatus, 'APPROVED');
      expect(mockRepo.updatedReviewerUid, 'user_treasurer');
    });

    test('User without approveCollection permission throws PermissionException', () async {
      expect(
        () async => await approveUseCase.execute(
          collection: pendingCollection,
          reviewer: collectionMemberUser,
        ),
        throwsA(isA<PermissionException>()),
      );
    });

    test('Self-approval restriction prevents user from approving their own transaction', () async {
      final treasurerSelfEntry = pendingCollection.copyWith(createdBy: 'user_treasurer');

      expect(
        () async => await approveUseCase.execute(
          collection: treasurerSelfEntry,
          reviewer: treasurerUser,
        ),
        throwsA(isA<PermissionException>()),
      );
    });

    test('Rejection requires a non-empty rejection reason', () async {
      expect(
        () async => await rejectUseCase.execute(
          collection: pendingCollection,
          reviewer: treasurerUser,
          rejectionReason: '   ',
        ),
        throwsA(isA<AppException>()),
      );
    });
  });
}
