import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chanda_target_model.dart';

abstract class ChandaRemoteDataSource {
  Future<List<ChandaTargetModel>> getChandaTargetsByEventId(String eventId);
  Future<ChandaTargetModel?> getChandaTargetById(String id);
  Future<void> createChandaTarget(ChandaTargetModel target);
  Future<void> updateChandaTarget(ChandaTargetModel target);
  Future<void> deleteChandaTarget(String id);
}

class ChandaRemoteDataSourceImpl implements ChandaRemoteDataSource {
  final FirebaseFirestore firestore;
  ChandaRemoteDataSourceImpl(this.firestore);

  CollectionReference get _chandaRef => firestore.collection('chanda_targets');

  @override
  Future<List<ChandaTargetModel>> getChandaTargetsByEventId(String eventId) async {
    try {
      final snapshot = await _chandaRef
          .where('eventId', isEqualTo: eventId)
          .get();

      final list = snapshot.docs
          .map((doc) => ChandaTargetModel.fromFirestore(doc))
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ChandaTargetModel?> getChandaTargetById(String id) async {
    final doc = await _chandaRef.doc(id).get();
    if (!doc.exists) return null;
    return ChandaTargetModel.fromFirestore(doc);
  }

  @override
  Future<void> createChandaTarget(ChandaTargetModel target) async {
    await _chandaRef.doc(target.id).set(target.toFirestore());
  }

  @override
  Future<void> updateChandaTarget(ChandaTargetModel target) async {
    await _chandaRef.doc(target.id).update(target.toFirestore());
  }

  @override
  Future<void> deleteChandaTarget(String id) async {
    await _chandaRef.doc(id).delete();
  }
}
