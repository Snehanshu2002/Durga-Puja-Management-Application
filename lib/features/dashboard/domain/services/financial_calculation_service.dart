import '../../../collection/domain/entities/collection_entity.dart';
import '../../../expense/domain/entities/expense_entity.dart';
import '../entities/financial_summary.dart';

class FinancialCalculationService {
  FinancialSummary calculateSummary({
    required String eventId,
    required String eventName,
    required List<CollectionEntity> collections,
    required List<ExpenseEntity> expenses,
  }) {
    int totalApprovedCollection = 0;
    int pendingCollectionAmount = 0;
    int approvedCollectionCount = 0;
    int pendingCollectionCount = 0;
    int rejectedCollectionCount = 0;
    final Set<String> donorNames = {};

    for (final col in collections) {
      if (col.status.toUpperCase() == 'APPROVED') {
        totalApprovedCollection += col.amount;
        approvedCollectionCount++;
        if (col.donorName.trim().isNotEmpty) {
          donorNames.add(col.donorName.trim().toLowerCase());
        }
      } else if (col.status.toUpperCase() == 'PENDING') {
        pendingCollectionAmount += col.amount;
        pendingCollectionCount++;
      } else if (col.status.toUpperCase() == 'REJECTED') {
        rejectedCollectionCount++;
      }
    }

    int totalApprovedExpense = 0;
    int pendingExpenseAmount = 0;
    int approvedExpenseCount = 0;
    int pendingExpenseCount = 0;
    int rejectedExpenseCount = 0;

    for (final exp in expenses) {
      if (exp.status.toUpperCase() == 'APPROVED') {
        totalApprovedExpense += exp.amount;
        approvedExpenseCount++;
      } else if (exp.status.toUpperCase() == 'PENDING') {
        pendingExpenseAmount += exp.amount;
        pendingExpenseCount++;
      } else if (exp.status.toUpperCase() == 'REJECTED') {
        rejectedExpenseCount++;
      }
    }

    final currentBalance = totalApprovedCollection - totalApprovedExpense;

    return FinancialSummary(
      eventId: eventId,
      eventName: eventName,
      totalApprovedCollection: totalApprovedCollection,
      totalApprovedExpense: totalApprovedExpense,
      currentBalance: currentBalance,
      pendingCollectionAmount: pendingCollectionAmount,
      pendingExpenseAmount: pendingExpenseAmount,
      approvedCollectionCount: approvedCollectionCount,
      approvedExpenseCount: approvedExpenseCount,
      pendingCollectionCount: pendingCollectionCount,
      pendingExpenseCount: pendingExpenseCount,
      rejectedCollectionCount: rejectedCollectionCount,
      rejectedExpenseCount: rejectedExpenseCount,
      totalDonorCount: donorNames.length,
    );
  }
}
