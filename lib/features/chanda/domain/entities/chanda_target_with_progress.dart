import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'chanda_target.dart';

class ChandaTargetWithProgress {
  final ChandaTarget target;
  final int paidAmount;
  final List<CollectionEntity> linkedCollections;

  const ChandaTargetWithProgress({
    required this.target,
    required this.paidAmount,
    required this.linkedCollections,
  });

  int get targetAmount => target.targetAmount;
  int get remainingAmount => (targetAmount - paidAmount).clamp(0, targetAmount);
  int get excessAmount => (paidAmount - targetAmount).clamp(0, paidAmount);
  bool get hasExcess => paidAmount > targetAmount;

  double get progressPercentage {
    if (targetAmount <= 0) return 1.0;
    final progress = paidAmount / targetAmount;
    return progress > 1.0 ? 1.0 : progress;
  }

  String get computedStatus {
    if (target.isCancelled) return 'CANCELLED';
    if (paidAmount >= targetAmount && targetAmount > 0) return 'PAID';
    if (paidAmount > 0) return 'PARTIAL';
    return 'PENDING';
  }

  bool get isFullyPaid => computedStatus == 'PAID';
  bool get isPartial => computedStatus == 'PARTIAL';
  bool get isPending => computedStatus == 'PENDING';
  bool get isCancelled => computedStatus == 'CANCELLED';
  String get statusLabel => computedStatus;

  List<CollectionEntity> get approvedCollections =>
      linkedCollections.where((c) => c.isApproved).toList();

  List<CollectionEntity> get pendingCollections =>
      linkedCollections.where((c) => c.isPending).toList();

  List<CollectionEntity> get rejectedCollections =>
      linkedCollections.where((c) => c.isRejected).toList();
}
