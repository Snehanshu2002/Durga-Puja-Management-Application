import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/features/collection/presentation/providers/collection_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/core/utils/bhasani_2026_seeder.dart';
import '../../data/datasources/chanda_remote_datasource.dart';
import '../../data/repositories/chanda_repository_impl.dart';
import '../../domain/entities/chanda_target.dart';
import '../../domain/entities/chanda_target_with_progress.dart';
import '../../domain/repositories/chanda_repository.dart';

final chandaRemoteDataSourceProvider = Provider<ChandaRemoteDataSource>((ref) {
  return ChandaRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final chandaRepositoryProvider = Provider<ChandaRepository>((ref) {
  final dataSource = ref.watch(chandaRemoteDataSourceProvider);
  return ChandaRepositoryImpl(dataSource);
});

final chandaTargetsProvider = FutureProvider<List<ChandaTarget>>((ref) async {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) return [];

  final repo = ref.watch(chandaRepositoryProvider);
  try {
    final targets = await repo.getChandaTargetsByEventId(activeEvent.id);
    if (activeEvent.id == 'bhasani_utsab_2026') {
      final needsPhoneSync = targets.isEmpty ||
          targets.length < Bhasani2026Seeder.targetList.length ||
          targets.any((t) =>
              (t.mobileNumber == null || t.mobileNumber!.isEmpty) &&
              Bhasani2026Seeder.targetList.any((s) => s['personName'] == t.personName && s['mobileNumber'] != null));

      if (needsPhoneSync) {
        await Bhasani2026Seeder.seedBhasani2026Targets(
          eventId: activeEvent.id,
          organizationName: activeEvent.organizationName,
        );
        final seeded = await repo.getChandaTargetsByEventId(activeEvent.id);
        if (seeded.isNotEmpty) return seeded;
        return Bhasani2026Seeder.getInitialTargets(
          eventId: activeEvent.id,
          organizationName: activeEvent.organizationName,
        );
      }
    }
    return targets;
  } catch (_) {
    if (activeEvent.id == 'bhasani_utsab_2026') {
      return Bhasani2026Seeder.getInitialTargets(
        eventId: activeEvent.id,
        organizationName: activeEvent.organizationName,
      );
    }
    return [];
  }
});

bool isEventCompatible(String targetEventId, String collEventId) {
  if (targetEventId == collEventId) return true;
  if ((targetEventId == 'bhasani_utsab_2026' || targetEventId == 'event_2026') &&
      (collEventId == 'bhasani_utsab_2026' || collEventId == 'event_2026')) {
    return true;
  }
  return false;
}

const Map<String, String> _knownAliases = {
  'kalu': 'snehanshu sahoo',
  'snehansu': 'snehanshu sahoo',
  'snehasnu': 'snehanshu sahoo',
  'snehanshu': 'snehanshu sahoo',
  'chandu': 'chandan swain',
  'chandan': 'chandan swain',
  'sankar': 'sankar bhola',
  'suma': 'sumanta sahoo',
  'sumant': 'sumanta sahoo',
  'sumanta': 'sumanta sahoo',
  'siba': 'siba bhola',
  'titu': 'titu behera',
  'silu': 'nilu bhola',
  'silu bhola': 'nilu bhola',
  'nilu': 'nilu bhola',
  'biren': 'birenraj pradhan',
  'birenraj': 'birenraj pradhan',
  'ashish': 'ashish praadhan',
  'deepak': 'deepak pradhan',
  'rajesh': 'rajesh bhola',
  'nata': 'natabar pradhan',
  'natabar': 'natabar pradhan',
  'ganthi': 'ganthi sahoo',
  'amiya': 'ameeya pradhan',
  'ameeya': 'ameeya pradhan',
  'debasish': 'debasish bhola',
  'debashish': 'debasish bhola',
  'gopal': 'gopal swain',
  'babul': 'babul behera',
  'babuli': 'babul behera',
  'tofan': 'tophan singh',
  'tophan': 'tophan singh',
  'sunil': 'sunil barik',
  'subhasish': 'subhasish bhola',
  'sudhanshu': 'sudhanshu sahoo',
  'prasant': 'prasant swain',
};

String _cleanName(String name) {
  return name.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ').toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool _matchesPersonName(String targetName, String collDonor) {
  final tClean = _cleanName(targetName);
  final cClean = _cleanName(collDonor);

  if (tClean == cClean) return true;

  final tWords = tClean.split(' ').where((w) => w.isNotEmpty).toList();
  final cWords = cClean.split(' ').where((w) => w.isNotEmpty).toList();

  // If both have multiple words (first and last name), ensure surnames don't conflict unless full alias
  if (tWords.length > 1 && cWords.length > 1) {
    if (tWords.last != cWords.last) {
      bool isAlias = false;
      for (final entry in _knownAliases.entries) {
        if ((cClean == entry.key || cWords.contains(entry.key)) && entry.value == tClean) {
          isAlias = true;
          break;
        }
      }
      if (!isAlias) return false;
    }
  }

  // Check aliases
  for (final entry in _knownAliases.entries) {
    if ((cClean == entry.key || cWords.contains(entry.key)) && entry.value == tClean) {
      return true;
    }
  }

  // If collection donor is single word / nickname (e.g. "Sankar"), match target's first name
  if (cWords.length == 1 && tWords.length > 1) {
    if (cWords[0] == tWords[0] || (cWords[0].length >= 4 && tWords[0].startsWith(cWords[0]))) {
      return true;
    }
  }

  return false;
}

final chandaWithProgressListProvider = Provider<List<ChandaTargetWithProgress>>((ref) {
  final targetsAsync = ref.watch(chandaTargetsProvider);
  final collectionsAsync = ref.watch(collectionsProvider);

  final targets = targetsAsync.value ?? [];
  final collections = collectionsAsync.value ?? [];

  return targets.map((target) {
    final cleanTargetPhone = target.mobileNumber?.replaceAll(RegExp(r'[^0-9]'), '');

    // Find all collections explicitly or implicitly linked to this target
    final linked = collections.where((c) {
      // 1. Explicit target ID match
      if (c.chandaTargetId != null && c.chandaTargetId == target.id) {
        return true;
      }
      // 2. Exact user ID match (with compatible event)
      if (target.userId != null && c.userId != null && c.userId == target.userId && isEventCompatible(target.eventId, c.eventId)) {
        return true;
      }
      // 3. Event match + Phone Number match (exact 10 digits comparison)
      if (isEventCompatible(target.eventId, c.eventId) && cleanTargetPhone != null && cleanTargetPhone.isNotEmpty) {
        final cleanCollPhone = c.mobileNumber?.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanCollPhone != null && cleanCollPhone.isNotEmpty && cleanCollPhone == cleanTargetPhone) {
          return true;
        }
      }
      // 4. Event match + Name/Alias match
      if (isEventCompatible(target.eventId, c.eventId)) {
        if (_matchesPersonName(target.personName, c.donorName)) {
          return true;
        }
      }
      return false;
    }).toList();

    // Paid amount is strictly from APPROVED collections only
    final paidAmount = linked
        .where((c) => c.isApproved)
        .fold<int>(0, (acc, c) => acc + c.amount);

    return ChandaTargetWithProgress(
      target: target,
      paidAmount: paidAmount,
      linkedCollections: linked,
    );
  }).toList();
});

final userChandaTargetProvider = Provider.family<ChandaTargetWithProgress?, String>((ref, userId) {
  final list = ref.watch(chandaWithProgressListProvider);
  try {
    return list.firstWhere((item) => item.target.userId == userId);
  } catch (_) {
    return null;
  }
});

class ChandaSummary {
  final int totalTarget;
  final int totalCollected;
  final int totalRemaining;
  final int totalExcess;
  final int totalMembers;
  final int fullyPaidCount;
  final int partialPaidCount;
  final int pendingCount;
  final int missingPhoneCount;

  const ChandaSummary({
    required this.totalTarget,
    required this.totalCollected,
    required this.totalRemaining,
    required this.totalExcess,
    required this.totalMembers,
    required this.fullyPaidCount,
    required this.partialPaidCount,
    required this.pendingCount,
    required this.missingPhoneCount,
  });

  double get overallProgress {
    if (totalTarget <= 0) return 0.0;
    final p = totalCollected / totalTarget;
    return p > 1.0 ? 1.0 : p;
  }

  double get achievementPercentage {
    if (totalTarget <= 0) return 0.0;
    return (totalCollected / totalTarget) * 100.0;
  }
}

final chandaSummaryProvider = Provider<ChandaSummary>((ref) {
  final list = ref.watch(chandaWithProgressListProvider);

  int totalTarget = 0;
  int totalCollected = 0;
  int totalRemaining = 0;
  int totalExcess = 0;
  int fullyPaid = 0;
  int partial = 0;
  int pending = 0;
  int missingPhone = 0;

  for (final item in list) {
    if (item.isCancelled) continue;
    totalTarget += item.targetAmount;
    totalCollected += item.paidAmount;
    totalRemaining += item.remainingAmount;
    totalExcess += item.excessAmount;

    if (item.isFullyPaid) {
      fullyPaid++;
    } else if (item.isPartial) {
      partial++;
    } else {
      pending++;
    }

    final phone = item.target.mobileNumber?.trim();
    if (phone == null || phone.isEmpty) {
      missingPhone++;
    }
  }

  return ChandaSummary(
    totalTarget: totalTarget,
    totalCollected: totalCollected,
    totalRemaining: totalRemaining,
    totalExcess: totalExcess,
    totalMembers: list.length,
    fullyPaidCount: fullyPaid,
    partialPaidCount: partial,
    pendingCount: pending,
    missingPhoneCount: missingPhone,
  );
});

enum ChandaFilterType {
  all,
  pending,
  partial,
  fullyPaid,
  excess,
  missingPhone,
}

enum ChandaSortOption {
  nameAsc,
  nameDesc,
  targetHighToLow,
  targetLowToHigh,
  paidHighToLow,
  remainingHighToLow,
  recentlyAdded,
}

extension ChandaSortOptionExt on ChandaSortOption {
  String get displayName {
    switch (this) {
      case ChandaSortOption.nameAsc:
        return 'Name (A to Z)';
      case ChandaSortOption.nameDesc:
        return 'Name (Z to A)';
      case ChandaSortOption.targetHighToLow:
        return 'Highest Target (₹)';
      case ChandaSortOption.targetLowToHigh:
        return 'Lowest Target (₹)';
      case ChandaSortOption.paidHighToLow:
        return 'Highest Paid (₹)';
      case ChandaSortOption.remainingHighToLow:
        return 'Highest Pending / Baki (₹)';
      case ChandaSortOption.recentlyAdded:
        return 'Recently Added';
    }
  }
}

final chandaFilterProvider = StateProvider<ChandaFilterType>((ref) => ChandaFilterType.all);
final chandaSortOptionProvider = StateProvider<ChandaSortOption>((ref) => ChandaSortOption.nameAsc);
final chandaSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredChandaListProvider = Provider<List<ChandaTargetWithProgress>>((ref) {
  final list = ref.watch(chandaWithProgressListProvider);
  final filter = ref.watch(chandaFilterProvider);
  final sort = ref.watch(chandaSortOptionProvider);
  final query = ref.watch(chandaSearchQueryProvider).trim().toLowerCase();

  final filtered = list.where((item) {
    // 1. Status & Attribute Filter
    switch (filter) {
      case ChandaFilterType.all:
        break;
      case ChandaFilterType.pending:
        if (!item.isPending) return false;
        break;
      case ChandaFilterType.partial:
        if (!item.isPartial) return false;
        break;
      case ChandaFilterType.fullyPaid:
        if (!item.isFullyPaid) return false;
        break;
      case ChandaFilterType.excess:
        if (!item.hasExcess) return false;
        break;
      case ChandaFilterType.missingPhone:
        final phone = item.target.mobileNumber?.trim();
        if (phone != null && phone.isNotEmpty) return false;
        break;
    }

    // 2. Search Query (matches Name or Mobile Number)
    if (query.isNotEmpty) {
      final nameMatches = item.target.personName.toLowerCase().contains(query);
      final cleanQuery = query.replaceAll(RegExp(r'\D'), '');
      final cleanPhone = item.target.mobileNumber?.replaceAll(RegExp(r'\D'), '') ?? '';
      final mobileMatches = (cleanQuery.isNotEmpty && cleanPhone.contains(cleanQuery)) ||
          (item.target.mobileNumber?.toLowerCase().contains(query) ?? false);
      return nameMatches || mobileMatches;
    }

    return true;
  }).toList();

  // 3. Sorting
  switch (sort) {
    case ChandaSortOption.nameAsc:
      filtered.sort((a, b) => a.target.personName.toLowerCase().compareTo(b.target.personName.toLowerCase()));
      break;
    case ChandaSortOption.nameDesc:
      filtered.sort((a, b) => b.target.personName.toLowerCase().compareTo(a.target.personName.toLowerCase()));
      break;
    case ChandaSortOption.targetHighToLow:
      filtered.sort((a, b) => b.targetAmount.compareTo(a.targetAmount));
      break;
    case ChandaSortOption.targetLowToHigh:
      filtered.sort((a, b) => a.targetAmount.compareTo(b.targetAmount));
      break;
    case ChandaSortOption.paidHighToLow:
      filtered.sort((a, b) => b.paidAmount.compareTo(a.paidAmount));
      break;
    case ChandaSortOption.remainingHighToLow:
      filtered.sort((a, b) => b.remainingAmount.compareTo(a.remainingAmount));
      break;
    case ChandaSortOption.recentlyAdded:
      filtered.sort((a, b) => b.target.createdAt.compareTo(a.target.createdAt));
      break;
  }

  return filtered;
});
