import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/custody/domain/entities/collection_custody.dart';
import 'package:durgapuja_manager/features/custody/domain/entities/user_custody_balance.dart';
import 'package:durgapuja_manager/features/custody/presentation/providers/custody_provider.dart';

void main() {
  group('Collection Custody / Payment Handover Tests', () {
    final now = DateTime.now();

    test('Test 1 — Cash Only: Approved Cash Collection = ₹10,000 => Custody = ₹10,000', () {
      final balance = UserCustodyBalance(
        userId: 'uid_rashmi',
        userName: 'Rashmi',
        totalCollected: 10000,
        totalReceived: 0,
        totalHandedOver: 0,
        totalDeposited: 0,
      );

      expect(balance.currentCustody, 10000);
      expect(balance.hasActiveCustody, isTrue);
    });

    test('Test 2 — UPI Exclusion: Approved Cash = ₹10,000, Approved UPI = ₹5,000 => Custody Base = ₹10,000 (NOT ₹15,000)', () {
      final cashCol = CollectionEntity(
        id: 'c_cash',
        eventId: 'opera_2025',
        donorName: 'Donor Cash',
        amount: 10000,
        paymentMode: PaymentMode.cash,
        purpose: 'Puja Chanda',
        collectedBy: 'Rashmi',
        date: now,
        status: 'APPROVED',
        createdBy: 'uid_rashmi',
        createdAt: now,
        updatedAt: now,
      );

      final upiCol = CollectionEntity(
        id: 'c_upi',
        eventId: 'opera_2025',
        donorName: 'Donor UPI',
        amount: 5000,
        paymentMode: PaymentMode.upi,
        purpose: 'Puja Chanda',
        collectedBy: 'Rashmi',
        date: now,
        status: 'APPROVED',
        createdBy: 'uid_rashmi',
        createdAt: now,
        updatedAt: now,
      );

      final allApprovedCollections = [cashCol, upiCol];

      // Physical cash custody base calculation
      final physicalCashCustody = allApprovedCollections
          .where((c) => c.isApproved && c.paymentMode == PaymentMode.cash)
          .fold<int>(0, (sum, c) => sum + c.amount);

      expect(physicalCashCustody, 10000);
      expect(physicalCashCustody, isNot(15000));
    });

    test('Test 3 — Cash Handover: Collector ₹10,000, Handover ₹7,000 => PENDING => Receiver confirms => Collector ₹3,000, Receiver ₹7,000', () {
      // Step 1: Handover initiated -> status PENDING
      final pendingHandover = CollectionCustody(
        id: 'cust_01',
        eventId: 'opera_2025',
        eventType: 'OPERA_JATRA',
        eventYear: 2025,
        organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
        amount: 7000,
        fromUserId: 'uid_rashmi',
        fromUserName: 'Rashmi',
        toUserId: 'uid_titu',
        toUserName: 'Titu',
        handoverType: CollectionCustody.typeCashHandover,
        status: CollectionCustody.statusPending,
        handedOverAt: now,
        receivedAt: null,
        createdBy: 'uid_rashmi',
        createdAt: now,
      );

      expect(pendingHandover.isPending, isTrue);
      expect(pendingHandover.isReceived, isFalse);

      // Rashmi balance during pending state: current custody 10k, available for further handover is 3k
      final rashmiPendingBalance = UserCustodyBalance(
        userId: 'uid_rashmi',
        userName: 'Rashmi',
        totalCollected: 10000,
        totalReceived: 0,
        totalHandedOver: 0,
        totalDeposited: 0,
        pendingOutgoing: 7000,
      );

      expect(rashmiPendingBalance.currentCustody, 10000);
      expect(rashmiPendingBalance.availableForHandover, 3000);

      // Self-confirmation protection: Rashmi cannot confirm her own handover
      final currentUserId = 'uid_rashmi';
      final canRashmiConfirm = currentUserId == pendingHandover.toUserId;
      expect(canRashmiConfirm, isFalse);

      // Step 2: Titu confirms received
      final confirmedHandover = pendingHandover.copyWith(
        status: CollectionCustody.statusReceived,
        receivedAt: now,
      );

      expect(confirmedHandover.isReceived, isTrue);

      // Final balances after confirmation
      final rashmiFinalBalance = UserCustodyBalance(
        userId: 'uid_rashmi',
        userName: 'Rashmi',
        totalCollected: 10000,
        totalReceived: 0,
        totalHandedOver: 7000,
        totalDeposited: 0,
        pendingOutgoing: 0,
      );

      final tituFinalBalance = UserCustodyBalance(
        userId: 'uid_titu',
        userName: 'Titu',
        totalCollected: 0,
        totalReceived: 7000,
        totalHandedOver: 0,
        totalDeposited: 0,
        isTreasurer: true,
      );

      expect(rashmiFinalBalance.currentCustody, 3000);
      expect(tituFinalBalance.currentCustody, 7000);
    });

    test('Test 4 — Bank Deposit: Treasurer ₹7,000, Bank Deposit ₹7,000 => Treasurer ₹0, Bank Deposited ₹7,000', () {
      final tituBalance = UserCustodyBalance(
        userId: 'uid_titu',
        userName: 'Titu',
        totalCollected: 0,
        totalReceived: 7000,
        totalHandedOver: 0,
        totalDeposited: 7000,
        isTreasurer: true,
      );

      expect(tituBalance.currentCustody, 0);
      expect(tituBalance.totalDeposited, 7000);
      expect(tituBalance.hasActiveCustody, isFalse);
    });

    test('Test 5 — Excess Handover: Available Cash = ₹3,000, Attempt Handover = ₹5,000 => Rejected', () {
      final balance = UserCustodyBalance(
        userId: 'uid_rashmi',
        userName: 'Rashmi',
        totalCollected: 10000,
        totalReceived: 0,
        totalHandedOver: 7000,
        totalDeposited: 0,
      );

      expect(balance.availableForHandover, 3000);

      final attemptAmount = 5000;
      final isPermitted = attemptAmount <= balance.availableForHandover;

      expect(isPermitted, isFalse);
    });

    test('Test 6 — Reconciliation: Approved Cash ₹1,50,000 = Collectors ₹30,000 + Treasurer ₹20,000 + Bank ₹1,00,000 => MATCHED', () {
      const summary = CustodySummary(
        totalApprovedCashCollection: 150000,
        totalWithCollectors: 30000,
        totalWithTreasurer: 20000,
        totalDeposited: 100000,
        totalPendingHandovers: 0,
        pendingHandoversCount: 0,
      );

      expect(summary.reconciledTotal, 150000);
      expect(summary.reconciliationDifference, 0);
      expect(summary.isReconciled, isTrue);
    });

    test('Test 7 — Reconciliation Mismatch: Approved Cash ₹1,50,000 != ₹1,48,000 (Bank ₹98,000) => Difference = ₹2,000 unreconciled', () {
      const summary = CustodySummary(
        totalApprovedCashCollection: 150000,
        totalWithCollectors: 30000,
        totalWithTreasurer: 20000,
        totalDeposited: 98000,
        totalPendingHandovers: 0,
        pendingHandoversCount: 0,
      );

      expect(summary.reconciledTotal, 148000);
      expect(summary.reconciliationDifference, 2000);
      expect(summary.isReconciled, isFalse);
    });

    test('CollectionCustody entity properties and getters', () {
      final custody = CollectionCustody(
        id: 'cust_01',
        collectionId: 'col_01',
        eventId: 'opera_2025',
        eventType: 'OPERA_JATRA',
        eventYear: 2025,
        organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
        amount: 7000,
        fromUserId: 'uid_rashmi',
        fromUserName: 'Rashmi',
        toUserId: 'uid_titu',
        toUserName: 'Titu',
        handoverType: CollectionCustody.typeCashHandover,
        status: CollectionCustody.statusReceived,
        handedOverAt: now,
        receivedAt: now,
        notes: 'Evening handover',
        createdBy: 'uid_rashmi',
        createdAt: now,
      );

      expect(custody.isReceived, isTrue);
      expect(custody.isDeposited, isFalse);
      expect(custody.isBankDeposit, isFalse);

      final bankDeposit = custody.copyWith(
        handoverType: CollectionCustody.typeBankDeposit,
        status: CollectionCustody.statusDeposited,
        toUserId: 'BANK',
        toUserName: 'State Bank of India',
      );

      expect(bankDeposit.isBankDeposit, isTrue);
      expect(bankDeposit.isDeposited, isTrue);
    });
  });
}
