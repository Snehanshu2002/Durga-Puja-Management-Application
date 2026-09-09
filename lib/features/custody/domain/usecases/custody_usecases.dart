import '../entities/collection_custody.dart';
import '../repositories/custody_repository.dart';

class GetCustodyRecordsUseCase {
  final CustodyRepository repository;
  GetCustodyRecordsUseCase(this.repository);

  Future<List<CollectionCustody>> execute(String eventId) {
    return repository.getCustodyRecordsByEventId(eventId);
  }
}

class CreateCustodyHandoverUseCase {
  final CustodyRepository repository;
  CreateCustodyHandoverUseCase(this.repository);

  Future<void> execute(CollectionCustody record) {
    return repository.createCustodyRecord(record);
  }
}

class UpdateCustodyRecordUseCase {
  final CustodyRepository repository;
  UpdateCustodyRecordUseCase(this.repository);

  Future<void> execute(CollectionCustody record) {
    return repository.updateCustodyRecord(record);
  }
}

class DeleteCustodyRecordUseCase {
  final CustodyRepository repository;
  DeleteCustodyRecordUseCase(this.repository);

  Future<void> execute(String id) {
    return repository.deleteCustodyRecord(id);
  }
}
