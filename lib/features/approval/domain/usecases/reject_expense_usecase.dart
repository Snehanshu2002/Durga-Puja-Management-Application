import '../../../../core/error/app_exception.dart';
import '../../../expense/domain/entities/expense_entity.dart';
import '../../../expense/domain/repositories/expense_repository.dart';
import '../../../roles/domain/entities/permission.dart';
import '../../../roles/domain/services/permission_service.dart';
import '../../../users/domain/entities/user.dart';

class RejectExpenseUseCase {
  final ExpenseRepository _repository;
  final PermissionService _permissionService;

  RejectExpenseUseCase(this._repository, this._permissionService);

  Future<void> execute({
    required ExpenseEntity expense,
    required AppUser reviewer,
    required String rejectionReason,
  }) async {
    if (!reviewer.hasAccessToEvent(expense.eventId)) {
      throw const PermissionException('You do not have access to reject expenses for this event.');
    }

    final effectiveRole = reviewer.getEffectiveRoleForEvent(expense.eventId);

    if (!_permissionService.hasPermission(effectiveRole, Permission.approveExpense)) {
      throw const PermissionException('You do not have permission to reject expenses for this event.');
    }

    if (rejectionReason.trim().isEmpty) {
      throw const AppException('Rejection reason is required.');
    }

    await _repository.updateExpenseStatus(
      expenseId: expense.id,
      status: 'REJECTED',
      reviewerUid: reviewer.uid,
      rejectionReason: rejectionReason.trim(),
    );
  }
}
