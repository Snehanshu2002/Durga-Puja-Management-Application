import '../../../users/domain/entities/user.dart';
import '../entities/collection_entity.dart';

abstract class CollectionRepository {
  Future<List<CollectionEntity>> getCollectionsByEventId(String eventId);
  Future<List<CollectionEntity>> getPendingCollections(String eventId);
  Future<CollectionEntity?> getCollectionById(String id);
  Future<void> createCollection(CollectionEntity collection);
  Future<void> updateCollection(CollectionEntity collection);
  Future<void> deleteCollection({
    required CollectionEntity collection,
    required AppUser user,
  });
  Future<void> updateCollectionStatus({
    required String collectionId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  });
}
