import '../../../../core/error/app_exception.dart';
import '../../../collection/domain/entities/collection_entity.dart';
import '../../../collection/domain/repositories/collection_repository.dart';
import '../../../roles/domain/entities/permission.dart';
import '../../../roles/domain/services/permission_service.dart';
import '../../../users/domain/entities/user.dart';

class ApproveCollectionUseCase {
  final CollectionRepository _repository;
  final PermissionService _permissionService;

  ApproveCollectionUseCase(this._repository, this._permissionService);

  Future<void> execute({
    required CollectionEntity collection,
    required AppUser reviewer,
  }) async {
    if (!reviewer.hasAccessToEvent(collection.eventId)) {
      throw const PermissionException('You do not have access to approve collections for this event.');
    }

    final effectiveRole = reviewer.getEffectiveRoleForEvent(collection.eventId);

    if (!_permissionService.hasPermission(effectiveRole, Permission.approveCollection)) {
      throw const PermissionException('You do not have permission to approve collections for this event.');
    }

    if (collection.createdBy == reviewer.uid) {
      throw const PermissionException('Self-approval restricted: Another authorized user must approve your collection entry.');
    }

    await _repository.updateCollectionStatus(
      collectionId: collection.id,
      status: 'APPROVED',
      reviewerUid: reviewer.uid,
    );
  }
}
