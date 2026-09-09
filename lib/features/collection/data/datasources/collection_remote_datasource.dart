import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/collection_model.dart';
import '../../../../core/error/app_exception.dart';

abstract class CollectionRemoteDataSource {
  Future<List<CollectionModel>> getCollectionsByEventId(String eventId);
  Future<List<CollectionModel>> getPendingCollections(String eventId);
  Future<CollectionModel?> getCollectionById(String id);
  Future<void> createCollection(CollectionModel collection);
  Future<void> updateCollection(CollectionModel collection);
  Future<void> deleteCollection(String id);
  Future<void> updateCollectionStatusInTransaction({
    required String collectionId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  });
}

class CollectionRemoteDataSourceImpl implements CollectionRemoteDataSource {
  final FirebaseFirestore _firestore;

  CollectionRemoteDataSourceImpl(this._firestore);

  CollectionReference get _collectionsRef => _firestore.collection('collections');

  @override
  Future<void> deleteCollection(String id) async {
    await _collectionsRef.doc(id).delete();
  }

  List<String> _getEventIdsToQuery(String eventId) {
    if (eventId == 'bhasani_utsab_2026' || eventId == 'event_2026') {
      return ['bhasani_utsab_2026', 'event_2026'];
    }
    return [eventId];
  }

  @override
  Future<List<CollectionModel>> getCollectionsByEventId(String eventId) async {
    final eventIds = _getEventIdsToQuery(eventId);
    final snapshot = await _collectionsRef
        .where('eventId', whereIn: eventIds)
        .get();
    final docs = snapshot.docs
        .map((doc) => CollectionModel.fromFirestore(doc))
        .toList();
    docs.sort((a, b) => b.date.compareTo(a.date));
    return docs;
  }

  @override
  Future<List<CollectionModel>> getPendingCollections(String eventId) async {
    final eventIds = _getEventIdsToQuery(eventId);
    final snapshot = await _collectionsRef
        .where('eventId', whereIn: eventIds)
        .where('status', isEqualTo: 'PENDING')
        .get();
    final docs = snapshot.docs
        .map((doc) => CollectionModel.fromFirestore(doc))
        .toList();
    docs.sort((a, b) => b.date.compareTo(a.date));
    return docs;
  }

  @override
  Future<CollectionModel?> getCollectionById(String id) async {
    final doc = await _collectionsRef.doc(id).get();
    if (!doc.exists) return null;
    return CollectionModel.fromFirestore(doc);
  }

  @override
  Future<void> createCollection(CollectionModel collection) async {
    final docRef = collection.id.isNotEmpty
        ? _collectionsRef.doc(collection.id)
        : _collectionsRef.doc();

    final newDoc = CollectionModel(
      id: docRef.id,
      eventId: collection.eventId,
      donorName: collection.donorName.trim(),
      mobileNumber: collection.mobileNumber?.trim(),
      amount: collection.amount,
      paymentMode: collection.paymentMode,
      transactionId: collection.transactionId?.trim(),
      purpose: collection.purpose.trim(),
      collectedBy: collection.collectedBy,
      date: collection.date,
      remark: collection.remark?.trim(),
      paymentScreenshotUrl: collection.paymentScreenshotUrl,
      status: collection.status,
      createdBy: collection.createdBy,
      createdAt: collection.createdAt,
      updatedAt: collection.updatedAt,
    );

    await docRef.set(newDoc.toFirestore());
  }

  @override
  Future<void> updateCollection(CollectionModel collection) async {
    final docRef = _collectionsRef.doc(collection.id);
    await docRef.set(collection.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> updateCollectionStatusInTransaction({
    required String collectionId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final docRef = _collectionsRef.doc(collectionId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw const AppException('Collection record does not exist.');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentStatus = data['status'] ?? 'PENDING';

      if (currentStatus != 'PENDING') {
        throw AppException('Transaction is already $currentStatus.');
      }

      final updates = <String, dynamic>{
        'status': status,
        'approvedBy': reviewerUid,
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (rejectionReason != null) {
        updates['rejectionReason'] = rejectionReason;
      }

      transaction.update(docRef, updates);
    });
  }
}
