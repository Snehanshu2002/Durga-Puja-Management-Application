import '../../domain/entities/puja_event.dart';
import '../../domain/repositories/puja_event_repository.dart';
import '../datasources/puja_event_remote_datasource.dart';
import '../models/puja_event_model.dart';

class PujaEventRepositoryImpl implements PujaEventRepository {
  final PujaEventRemoteDataSource _remoteDataSource;

  PujaEventRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PujaEvent>> getAllEvents() async {
    return await _remoteDataSource.getAllEvents();
  }

  @override
  Future<List<PujaEvent>> getActiveEvents() async {
    return await _remoteDataSource.getActiveEvents();
  }

  @override
  Future<PujaEvent?> getEventById(String id) async {
    return await _remoteDataSource.getEventById(id);
  }

  @override
  Future<void> createEvent(PujaEvent event) async {
    await _remoteDataSource.createEvent(PujaEventModel.fromEntity(event));
  }

  @override
  Future<void> updateEvent(PujaEvent event) async {
    await _remoteDataSource.updateEvent(PujaEventModel.fromEntity(event));
  }
}
