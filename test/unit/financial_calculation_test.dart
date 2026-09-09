import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/dashboard/domain/services/financial_calculation_service.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_entity.dart';

void main() {
  group('Financial Calculation Service Tests', () {
    final calcService = FinancialCalculationService();
    final now = DateTime.now();

    test('Collection = ₹100,000, Expense = ₹70,000 => Balance = ₹30,000', () {
      final collections = [
        CollectionEntity(
          id: 'c1',
          eventId: 'e1',
          donorName: 'Rahul',
          amount: 100000,
          paymentMode: PaymentMode.upi,
          purpose: 'Puja',
          collectedBy: 'u1',
          date: now,
          status: 'APPROVED',
          createdBy: 'u1',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final expenses = [
        ExpenseEntity(
          id: 'ex1',
          eventId: 'e1',
          categoryId: 'decoration',
          description: 'Decoration',
          amount: 70000,
          paidTo: 'Vendor A',
          paymentMode: PaymentMode.cash,
          date: now,
          status: 'APPROVED',
          addedBy: 'u2',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final summary = calcService.calculateSummary(
        eventId: 'e1',
        eventName: 'Durga Puja 2026',
        collections: collections,
        expenses: expenses,
      );

      expect(summary.totalApprovedCollection, 100000);
      expect(summary.totalApprovedExpense, 70000);
      expect(summary.currentBalance, 30000);
      expect(summary.isDeficit, isFalse);
    });

    test('Collection = ₹50,000, Expense = ₹70,000 => Deficit Balance = -₹20,000', () {
      final collections = [
        CollectionEntity(
          id: 'c1',
          eventId: 'e1',
          donorName: 'Amit',
          amount: 50000,
          paymentMode: PaymentMode.upi,
          purpose: 'Puja',
          collectedBy: 'u1',
          date: now,
          status: 'APPROVED',
          createdBy: 'u1',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final expenses = [
        ExpenseEntity(
          id: 'ex1',
          eventId: 'e1',
          categoryId: 'sound',
          description: 'Sound System',
          amount: 70000,
          paidTo: 'Vendor B',
          paymentMode: PaymentMode.upi,
          date: now,
          status: 'APPROVED',
          addedBy: 'u2',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final summary = calcService.calculateSummary(
        eventId: 'e1',
        eventName: 'Durga Puja 2026',
        collections: collections,
        expenses: expenses,
      );

      expect(summary.totalApprovedCollection, 50000);
      expect(summary.totalApprovedExpense, 70000);
      expect(summary.currentBalance, -20000);
      expect(summary.isDeficit, isTrue);
    });

    test('PENDING and REJECTED transactions do NOT affect official financial totals', () {
      final collections = [
        CollectionEntity(
          id: 'c1',
          eventId: 'e1',
          donorName: 'Rahul',
          amount: 10000,
          paymentMode: PaymentMode.cash,
          purpose: 'Puja',
          collectedBy: 'u1',
          date: now,
          status: 'APPROVED',
          createdBy: 'u1',
          createdAt: now,
          updatedAt: now,
        ),
        CollectionEntity(
          id: 'c2',
          eventId: 'e1',
          donorName: 'Pending Donor',
          amount: 50000,
          paymentMode: PaymentMode.cash,
          purpose: 'Puja',
          collectedBy: 'u1',
          date: now,
          status: 'PENDING',
          createdBy: 'u1',
          createdAt: now,
          updatedAt: now,
        ),
        CollectionEntity(
          id: 'c3',
          eventId: 'e1',
          donorName: 'Rejected Donor',
          amount: 25000,
          paymentMode: PaymentMode.cash,
          purpose: 'Puja',
          collectedBy: 'u1',
          date: now,
          status: 'REJECTED',
          createdBy: 'u1',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final summary = calcService.calculateSummary(
        eventId: 'e1',
        eventName: 'Durga Puja 2026',
        collections: collections,
        expenses: [],
      );

      expect(summary.totalApprovedCollection, 10000);
      expect(summary.pendingCollectionAmount, 50000);
      expect(summary.pendingCollectionCount, 1);
      expect(summary.rejectedCollectionCount, 1);
      expect(summary.currentBalance, 10000);
    });
  });
}
