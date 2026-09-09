import 'package:durgapuja_manager/core/enums/payment_mode.dart';

class CategoryExpenseItem {
  final String categoryId;
  final String categoryName;
  final int totalAmount;
  final double percentage;

  const CategoryExpenseItem({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
  });
}

class PaymentModeBreakdownItem {
  final PaymentMode paymentMode;
  final int collectionAmount;
  final int expenseAmount;

  const PaymentModeBreakdownItem({
    required this.paymentMode,
    required this.collectionAmount,
    required this.expenseAmount,
  });
}

class DailyTrendItem {
  final DateTime date;
  final int collectionAmount;
  final int expenseAmount;

  const DailyTrendItem({
    required this.date,
    required this.collectionAmount,
    required this.expenseAmount,
  });
}

class AnalyticsData {
  final List<CategoryExpenseItem> categoryExpenses;
  final List<PaymentModeBreakdownItem> paymentModeBreakdown;
  final List<DailyTrendItem> dailyTrends;
  final int totalApprovedCollection;
  final int totalApprovedExpense;

  const AnalyticsData({
    required this.categoryExpenses,
    required this.paymentModeBreakdown,
    required this.dailyTrends,
    required this.totalApprovedCollection,
    required this.totalApprovedExpense,
  });
}
