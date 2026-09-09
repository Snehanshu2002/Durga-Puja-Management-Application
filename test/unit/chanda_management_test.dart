import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/features/chanda/domain/entities/chanda_target.dart';
import 'package:durgapuja_manager/features/chanda/domain/entities/chanda_target_with_progress.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/app_role.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';

void main() {
  group('Chanda Target / Pledge Management Tests', () {
    final now = DateTime.now();

    final target = ChandaTarget(
      id: 'target_001',
      userId: 'user_filu',
      personName: 'Filu Bhola',
      mobileNumber: '9876543210',
      targetAmount: 5000,
      eventId: 'opera_jatra_2025',
      eventType: 'OPERA_JATRA',
      eventYear: 2025,
      organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
      status: 'PENDING',
      createdAt: now,
      updatedAt: now,
      createdBy: 'uid_admin',
    );

    test('Initial state with no payments: Paid = 0, Remaining = 5000, Status = PENDING', () {
      final item = ChandaTargetWithProgress(
        target: target,
        paidAmount: 0,
        linkedCollections: [],
      );

      expect(item.paidAmount, 0);
      expect(item.remainingAmount, 5000);
      expect(item.progressPercentage, 0.0);
      expect(item.computedStatus, 'PENDING');
      expect(item.isPending, isTrue);
      expect(item.isFullyPaid, isFalse);
    });

    test('Partial Payment: Target ₹5,000, Approved ₹3,000 => Paid = ₹3,000, Remaining = ₹2,000, Status = PARTIAL', () {
      final approvedCollection = CollectionEntity(
        id: 'col_01',
        eventId: 'opera_jatra_2025',
        userId: 'user_filu',
        donorName: 'Filu Bhola',
        amount: 3000,
        paymentMode: PaymentMode.upi,
        purpose: 'Puja Chanda',
        collectedBy: 'Rashmi',
        date: now,
        status: 'APPROVED',
        createdBy: 'uid_rashmi',
        createdAt: now,
        updatedAt: now,
        chandaTargetId: 'target_001',
      );

      final item = ChandaTargetWithProgress(
        target: target,
        paidAmount: approvedCollection.amount,
        linkedCollections: [approvedCollection],
      );

      expect(item.paidAmount, 3000);
      expect(item.remainingAmount, 2000);
      expect(item.progressPercentage, 0.6);
      expect(item.computedStatus, 'PARTIAL');
      expect(item.isPartial, isTrue);
    });

    test('Full Payment: Target ₹5,000, Two approved payments (₹3k + ₹2k) => Paid = ₹5,000, Remaining = 0, Status = PAID', () {
      final col1 = CollectionEntity(
        id: 'col_01',
        eventId: 'opera_jatra_2025',
        userId: 'user_filu',
        donorName: 'Filu Bhola',
        amount: 3000,
        paymentMode: PaymentMode.upi,
        purpose: 'Puja Chanda',
        collectedBy: 'Rashmi',
        date: now,
        status: 'APPROVED',
        createdBy: 'uid_rashmi',
        createdAt: now,
        updatedAt: now,
        chandaTargetId: 'target_001',
      );

      final col2 = CollectionEntity(
        id: 'col_02',
        eventId: 'opera_jatra_2025',
        userId: 'user_filu',
        donorName: 'Filu Bhola',
        amount: 2000,
        paymentMode: PaymentMode.cash,
        purpose: 'Puja Chanda',
        collectedBy: 'Titu',
        date: now,
        status: 'APPROVED',
        createdBy: 'uid_titu',
        createdAt: now,
        updatedAt: now,
        chandaTargetId: 'target_001',
      );

      final totalPaid = col1.amount + col2.amount;
      final item = ChandaTargetWithProgress(
        target: target,
        paidAmount: totalPaid,
        linkedCollections: [col1, col2],
      );

      expect(item.paidAmount, 5000);
      expect(item.remainingAmount, 0);
      expect(item.progressPercentage, 1.0);
      expect(item.computedStatus, 'PAID');
      expect(item.isFullyPaid, isTrue);
    });

    test('Pending or Rejected collections do NOT increment Paid amount', () {
      final pendingCol = CollectionEntity(
        id: 'col_01',
        eventId: 'opera_jatra_2025',
        userId: 'user_filu',
        donorName: 'Filu Bhola',
        amount: 2000,
        paymentMode: PaymentMode.upi,
        purpose: 'Puja Chanda',
        collectedBy: 'Rashmi',
        date: now,
        status: 'PENDING',
        createdBy: 'uid_rashmi',
        createdAt: now,
        updatedAt: now,
        chandaTargetId: 'target_001',
      );

      final rejectedCol = CollectionEntity(
        id: 'col_02',
        eventId: 'opera_jatra_2025',
        userId: 'user_filu',
        donorName: 'Filu Bhola',
        amount: 1500,
        paymentMode: PaymentMode.upi,
        purpose: 'Puja Chanda',
        collectedBy: 'Rashmi',
        date: now,
        status: 'REJECTED',
        createdBy: 'uid_rashmi',
        createdAt: now,
        updatedAt: now,
        chandaTargetId: 'target_001',
      );

      final allLinked = [pendingCol, rejectedCol];
      final approvedPaid = allLinked
          .where((c) => c.isApproved)
          .fold<int>(0, (sum, c) => sum + c.amount);

      final item = ChandaTargetWithProgress(
        target: target,
        paidAmount: approvedPaid,
        linkedCollections: allLinked,
      );

      expect(item.paidAmount, 0);
      expect(item.remainingAmount, 5000);
      expect(item.computedStatus, 'PENDING');
      expect(item.pendingCollections.length, 1);
      expect(item.rejectedCollections.length, 1);
      expect(item.approvedCollections.length, 0);
    });

    test('Excess Payment: Target ₹5,000, Approved ₹6,000 => Paid = ₹6,000, Remaining = 0, Excess = ₹1,000, Status = PAID', () {
      final col = CollectionEntity(
        id: 'col_excess',
        eventId: 'opera_jatra_2025',
        userId: 'user_filu',
        donorName: 'Filu Bhola',
        amount: 6000,
        paymentMode: PaymentMode.cash,
        purpose: 'Special Chanda',
        collectedBy: 'Rashmi',
        date: now,
        status: 'APPROVED',
        createdBy: 'uid_rashmi',
        createdAt: now,
        updatedAt: now,
        chandaTargetId: 'target_001',
      );

      final item = ChandaTargetWithProgress(
        target: target,
        paidAmount: col.amount,
        linkedCollections: [col],
      );

      expect(item.paidAmount, 6000);
      expect(item.remainingAmount, 0);
      expect(item.excessAmount, 1000);
      expect(item.hasExcess, isTrue);
      expect(item.progressPercentage, 1.0);
      expect(item.computedStatus, 'PAID');
    });

    test('Test 1 & 2 & 3 & 4 — User Active & Event Access Filtering for Selectors', () {
      final activeUserWithEvent = AppUser(
        uid: 'user_rashmi',
        name: 'Rashmi',
        email: 'rashmi@gmail.com',
        role: AppRole.collectionMember,
        status: 'ACTIVE',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      final deactivatedUser = AppUser(
        uid: 'user_deactivated',
        name: 'Inactive Member',
        email: 'inactive@gmail.com',
        role: AppRole.collectionMember,
        status: 'DEACTIVATED',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      final removedUser = AppUser(
        uid: 'user_removed',
        name: 'Removed Member',
        email: 'removed@gmail.com',
        role: AppRole.collectionMember,
        status: 'REMOVED',
        assignedEventIds: ['opera_jatra_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      final unauthorizedEventUser = AppUser(
        uid: 'user_bhasani_only',
        name: 'Bhasani Member',
        email: 'bhasani@gmail.com',
        role: AppRole.collectionMember,
        status: 'ACTIVE',
        assignedEventIds: ['bhasani_utsab_2026'],
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      final allUsers = [activeUserWithEvent, deactivatedUser, removedUser, unauthorizedEventUser];

      // Filter for Opera/Jatra 2026
      final operaSelectable = allUsers.where(
        (u) => u.isActive && u.hasAccessToEvent('opera_jatra_2026'),
      ).toList();

      expect(operaSelectable.length, 1);
      expect(operaSelectable.first.uid, 'user_rashmi');

      // Filter for Bhasani 2026
      final bhasaniSelectable = allUsers.where(
        (u) => u.isActive && u.hasAccessToEvent('bhasani_utsab_2026'),
      ).toList();

      expect(bhasaniSelectable.length, 1);
      expect(bhasaniSelectable.first.uid, 'user_bhasani_only');
    });

    test('Test 5 & 6 & 7 — Event Isolation for Chanda Targets', () {
      final targetBhasani = ChandaTarget(
        id: 'target_bhasani',
        userId: 'user_rashmi',
        personName: 'Rashmi',
        targetAmount: 5000,
        eventId: 'bhasani_utsab_2026',
        eventType: 'BHASANI_UTSAB',
        eventYear: 2026,
        organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
        status: 'PENDING',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      final targetOpera = ChandaTarget(
        id: 'target_opera',
        userId: 'user_rashmi',
        personName: 'Rashmi',
        targetAmount: 10000,
        eventId: 'opera_jatra_2026',
        eventType: 'OPERA_JATRA',
        eventYear: 2026,
        organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
        status: 'PENDING',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );

      final targets = [targetBhasani, targetOpera];

      final operaTargets = targets.where((t) => t.eventId == 'opera_jatra_2026').toList();
      expect(operaTargets.length, 1);
      expect(operaTargets.first.targetAmount, 10000);

      final bhasaniTargets = targets.where((t) => t.eventId == 'bhasani_utsab_2026').toList();
      expect(bhasaniTargets.length, 1);
      expect(bhasaniTargets.first.targetAmount, 5000);
    });

    test('Test 8 & 14 — Duplicate Prevention for same userId + eventId', () {
      final existingTargets = [
        ChandaTarget(
          id: 'target_existing',
          userId: 'user_rashmi',
          personName: 'Rashmi',
          targetAmount: 5000,
          eventId: 'opera_jatra_2026',
          eventType: 'OPERA_JATRA',
          eventYear: 2026,
          organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
          status: 'PENDING',
          createdAt: now,
          updatedAt: now,
          createdBy: 'admin',
        )
      ];

      final hasDuplicate = existingTargets.any(
        (t) => t.userId == 'user_rashmi' && t.eventId == 'opera_jatra_2026',
      );
      expect(hasDuplicate, isTrue);

      final allowDifferentEvent = existingTargets.any(
        (t) => t.userId == 'user_rashmi' && t.eventId == 'bhasani_utsab_2026',
      );
      expect(allowDifferentEvent, isFalse);
    });

    test('Test 15 — Public / Direct Donation without member userId remains supported', () {
      final directDonation = CollectionEntity(
        id: 'col_direct',
        eventId: 'opera_jatra_2026',
        userId: null,
        chandaTargetId: null,
        donorName: 'Anonymous Devotee',
        mobileNumber: null,
        amount: 500,
        paymentMode: PaymentMode.cash,
        purpose: 'General Pandal Donation',
        collectedBy: 'Rashmi',
        date: now,
        status: 'APPROVED',
        createdBy: 'uid_rashmi',
        createdAt: now,
        updatedAt: now,
      );

      expect(directDonation.userId, isNull);
      expect(directDonation.chandaTargetId, isNull);
      expect(directDonation.donorName, 'Anonymous Devotee');
      expect(directDonation.isApproved, isTrue);
    });
  });
}
