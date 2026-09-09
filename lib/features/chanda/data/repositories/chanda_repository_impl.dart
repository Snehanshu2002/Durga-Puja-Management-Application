import '../../domain/entities/chanda_target.dart';
import '../../domain/repositories/chanda_repository.dart';
import '../datasources/chanda_remote_datasource.dart';
import '../models/chanda_target_model.dart';

class ChandaRepositoryImpl implements ChandaRepository {
  final ChandaRemoteDataSource remoteDataSource;
  ChandaRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ChandaTarget>> getChandaTargetsByEventId(String eventId) async {
    return remoteDataSource.getChandaTargetsByEventId(eventId);
  }

  @override
  Future<ChandaTarget?> getChandaTargetById(String id) async {
    return remoteDataSource.getChandaTargetById(id);
  }

  @override
  Future<void> createChandaTarget(ChandaTarget target) async {
    return remoteDataSource.createChandaTarget(ChandaTargetModel.fromEntity(target));
  }

  @override
  Future<void> updateChandaTarget(ChandaTarget target) async {
    return remoteDataSource.updateChandaTarget(ChandaTargetModel.fromEntity(target));
  }

  @override
  Future<void> deleteChandaTarget(String id) async {
    return remoteDataSource.deleteChandaTarget(id);
  }
}
