import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/expense_remote_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../puja_event/presentation/providers/puja_event_provider.dart';

final expenseRemoteDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dataSource = ref.watch(expenseRemoteDataSourceProvider);
  return ExpenseRepositoryImpl(dataSource);
});

final expensesProvider = StreamProvider<List<ExpenseEntity>>((ref) async* {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) {
    yield [];
    return;
  }

  try {
    final repo = ref.watch(expenseRepositoryProvider);
    final expenses = await repo.getExpensesByEventId(activeEvent.id);
    yield expenses;
  } catch (e) {
    yield [];
  }
});

final pendingExpensesProvider = StreamProvider<List<ExpenseEntity>>((ref) async* {
  final activeEvent = ref.watch(activePujaEventProvider);
  if (activeEvent == null) {
    yield [];
    return;
  }

  try {
    final repo = ref.watch(expenseRepositoryProvider);
    final pending = await repo.getPendingExpenses(activeEvent.id);
    yield pending;
  } catch (e) {
    yield [];
  }
});
