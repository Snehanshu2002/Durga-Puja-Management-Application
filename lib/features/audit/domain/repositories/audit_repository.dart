import '../entities/audit_log.dart';

abstract class AuditRepository {
  Future<void> logAction(AuditLog log);
  Future<List<AuditLog>> getLogsByEventId(String eventId);
}
