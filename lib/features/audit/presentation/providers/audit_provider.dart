import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/audit_remote_datasource.dart';
import '../../data/repositories/audit_repository_impl.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../../puja_event/presentation/providers/puja_event_provider.dart';

final auditRemoteDataSourceProvider = Provider<AuditRemoteDataSource>((ref) {
  return AuditRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final ds = ref.watch(auditRemoteDataSourceProvider);
  return AuditRepositoryImpl(ds);
});

final auditLogsProvider = FutureProvider<List<AuditLog>>((ref) async {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) return [];
  final repo = ref.watch(auditRepositoryProvider);
  return await repo.getLogsByEventId(activeEvent.id);
});
