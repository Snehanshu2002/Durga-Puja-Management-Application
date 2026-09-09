import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense_category.dart';

final expenseCategoriesProvider = StateProvider<List<ExpenseCategory>>((ref) {
  return ExpenseCategory.defaultCategories;
});

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Categories'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: cat.isActive ? Colors.green.shade100 : Colors.grey.shade300,
                child: Icon(
                  cat.isActive ? Icons.category : Icons.block,
                  color: cat.isActive ? Colors.green : Colors.grey,
                ),
              ),
              title: Text(
                cat.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: cat.isActive ? TextDecoration.none : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text('Used in ${cat.usageCount} expenses'),
              trailing: Switch(
                value: cat.isActive,
                onChanged: (val) {
                  final updatedList = [...categories];
                  updatedList[index] = cat.copyWith(isActive: val);
                  ref.read(expenseCategoriesProvider.notifier).state = updatedList;
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
