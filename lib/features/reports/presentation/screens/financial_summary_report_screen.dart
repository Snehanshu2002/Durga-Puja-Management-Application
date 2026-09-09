import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/features/dashboard/presentation/providers/dashboard_provider.dart';

class FinancialSummaryReportScreen extends ConsumerWidget {
  const FinancialSummaryReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Summary'),
      ),
      body: dashboardAsync.when(
        data: (summary) {
          if (summary == null) {
            return const Center(child: Text('No active event selected.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.eventName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildItemRow(
                          'Total Approved Collection',
                          MoneyFormatter.format(summary.totalApprovedCollection),
                          color: Colors.green,
                        ),
                        _buildItemRow(
                          'Total Approved Expense',
                          MoneyFormatter.format(summary.totalApprovedExpense),
                          color: Colors.red,
                        ),
                        const Divider(height: 24),
                        _buildItemRow(
                          'Net Balance',
                          MoneyFormatter.format(summary.currentBalance),
                          color: summary.isDeficit ? Colors.red : Colors.blue,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending & Excluded Transactions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildItemRow(
                          'Pending Collection',
                          '${MoneyFormatter.format(summary.pendingCollectionAmount)} (${summary.pendingCollectionCount} entries)',
                        ),
                        _buildItemRow(
                          'Pending Expense',
                          '${MoneyFormatter.format(summary.pendingExpenseAmount)} (${summary.pendingExpenseCount} entries)',
                        ),
                        _buildItemRow(
                          'Rejected Collections',
                          '${summary.rejectedCollectionCount} entries',
                        ),
                        _buildItemRow(
                          'Rejected Expenses',
                          '${summary.rejectedExpenseCount} entries',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingView(message: 'Generating summary...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
      ),
    );
  }

  Widget _buildItemRow(String title, String value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
