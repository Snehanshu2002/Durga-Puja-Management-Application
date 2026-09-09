import '../../../../core/error/app_exception.dart';
import '../../../expense/domain/entities/expense_entity.dart';
import '../../../expense/domain/repositories/expense_repository.dart';
import '../../../roles/domain/entities/permission.dart';
import '../../../roles/domain/services/permission_service.dart';
import '../../../users/domain/entities/user.dart';

class ApproveExpenseUseCase {
  final ExpenseRepository _repository;
  final PermissionService _permissionService;

  ApproveExpenseUseCase(this._repository, this._permissionService);

  Future<void> execute({
    required ExpenseEntity expense,
    required AppUser reviewer,
  }) async {
    if (!reviewer.hasAccessToEvent(expense.eventId)) {
      throw const PermissionException('You do not have access to approve expenses for this event.');
    }

    final effectiveRole = reviewer.getEffectiveRoleForEvent(expense.eventId);

    if (!_permissionService.hasPermission(effectiveRole, Permission.approveExpense)) {
      throw const PermissionException('You do not have permission to approve expenses for this event.');
    }

    if (expense.addedBy == reviewer.uid) {
      throw const PermissionException('Self-approval restricted: Another authorized user must approve your expense entry.');
    }

    await _repository.updateExpenseStatus(
      expenseId: expense.id,
      status: 'APPROVED',
      reviewerUid: reviewer.uid,
    );
  }
}
