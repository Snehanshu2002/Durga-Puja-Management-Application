import '../../../users/domain/entities/user.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getExpensesByEventId(String eventId);
  Future<List<ExpenseEntity>> getPendingExpenses(String eventId);
  Future<ExpenseEntity?> getExpenseById(String id);
  Future<void> createExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense({
    required ExpenseEntity expense,
    required AppUser user,
  });
  Future<void> updateExpenseStatus({
    required String expenseId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  });
}
