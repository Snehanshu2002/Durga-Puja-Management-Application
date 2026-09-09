import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/puja_event_model.dart';

abstract class PujaEventRemoteDataSource {
  Future<List<PujaEventModel>> getAllEvents();
  Future<List<PujaEventModel>> getActiveEvents();
  Future<PujaEventModel?> getEventById(String id);
  Future<void> createEvent(PujaEventModel event);
  Future<void> updateEvent(PujaEventModel event);
}

class PujaEventRemoteDataSourceImpl implements PujaEventRemoteDataSource {
  final FirebaseFirestore _firestore;

  PujaEventRemoteDataSourceImpl(this._firestore);

  CollectionReference get _eventsRef => _firestore.collection('puja_events');

  @override
  Future<List<PujaEventModel>> getAllEvents() async {
    final snapshot = await _eventsRef.get();
    final docs = snapshot.docs
        .map((doc) => PujaEventModel.fromFirestore(doc))
        .toList();
    docs.sort((a, b) => b.year.compareTo(a.year));
    return docs;
  }

  @override
  Future<List<PujaEventModel>> getActiveEvents() async {
    final snapshot = await _eventsRef
        .where('status', isEqualTo: 'ACTIVE')
        .get();
    final docs = snapshot.docs
        .map((doc) => PujaEventModel.fromFirestore(doc))
        .toList();
    docs.sort((a, b) => b.year.compareTo(a.year));
    return docs;
  }

  @override
  Future<PujaEventModel?> getEventById(String id) async {
    final doc = await _eventsRef.doc(id).get();
    if (!doc.exists) return null;
    return PujaEventModel.fromFirestore(doc);
  }

  @override
  Future<void> createEvent(PujaEventModel event) async {
    final docRef = event.id.isNotEmpty
        ? _eventsRef.doc(event.id)
        : _eventsRef.doc();

    final newEvent = PujaEventModel(
      id: docRef.id,
      name: event.name.trim(),
      year: event.year,
      eventType: event.eventType,
      organizationName: event.organizationName,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location.trim(),
      description: event.description.trim(),
      status: event.status,
      createdBy: event.createdBy,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    );

    await docRef.set(newEvent.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> updateEvent(PujaEventModel event) async {
    await _eventsRef.doc(event.id).set(
          PujaEventModel.fromEntity(event).toFirestore(),
          SetOptions(merge: true),
        );
  }
}
