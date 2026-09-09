import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/features/collection/presentation/providers/collection_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import '../../data/datasources/custody_remote_datasource.dart';
import '../../data/repositories/custody_repository_impl.dart';
import '../../domain/entities/collection_custody.dart';
import '../../domain/entities/user_custody_balance.dart';
import '../../domain/repositories/custody_repository.dart';

final custodyRemoteDataSourceProvider = Provider<CustodyRemoteDataSource>((ref) {
  return CustodyRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final custodyRepositoryProvider = Provider<CustodyRepository>((ref) {
  final dataSource = ref.watch(custodyRemoteDataSourceProvider);
  return CustodyRepositoryImpl(dataSource);
});

final custodyRecordsProvider = FutureProvider<List<CollectionCustody>>((ref) async {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) return [];

  final repo = ref.watch(custodyRepositoryProvider);
  try {
    return await repo.getCustodyRecordsByEventId(activeEvent.id);
  } catch (_) {
    return [];
  }
});

class CustodySummary {
  final int totalApprovedCashCollection;
  final int totalWithCollectors;
  final int totalWithTreasurer;
  final int totalDeposited;
  final int totalPendingHandovers;
  final int pendingHandoversCount;

  const CustodySummary({
    required this.totalApprovedCashCollection,
    required this.totalWithCollectors,
    required this.totalWithTreasurer,
    required this.totalDeposited,
    required this.totalPendingHandovers,
    required this.pendingHandoversCount,
  });

  int get totalInCustody => totalWithCollectors + totalWithTreasurer;

  /// Reconciled Total = With Collectors + With Treasurer + Bank Deposited
  int get reconciledTotal => totalWithCollectors + totalWithTreasurer + totalDeposited;

  /// Difference = |Approved Cash Collection - Reconciled Total|
  int get reconciliationDifference => (totalApprovedCashCollection - reconciledTotal).abs();

  /// Whether the reconciliation matches perfectly
  bool get isReconciled => totalApprovedCashCollection == reconciledTotal;
}

final userCustodyBalancesProvider = Provider<List<UserCustodyBalance>>((ref) {
  final collections = ref.watch(collectionsProvider).value ?? [];
  final custodyRecords = ref.watch(custodyRecordsProvider).value ?? [];

  // Filter strictly approved collections
  final approvedCollections = collections.where((c) => c.isApproved).toList();

  // Aggregate user IDs and Names
  final Map<String, String> userNames = {};
  final Map<String, int> collectedMap = {};
  final Map<String, int> receivedMap = {};
  final Map<String, int> handedOverMap = {};
  final Map<String, int> depositedMap = {};
  final Map<String, int> pendingOutgoingMap = {};

  void ensureUser(String uid, String name) {
    if (uid.isEmpty) return;
    userNames.putIfAbsent(uid, () => name.isNotEmpty ? name : 'Collector');
    collectedMap.putIfAbsent(uid, () => 0);
    receivedMap.putIfAbsent(uid, () => 0);
    handedOverMap.putIfAbsent(uid, () => 0);
    depositedMap.putIfAbsent(uid, () => 0);
    pendingOutgoingMap.putIfAbsent(uid, () => 0);
  }

  // 1. Process Approved Cash Collections
  for (final c in approvedCollections) {
    final uid = c.createdBy;
    final name = c.collectedBy.isNotEmpty ? c.collectedBy : 'Collector';
    ensureUser(uid, name);

    // Only Cash collections create physical in-hand custody
    if (c.paymentMode == PaymentMode.cash) {
      collectedMap[uid] = (collectedMap[uid] ?? 0) + c.amount;
    }
  }

  // 2. Process Custody Transfers & Deposits
  for (final record in custodyRecords) {
    if (record.isCancelled) continue;

    // Sender
    ensureUser(record.fromUserId, record.fromUserName);

    if (record.isPending) {
      // Track pending outgoing to lock balance from being double handed-over
      pendingOutgoingMap[record.fromUserId] =
          (pendingOutgoingMap[record.fromUserId] ?? 0) + record.amount;
      continue;
    }

    if (record.handoverType == CollectionCustody.typeBankDeposit && record.isDeposited) {
      depositedMap[record.fromUserId] = (depositedMap[record.fromUserId] ?? 0) + record.amount;
    } else if (record.handoverType == CollectionCustody.typeCashHandover && record.isReceived) {
      handedOverMap[record.fromUserId] = (handedOverMap[record.fromUserId] ?? 0) + record.amount;

      // Receiver
      if (record.toUserId.isNotEmpty && record.toUserId != 'BANK') {
        ensureUser(record.toUserId, record.toUserName);
        receivedMap[record.toUserId] = (receivedMap[record.toUserId] ?? 0) + record.amount;
      }
    }
  }

  // Build Balance entities
  final List<UserCustodyBalance> balances = [];
  for (final uid in userNames.keys) {
    final col = collectedMap[uid] ?? 0;
    final rec = receivedMap[uid] ?? 0;
    final hnd = handedOverMap[uid] ?? 0;
    final dep = depositedMap[uid] ?? 0;
    final pendOut = pendingOutgoingMap[uid] ?? 0;

    final name = userNames[uid] ?? 'Collector';
    final isTreasurer = name.toLowerCase().contains('treasurer') ||
        name.toLowerCase().contains('titu') ||
        name.toLowerCase().contains('president') ||
        name.toLowerCase().contains('admin');

    // Include if the user has any collection or custody activity
    if (col > 0 || rec > 0 || hnd > 0 || dep > 0 || pendOut > 0) {
      balances.add(
        UserCustodyBalance(
          userId: uid,
          userName: name,
          totalCollected: col,
          totalReceived: rec,
          totalHandedOver: hnd,
          totalDeposited: dep,
          pendingOutgoing: pendOut,
          isTreasurer: isTreasurer,
        ),
      );
    }
  }

  balances.sort((a, b) => b.currentCustody.compareTo(a.currentCustody));
  return balances;
});

final custodySummaryProvider = Provider<CustodySummary>((ref) {
  final collections = ref.watch(collectionsProvider).value ?? [];
  final custodyRecords = ref.watch(custodyRecordsProvider).value ?? [];
  final balances = ref.watch(userCustodyBalancesProvider);

  // Cash collections only
  final totalApprovedCash = collections
      .where((c) => c.isApproved && c.paymentMode == PaymentMode.cash)
      .fold<int>(0, (acc, c) => acc + c.amount);

  final totalDeposited = custodyRecords
      .where((r) => r.isDeposited && r.handoverType == CollectionCustody.typeBankDeposit)
      .fold<int>(0, (acc, r) => acc + r.amount);

  final pendingHandovers = custodyRecords.where((r) => r.isPending).toList();
  final totalPending = pendingHandovers.fold<int>(0, (acc, r) => acc + r.amount);

  int totalTreasurer = 0;
  int totalCollectors = 0;

  for (final b in balances) {
    if (b.isTreasurer) {
      totalTreasurer += b.currentCustody;
    } else {
      totalCollectors += b.currentCustody;
    }
  }

  return CustodySummary(
    totalApprovedCashCollection: totalApprovedCash,
    totalWithCollectors: totalCollectors,
    totalWithTreasurer: totalTreasurer,
    totalDeposited: totalDeposited,
    totalPendingHandovers: totalPending,
    pendingHandoversCount: pendingHandovers.length,
  );
});
