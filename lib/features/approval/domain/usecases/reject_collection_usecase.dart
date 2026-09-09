import '../../../../core/error/app_exception.dart';
import '../../../collection/domain/entities/collection_entity.dart';
import '../../../collection/domain/repositories/collection_repository.dart';
import '../../../roles/domain/entities/permission.dart';
import '../../../roles/domain/services/permission_service.dart';
import '../../../users/domain/entities/user.dart';

class RejectCollectionUseCase {
  final CollectionRepository _repository;
  final PermissionService _permissionService;

  RejectCollectionUseCase(this._repository, this._permissionService);

  Future<void> execute({
    required CollectionEntity collection,
    required AppUser reviewer,
    required String rejectionReason,
  }) async {
    if (!reviewer.hasAccessToEvent(collection.eventId)) {
      throw const PermissionException('You do not have access to reject collections for this event.');
    }

    final effectiveRole = reviewer.getEffectiveRoleForEvent(collection.eventId);

    if (!_permissionService.hasPermission(effectiveRole, Permission.approveCollection)) {
      throw const PermissionException('You do not have permission to reject collections for this event.');
    }

    if (rejectionReason.trim().isEmpty) {
      throw const AppException('Rejection reason is required.');
    }

    await _repository.updateCollectionStatus(
      collectionId: collection.id,
      status: 'REJECTED',
      reviewerUid: reviewer.uid,
      rejectionReason: rejectionReason.trim(),
    );
  }
}
