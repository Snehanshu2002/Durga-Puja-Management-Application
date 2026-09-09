import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/features/collection/presentation/providers/collection_provider.dart';
import 'package:durgapuja_manager/features/expense/presentation/providers/expense_provider.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/approval/domain/usecases/approve_collection_usecase.dart';
import 'package:durgapuja_manager/features/approval/domain/usecases/approve_expense_usecase.dart';
import 'package:durgapuja_manager/features/approval/domain/usecases/reject_collection_usecase.dart';
import 'package:durgapuja_manager/features/approval/domain/usecases/reject_expense_usecase.dart';

export 'package:durgapuja_manager/features/collection/presentation/providers/collection_provider.dart';
export 'package:durgapuja_manager/features/expense/presentation/providers/expense_provider.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final approveCollectionUseCaseProvider = Provider<ApproveCollectionUseCase>((ref) {
  return ApproveCollectionUseCase(
    ref.watch(collectionRepositoryProvider),
    ref.watch(permissionServiceProvider),
  );
});

final rejectCollectionUseCaseProvider = Provider<RejectCollectionUseCase>((ref) {
  return RejectCollectionUseCase(
    ref.watch(collectionRepositoryProvider),
    ref.watch(permissionServiceProvider),
  );
});

final approveExpenseUseCaseProvider = Provider<ApproveExpenseUseCase>((ref) {
  return ApproveExpenseUseCase(
    ref.watch(expenseRepositoryProvider),
    ref.watch(permissionServiceProvider),
  );
});

final rejectExpenseUseCaseProvider = Provider<RejectExpenseUseCase>((ref) {
  return RejectExpenseUseCase(
    ref.watch(expenseRepositoryProvider),
    ref.watch(permissionServiceProvider),
  );
});
