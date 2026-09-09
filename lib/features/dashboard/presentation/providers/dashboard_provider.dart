import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/features/approval/presentation/providers/approval_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/services/financial_calculation_service.dart';
import '../widgets/date_filter_selector.dart';

final dashboardDateRangeProvider = StateProvider<DashboardDateRange>((ref) {
  return DashboardDateRange.thisPuja;
});

final financialCalculationServiceProvider = Provider<FinancialCalculationService>((ref) {
  return FinancialCalculationService();
});

final dashboardProvider = FutureProvider<FinancialSummary?>((ref) async {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) return null;

  final collectionRepo = ref.watch(collectionRepositoryProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final calcService = ref.watch(financialCalculationServiceProvider);

  try {
    final collections = await collectionRepo.getCollectionsByEventId(activeEvent.id);
    final expenses = await expenseRepo.getExpensesByEventId(activeEvent.id);

    return calcService.calculateSummary(
      eventId: activeEvent.id,
      eventName: activeEvent.name,
      collections: collections,
      expenses: expenses,
    );
  } catch (e, stack) {
    debugPrint('[DashboardProvider Error] $e\n$stack');
    return calcService.calculateSummary(
      eventId: activeEvent.id,
      eventName: activeEvent.name,
      collections: [],
      expenses: [],
    );
  }
});
