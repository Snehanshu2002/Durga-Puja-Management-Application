import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/audit_repository.dart';
import '../datasources/audit_remote_datasource.dart';
import '../models/audit_log_model.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource _remoteDataSource;

  AuditRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> logAction(AuditLog log) async {
    await _remoteDataSource.logAction(AuditLogModel.fromEntity(log));
  }

  @override
  Future<List<AuditLog>> getLogsByEventId(String eventId) async {
    return await _remoteDataSource.getLogsByEventId(eventId);
  }
}
