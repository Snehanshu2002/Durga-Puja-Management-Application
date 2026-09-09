import '../entities/chanda_target.dart';

abstract class ChandaRepository {
  Future<List<ChandaTarget>> getChandaTargetsByEventId(String eventId);
  Future<ChandaTarget?> getChandaTargetById(String id);
  Future<void> createChandaTarget(ChandaTarget target);
  Future<void> updateChandaTarget(ChandaTarget target);
  Future<void> deleteChandaTarget(String id);
}
