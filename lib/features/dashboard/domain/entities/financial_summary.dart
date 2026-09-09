class FinancialSummary {
  final String eventId;
  final String eventName;
  final int totalApprovedCollection;
  final int totalApprovedExpense;
  final int currentBalance;
  final int pendingCollectionAmount;
  final int pendingExpenseAmount;
  final int approvedCollectionCount;
  final int approvedExpenseCount;
  final int pendingCollectionCount;
  final int pendingExpenseCount;
  final int rejectedCollectionCount;
  final int rejectedExpenseCount;
  final int totalDonorCount;

  const FinancialSummary({
    required this.eventId,
    required this.eventName,
    required this.totalApprovedCollection,
    required this.totalApprovedExpense,
    required this.currentBalance,
    required this.pendingCollectionAmount,
    required this.pendingExpenseAmount,
    required this.approvedCollectionCount,
    required this.approvedExpenseCount,
    required this.pendingCollectionCount,
    required this.pendingExpenseCount,
    required this.rejectedCollectionCount,
    required this.rejectedExpenseCount,
    required this.totalDonorCount,
  });

  bool get isDeficit => currentBalance < 0;

  double get averageDonation {
    if (approvedCollectionCount == 0) return 0.0;
    return totalApprovedCollection / approvedCollectionCount;
  }
}
