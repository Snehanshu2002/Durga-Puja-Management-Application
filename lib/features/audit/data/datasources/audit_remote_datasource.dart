import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_model.dart';

abstract class AuditRemoteDataSource {
  Future<void> logAction(AuditLogModel log);
  Future<List<AuditLogModel>> getLogsByEventId(String eventId);
}

class AuditRemoteDataSourceImpl implements AuditRemoteDataSource {
  final FirebaseFirestore _firestore;

  AuditRemoteDataSourceImpl(this._firestore);

  CollectionReference get _auditRef => _firestore.collection('audit_logs');

  @override
  Future<void> logAction(AuditLogModel log) async {
    final docRef = log.id.isNotEmpty
        ? _auditRef.doc(log.id)
        : _auditRef.doc();

    final newLog = AuditLogModel(
      id: docRef.id,
      eventId: log.eventId,
      userId: log.userId,
      userName: log.userName,
      action: log.action,
      entityType: log.entityType,
      entityId: log.entityId,
      timestamp: log.timestamp,
      metadata: log.metadata,
    );
    await docRef.set(newLog.toFirestore());
  }

  @override
  Future<List<AuditLogModel>> getLogsByEventId(String eventId) async {
    final snapshot = await _auditRef
        .where('eventId', isEqualTo: eventId)
        .limit(100)
        .get();
    final docs = snapshot.docs
        .map((doc) => AuditLogModel.fromFirestore(doc))
        .toList();
    docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return docs;
  }
}
