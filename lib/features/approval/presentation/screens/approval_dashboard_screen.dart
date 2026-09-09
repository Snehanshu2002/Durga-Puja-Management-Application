import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/features/collection/presentation/providers/collection_provider.dart';
import 'package:durgapuja_manager/features/expense/presentation/providers/expense_provider.dart';
import 'transaction_review_screen.dart';

class ApprovalDashboardScreen extends ConsumerWidget {
  final int initialTabIndex;

  const ApprovalDashboardScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCollectionsAsync = ref.watch(pendingCollectionsProvider);
    final pendingExpensesAsync = ref.watch(pendingExpensesProvider);

    final dateFormat = DateFormat('dd MMM yyyy');

    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex.clamp(0, 1),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Approvals Hub'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Collections'),
              Tab(text: 'Pending Expenses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Collections Tab
            pendingCollectionsAsync.when(
              data: (collections) {
                if (collections.isEmpty) {
                  return const Center(
                    child: Text('No pending collections for approval.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final item = collections[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          item.donorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item.paymentMode.label} • ${dateFormat.format(item.date)}',
                        ),
                        trailing: Text(
                          '₹${item.amount}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransactionReviewScreen(collection: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingView(),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(pendingCollectionsProvider),
              ),
            ),

            // Expenses Tab
            pendingExpensesAsync.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const Center(
                    child: Text('No pending expenses for approval.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final item = expenses[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          item.paidTo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item.description} • ${dateFormat.format(item.date)}',
                        ),
                        trailing: Text(
                          '₹${item.amount}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransactionReviewScreen(expense: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingView(),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(pendingExpensesProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
