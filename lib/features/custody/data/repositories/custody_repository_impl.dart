import '../../domain/entities/collection_custody.dart';
import '../../domain/repositories/custody_repository.dart';
import '../datasources/custody_remote_datasource.dart';
import '../models/collection_custody_model.dart';

class CustodyRepositoryImpl implements CustodyRepository {
  final CustodyRemoteDataSource remoteDataSource;
  CustodyRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CollectionCustody>> getCustodyRecordsByEventId(String eventId) async {
    return remoteDataSource.getCustodyRecordsByEventId(eventId);
  }

  @override
  Future<void> createCustodyRecord(CollectionCustody record) async {
    return remoteDataSource.createCustodyRecord(CollectionCustodyModel.fromEntity(record));
  }

  @override
  Future<void> updateCustodyRecord(CollectionCustody record) async {
    return remoteDataSource.updateCustodyRecord(CollectionCustodyModel.fromEntity(record));
  }

  @override
  Future<void> deleteCustodyRecord(String id) async {
    return remoteDataSource.deleteCustodyRecord(id);
  }
}
