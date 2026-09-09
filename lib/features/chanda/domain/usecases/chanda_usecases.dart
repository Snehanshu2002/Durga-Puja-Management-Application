import '../../../../core/error/app_exception.dart';
import '../../../collection/domain/repositories/collection_repository.dart';
import '../entities/chanda_target.dart';
import '../repositories/chanda_repository.dart';

class GetChandaTargetsUseCase {
  final ChandaRepository repository;
  GetChandaTargetsUseCase(this.repository);

  Future<List<ChandaTarget>> execute(String eventId) {
    return repository.getChandaTargetsByEventId(eventId);
  }
}

class CreateChandaTargetUseCase {
  final ChandaRepository repository;
  CreateChandaTargetUseCase(this.repository);

  Future<void> execute(ChandaTarget target) {
    return repository.createChandaTarget(target);
  }
}

class UpdateChandaTargetUseCase {
  final ChandaRepository repository;
  UpdateChandaTargetUseCase(this.repository);

  Future<void> execute(ChandaTarget target) {
    return repository.updateChandaTarget(target);
  }
}

class DeleteChandaTargetUseCase {
  final ChandaRepository repository;
  final CollectionRepository? collectionRepository;

  DeleteChandaTargetUseCase(this.repository, [this.collectionRepository]);

  Future<void> execute({
    required String targetId,
    required String eventId,
  }) async {
    if (collectionRepository != null) {
      final collections = await collectionRepository!.getCollectionsByEventId(eventId);
      final hasApprovedCollections = collections.any(
        (c) => c.isApproved && c.chandaTargetId == targetId,
      );
      if (hasApprovedCollections) {
        throw const AppException(
          'Cannot delete pledge target with approved collection payments. Please archive/close the target instead.',
        );
      }
    }
    return repository.deleteChandaTarget(targetId);
  }
}
