import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/features/approval/presentation/providers/approval_provider.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';

class PersonDonationSummary {
  final String donorName;
  final String? mobile;
  final int totalAmount;
  final int transactionCount;
  final DateTime firstDonation;
  final DateTime lastDonation;
  final List<CollectionEntity> items;

  const PersonDonationSummary({
    required this.donorName,
    this.mobile,
    required this.totalAmount,
    required this.transactionCount,
    required this.firstDonation,
    required this.lastDonation,
    required this.items,
  });
}

class CollectorSummary {
  final String collectorUid;
  final String collectorName;
  final String? collectorEmail;
  final String? collectorRole;
  final int totalAmount;
  final int transactionCount;
  final List<CollectionEntity> items;

  const CollectorSummary({
    required this.collectorUid,
    required this.collectorName,
    this.collectorEmail,
    this.collectorRole,
    required this.totalAmount,
    required this.transactionCount,
    required this.items,
  });
}

class CategoryExpenseSummary {
  final String categoryId;
  final String categoryName;
  final int totalAmount;
  final int count;
  final List<ExpenseEntity> items;

  const CategoryExpenseSummary({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.count,
    required this.items,
  });
}

final personWiseReportProvider = FutureProvider<List<PersonDonationSummary>>((ref) async {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) return [];

  final repo = ref.watch(collectionRepositoryProvider);
  final collections = await repo.getCollectionsByEventId(activeEvent.id);

  final approved = collections.where((c) => c.status.toUpperCase() == 'APPROVED');

  final Map<String, List<CollectionEntity>> grouped = {};
  for (final col in approved) {
    final key = col.donorName.trim().toLowerCase();
    if (key.isNotEmpty) {
      grouped.putIfAbsent(key, () => []).add(col);
    }
  }

  final List<PersonDonationSummary> result = [];
  grouped.forEach((key, list) {
    list.sort((a, b) => a.date.compareTo(b.date));
    int total = 0;
    for (final item in list) {
      total += item.amount;
    }
    result.add(
      PersonDonationSummary(
        donorName: list.first.donorName,
        mobile: list.first.mobileNumber,
        totalAmount: total,
        transactionCount: list.length,
        firstDonation: list.first.date,
        lastDonation: list.last.date,
        items: list,
      ),
    );
  });

  result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  return result;
});

final collectorWiseReportProvider = FutureProvider<List<CollectorSummary>>((ref) async {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) return [];

  final repo = ref.watch(collectionRepositoryProvider);
  final collections = await repo.getCollectionsByEventId(activeEvent.id);

  final approved = collections.where((c) => c.status.toUpperCase() == 'APPROVED');

  List<AppUser> allUsers = [];
  try {
    allUsers = await ref.read(userRepositoryProvider).getAllUsers();
  } catch (_) {}

  final Map<String, List<CollectionEntity>> grouped = {};
  for (final col in approved) {
    final uid = col.collectedBy.isNotEmpty ? col.collectedBy : col.createdBy;
    grouped.putIfAbsent(uid, () => []).add(col);
  }

  final List<CollectorSummary> result = [];
  grouped.forEach((uid, list) {
    list.sort((a, b) => b.date.compareTo(a.date));
    int total = 0;
    for (final item in list) {
      total += item.amount;
    }

    AppUser? matchedUser;
    final lowerUid = uid.toLowerCase();
    for (final u in allUsers) {
      if (u.uid == uid ||
          u.email.toLowerCase() == lowerUid ||
          (u.email.isNotEmpty && lowerUid.contains(u.email.split('@').first.toLowerCase()))) {
        matchedUser = u;
        break;
      }
    }

    String name = matchedUser?.name ?? '';
    String? email = matchedUser?.email;
    String? role = matchedUser?.role.displayName;

    if (name.isEmpty) {
      if (uid.startsWith('user_pre_')) {
        name = uid.replaceAll('user_pre_', '').toUpperCase();
      } else if (uid.contains('@')) {
        name = uid.split('@').first.toUpperCase();
      } else {
        name = 'Collector ($uid)';
      }
    }

    result.add(
      CollectorSummary(
        collectorUid: uid,
        collectorName: name,
        collectorEmail: email,
        collectorRole: role,
        totalAmount: total,
        transactionCount: list.length,
        items: list,
      ),
    );
  });

  result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  return result;
});

final categoryWiseExpenseReportProvider = FutureProvider<List<CategoryExpenseSummary>>((ref) async {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) return [];

  final repo = ref.watch(expenseRepositoryProvider);
  final expenses = await repo.getExpensesByEventId(activeEvent.id);

  final approved = expenses.where((e) => e.status.toUpperCase() == 'APPROVED');

  final Map<String, List<ExpenseEntity>> grouped = {};
  for (final exp in approved) {
    final cat = exp.categoryId.isNotEmpty ? exp.categoryId : 'Other';
    grouped.putIfAbsent(cat, () => []).add(exp);
  }

  final List<CategoryExpenseSummary> result = [];
  grouped.forEach((cat, list) {
    int total = 0;
    for (final item in list) {
      total += item.amount;
    }
    final formattedName = cat.length > 1
        ? '${cat[0].toUpperCase()}${cat.substring(1)}'
        : cat.toUpperCase();
    result.add(
      CategoryExpenseSummary(
        categoryId: cat,
        categoryName: formattedName,
        totalAmount: total,
        count: list.length,
        items: list,
      ),
    );
  });

  result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  return result;
});
