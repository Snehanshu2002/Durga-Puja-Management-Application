import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../../../../core/error/app_exception.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpensesByEventId(String eventId);
  Future<List<ExpenseModel>> getPendingExpenses(String eventId);
  Future<ExpenseModel?> getExpenseById(String id);
  Future<void> createExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<void> updateExpenseStatusInTransaction({
    required String expenseId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  });
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExpenseRemoteDataSourceImpl(this._firestore);

  CollectionReference get _expensesRef => _firestore.collection('expenses');

  @override
  Future<void> deleteExpense(String id) async {
    await _expensesRef.doc(id).delete();
  }

  List<String> _getEventIdsToQuery(String eventId) {
    if (eventId == 'bhasani_utsab_2026' || eventId == 'event_2026') {
      return ['bhasani_utsab_2026', 'event_2026'];
    }
    return [eventId];
  }

  @override
  Future<List<ExpenseModel>> getExpensesByEventId(String eventId) async {
    final eventIds = _getEventIdsToQuery(eventId);
    final snapshot = await _expensesRef
        .where('eventId', whereIn: eventIds)
        .get();
    final docs = snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
    docs.sort((a, b) => b.date.compareTo(a.date));
    return docs;
  }

  @override
  Future<List<ExpenseModel>> getPendingExpenses(String eventId) async {
    final eventIds = _getEventIdsToQuery(eventId);
    final snapshot = await _expensesRef
        .where('eventId', whereIn: eventIds)
        .where('status', isEqualTo: 'PENDING')
        .get();
    final docs = snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
    docs.sort((a, b) => b.date.compareTo(a.date));
    return docs;
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    final doc = await _expensesRef.doc(id).get();
    if (!doc.exists) return null;
    return ExpenseModel.fromFirestore(doc);
  }

  @override
  Future<void> createExpense(ExpenseModel expense) async {
    final docRef = expense.id.isNotEmpty
        ? _expensesRef.doc(expense.id)
        : _expensesRef.doc();

    final newDoc = ExpenseModel(
      id: docRef.id,
      eventId: expense.eventId,
      categoryId: expense.categoryId,
      description: expense.description.trim(),
      amount: expense.amount,
      paidTo: expense.paidTo.trim(),
      paymentMode: expense.paymentMode,
      date: expense.date,
      remark: expense.remark?.trim(),
      billUrl: expense.billUrl,
      status: expense.status,
      addedBy: expense.addedBy,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );

    await docRef.set(newDoc.toFirestore());
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final docRef = _expensesRef.doc(expense.id);
    await docRef.set(expense.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> updateExpenseStatusInTransaction({
    required String expenseId,
    required String status,
    required String reviewerUid,
    String? rejectionReason,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final docRef = _expensesRef.doc(expenseId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw const AppException('Expense record does not exist.');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentStatus = data['status'] ?? 'PENDING';

      if (currentStatus != 'PENDING') {
        throw AppException('Expense is already $currentStatus.');
      }

      final updates = <String, dynamic>{
        'status': status,
        'approvedBy': reviewerUid,
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (rejectionReason != null) {
        updates['rejectionReason'] = rejectionReason;
      }

      transaction.update(docRef, updates);
    });
  }
}
