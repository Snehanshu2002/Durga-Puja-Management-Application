import '../../../../core/error/app_exception.dart';
import '../../../roles/domain/services/permission_service.dart';
import '../../../users/domain/entities/user.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _remoteDataSource;

  ExpenseRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ExpenseEntity>> getExpensesByEventId(String eventId) async {
    return await _remoteDataSource.getExpensesByEventId(eventId);
  }

  @override
  Future<List<ExpenseEntity>> getPendingExpenses(String eventId) async {
    return await _remoteDataSource.getPendingExpenses(eventId);
  }

  @override
  Future<ExpenseEntity?> getExpenseById(String id) async {
    return await _remoteDataSource.getExpenseById(id);
  }

  @override
  Future<void> createExpense(ExpenseEntity expense) async {
    await _remoteDataSource.createExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) async {
    await _remoteDataSource.updateExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> deleteExpense({
    required ExpenseEntity expense,
    required AppUser user,
  }) async {
    if (expense.isApproved) {
      throw const AppException('Approved transactions cannot be deleted. Approved records must remain permanently preserved.');
    }

    if (!expense.isPending) {
      throw const AppException('Only pending expenses can be deleted.');
    }

    if (!user.hasAccessToEvent(expense.eventId)) {
      throw const PermissionException('You do not have access to this event.');
    }

    final effectiveRole = user.getEffectiveRoleForEvent(expense.eventId);
    final canDelete = PermissionService().canDeleteExpense(
      role: effectiveRole,
      status: expense.status,
      isOwner: expense.addedBy == user.uid,
    );

    if (!canDelete) {
      throw const PermissionException('You do not have permission to delete this expense entry.');
    }

    await _remoteDataSource.deleteExpense(expense.id);
  }

  @override
  Future<void> updateExpenseStatus({
    required String expenseId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  }) async {
    await _remoteDataSource.updateExpenseStatusInTransaction(
      expenseId: expenseId,
      status: status,
      reviewerUid: reviewerUid,
      rejectionReason: rejectionReason,
    );
  }
}
