import '../../../../core/error/app_exception.dart';
import '../../../roles/domain/services/permission_service.dart';
import '../../../users/domain/entities/user.dart';
import '../../domain/entities/collection_entity.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_remote_datasource.dart';
import '../models/collection_model.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionRemoteDataSource _remoteDataSource;

  CollectionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CollectionEntity>> getCollectionsByEventId(String eventId) async {
    return await _remoteDataSource.getCollectionsByEventId(eventId);
  }

  @override
  Future<List<CollectionEntity>> getPendingCollections(String eventId) async {
    return await _remoteDataSource.getPendingCollections(eventId);
  }

  @override
  Future<CollectionEntity?> getCollectionById(String id) async {
    return await _remoteDataSource.getCollectionById(id);
  }

  @override
  Future<void> createCollection(CollectionEntity collection) async {
    await _remoteDataSource.createCollection(CollectionModel.fromEntity(collection));
  }

  @override
  Future<void> updateCollection(CollectionEntity collection) async {
    await _remoteDataSource.updateCollection(CollectionModel.fromEntity(collection));
  }

  @override
  Future<void> deleteCollection({
    required CollectionEntity collection,
    required AppUser user,
  }) async {
    if (collection.isApproved) {
      throw const AppException('Approved transactions cannot be deleted. Approved records must remain permanently preserved.');
    }

    if (collection.isCustodyLinked) {
      throw const AppException('Cannot delete: this collection is already linked to cash custody.');
    }

    if (!collection.isPending) {
      throw const AppException('Only pending collections can be deleted.');
    }

    if (!user.hasAccessToEvent(collection.eventId)) {
      throw const PermissionException('You do not have access to this event.');
    }

    final effectiveRole = user.getEffectiveRoleForEvent(collection.eventId);
    final canDelete = PermissionService().canDeleteCollection(
      role: effectiveRole,
      status: collection.status,
      isOwner: collection.createdBy == user.uid,
      isCustodyLinked: collection.isCustodyLinked,
    );

    if (!canDelete) {
      throw const PermissionException('You do not have permission to delete this collection entry.');
    }

    await _remoteDataSource.deleteCollection(collection.id);
  }

  @override
  Future<void> updateCollectionStatus({
    required String collectionId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  }) async {
    await _remoteDataSource.updateCollectionStatusInTransaction(
      collectionId: collectionId,
      status: status,
      reviewerUid: reviewerUid,
      rejectionReason: rejectionReason,
    );
  }
}
