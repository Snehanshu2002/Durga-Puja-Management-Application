import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/collection_custody_model.dart';

abstract class CustodyRemoteDataSource {
  Future<List<CollectionCustodyModel>> getCustodyRecordsByEventId(String eventId);
  Future<void> createCustodyRecord(CollectionCustodyModel record);
  Future<void> updateCustodyRecord(CollectionCustodyModel record);
  Future<void> deleteCustodyRecord(String id);
}

class CustodyRemoteDataSourceImpl implements CustodyRemoteDataSource {
  final FirebaseFirestore firestore;
  CustodyRemoteDataSourceImpl(this.firestore);

  CollectionReference get _custodyRef => firestore.collection('collection_custody');

  @override
  Future<List<CollectionCustodyModel>> getCustodyRecordsByEventId(String eventId) async {
    try {
      final snapshot = await _custodyRef
          .where('eventId', isEqualTo: eventId)
          .get();

      final list = snapshot.docs
          .map((doc) => CollectionCustodyModel.fromFirestore(doc))
          .toList();

      list.sort((a, b) => b.handedOverAt.compareTo(a.handedOverAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> createCustodyRecord(CollectionCustodyModel record) async {
    await _custodyRef.doc(record.id).set(record.toFirestore());
  }

  @override
  Future<void> updateCustodyRecord(CollectionCustodyModel record) async {
    await _custodyRef.doc(record.id).update(record.toFirestore());
  }

  @override
  Future<void> deleteCustodyRecord(String id) async {
    await _custodyRef.doc(id).delete();
  }
}
