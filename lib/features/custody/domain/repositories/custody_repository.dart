import '../entities/collection_custody.dart';

abstract class CustodyRepository {
  Future<List<CollectionCustody>> getCustodyRecordsByEventId(String eventId);
  Future<void> createCustodyRecord(CollectionCustody record);
  Future<void> updateCustodyRecord(CollectionCustody record);
  Future<void> deleteCustodyRecord(String id);
}
