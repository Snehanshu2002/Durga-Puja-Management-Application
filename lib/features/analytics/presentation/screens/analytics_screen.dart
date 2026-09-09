import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/widgets/event_selector.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analytics'),
        actions: const [
          EventSelector(),
          SizedBox(width: 8),
        ],
      ),
      body: analyticsAsync.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text('No active event selected.'));
          }

          final dateFormat = DateFormat('dd MMM');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Breakdown Card
                Text(
                  'Expense Category Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: data.categoryExpenses.isEmpty
                        ? const Center(
                            child: Text('No approved expenses recorded.'))
                        : Column(
                            children: data.categoryExpenses.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.categoryName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${MoneyFormatter.format(item.totalAmount)} (${item.percentage.toStringAsFixed(1)}%)',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: item.percentage / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Payment Mode Breakdown
                Text(
                  'Payment Mode Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: data.paymentModeBreakdown.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.paymentMode.label,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Col: ${MoneyFormatter.format(item.collectionAmount)}',
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Exp: ${MoneyFormatter.format(item.expenseAmount)}',
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Daily Trend
                Text(
                  'Daily Financial Trend',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: data.dailyTrends.isEmpty
                        ? const Center(
                            child: Text('No daily transaction trends available.'))
                        : Column(
                            children: data.dailyTrends.map((trend) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateFormat.format(trend.date),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '+${MoneyFormatter.format(trend.collectionAmount)}',
                                          style: const TextStyle(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          '-${MoneyFormatter.format(trend.expenseAmount)}',
                                          style: const TextStyle(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingView(message: 'Loading analytics...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(analyticsProvider),
        ),
      ),
    );
  }
}
