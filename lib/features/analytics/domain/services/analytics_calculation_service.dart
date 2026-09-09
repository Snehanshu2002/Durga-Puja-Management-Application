import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_entity.dart';
import '../entities/analytics_data.dart';

class AnalyticsCalculationService {
  AnalyticsData calculateAnalytics({
    required List<CollectionEntity> collections,
    required List<ExpenseEntity> expenses,
  }) {
    // 1. Filter only APPROVED transactions
    final approvedCollections =
        collections.where((c) => c.status.toUpperCase() == 'APPROVED').toList();
    final approvedExpenses =
        expenses.where((e) => e.status.toUpperCase() == 'APPROVED').toList();

    int totalApprovedCollection = 0;
    for (final col in approvedCollections) {
      totalApprovedCollection += col.amount;
    }

    int totalApprovedExpense = 0;
    final Map<String, int> categoryTotals = {};
    for (final exp in approvedExpenses) {
      totalApprovedExpense += exp.amount;
      categoryTotals[exp.categoryId] =
          (categoryTotals[exp.categoryId] ?? 0) + exp.amount;
    }

    // Category breakdown items
    final List<CategoryExpenseItem> categoryItems = [];
    categoryTotals.forEach((catId, amount) {
      final percentage = totalApprovedExpense > 0
          ? (amount / totalApprovedExpense) * 100
          : 0.0;
      categoryItems.add(
        CategoryExpenseItem(
          categoryId: catId,
          categoryName: _formatCategoryName(catId),
          totalAmount: amount,
          percentage: percentage,
        ),
      );
    });

    categoryItems.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    // 2. Payment mode breakdown
    final Map<PaymentMode, int> collectionByMode = {};
    final Map<PaymentMode, int> expenseByMode = {};

    for (final col in approvedCollections) {
      collectionByMode[col.paymentMode] =
          (collectionByMode[col.paymentMode] ?? 0) + col.amount;
    }

    for (final exp in approvedExpenses) {
      expenseByMode[exp.paymentMode] =
          (expenseByMode[exp.paymentMode] ?? 0) + exp.amount;
    }

    final List<PaymentModeBreakdownItem> paymentModeItems = [];
    for (final mode in PaymentMode.values) {
      paymentModeItems.add(
        PaymentModeBreakdownItem(
          paymentMode: mode,
          collectionAmount: collectionByMode[mode] ?? 0,
          expenseAmount: expenseByMode[mode] ?? 0,
        ),
      );
    }

    // 3. Daily trends
    final Map<String, int> dailyCollection = {};
    final Map<String, int> dailyExpense = {};
    final Set<String> datesSet = {};

    for (final col in approvedCollections) {
      final dateKey = _formatDateKey(col.date);
      datesSet.add(dateKey);
      dailyCollection[dateKey] = (dailyCollection[dateKey] ?? 0) + col.amount;
    }

    for (final exp in approvedExpenses) {
      final dateKey = _formatDateKey(exp.date);
      datesSet.add(dateKey);
      dailyExpense[dateKey] = (dailyExpense[dateKey] ?? 0) + exp.amount;
    }

    final sortedDateKeys = datesSet.toList()..sort();

    final List<DailyTrendItem> dailyTrends = sortedDateKeys.map((dateKey) {
      final parts = dateKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return DailyTrendItem(
        date: date,
        collectionAmount: dailyCollection[dateKey] ?? 0,
        expenseAmount: dailyExpense[dateKey] ?? 0,
      );
    }).toList();

    return AnalyticsData(
      categoryExpenses: categoryItems,
      paymentModeBreakdown: paymentModeItems,
      dailyTrends: dailyTrends,
      totalApprovedCollection: totalApprovedCollection,
      totalApprovedExpense: totalApprovedExpense,
    );
  }

  String _formatCategoryName(String id) {
    return id
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String _formatDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
