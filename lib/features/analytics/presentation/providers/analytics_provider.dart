import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/features/approval/presentation/providers/approval_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/services/analytics_calculation_service.dart';

final analyticsCalculationServiceProvider = Provider<AnalyticsCalculationService>((ref) {
  return AnalyticsCalculationService();
});

final analyticsProvider = FutureProvider<AnalyticsData?>((ref) async {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) return null;

  final collectionRepo = ref.watch(collectionRepositoryProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final calcService = ref.watch(analyticsCalculationServiceProvider);

  final collections = await collectionRepo.getCollectionsByEventId(activeEvent.id);
  final expenses = await expenseRepo.getExpensesByEventId(activeEvent.id);

  return calcService.calculateAnalytics(
    collections: collections,
    expenses: expenses,
  );
});
