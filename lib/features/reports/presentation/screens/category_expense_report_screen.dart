import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/features/expense/presentation/widgets/edit_expense_dialog.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../providers/reports_provider.dart';

class CategoryExpenseReportScreen extends ConsumerWidget {
  const CategoryExpenseReportScreen({super.key});

  void _showImageZoom(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          width: MediaQuery.of(ctx).size.width * 0.95,
          height: MediaQuery.of(ctx).size.height * 0.85,
          child: Column(
            children: [
              AppBar(
                title: const Text('Voucher / Bill Photo'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, e, s) => const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Failed to load image.'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryWiseExpenseReportProvider);
    final userRole = ref.watch(effectiveRoleProvider);
    final canEditExpense = PermissionService().hasPermission(userRole, Permission.editExpense);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text('No approved expense records found for this event.'),
            );
          }

          final grandTotal = categories.fold<int>(
            0,
            (sum, item) => sum + item.totalAmount,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Approved Expenses:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '₹$grandTotal',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...categories.map((category) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.receipt_long, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      category.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${category.count} transactions'),
                    trailing: Text(
                      '₹${category.totalAmount}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    children: category.items.map((item) {
                      final photoUrl = item.voucherUrl ?? item.billUrl;
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          item.paidTo,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${item.description}\nMode: ${item.paymentMode.label} • ${dateFormat.format(item.date)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${item.amount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.redAccent,
                              ),
                            ),
                            if (photoUrl != null && photoUrl.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.photo, color: Colors.blue, size: 20),
                                onPressed: () => _showImageZoom(context, photoUrl),
                                tooltip: 'View Bill Photo',
                              ),
                            ],
                            if (canEditExpense) ...[
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.indigo, size: 20),
                                onPressed: () => EditExpenseDialog.show(context, item),
                                tooltip: 'Edit Expense Entry',
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const LoadingView(message: 'Loading expense details...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(categoryWiseExpenseReportProvider),
        ),
      ),
    );
  }
}
