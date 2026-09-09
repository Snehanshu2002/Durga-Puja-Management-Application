import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_entity.dart';

class ReportCsvExportService {
  static String exportCollectionsToCsv(List<CollectionEntity> collections) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final List<List<dynamic>> rows = [
      [
        'Receipt No',
        'Date',
        'Donor Name',
        'Mobile',
        'Amount',
        'Payment Mode',
        'Transaction ID',
        'Purpose',
        'Collected By',
        'Status'
      ],
    ];

    for (final col in collections) {
      rows.add([
        col.id,
        dateFormat.format(col.date),
        col.donorName,
        col.mobileNumber ?? '',
        col.amount,
        col.paymentMode.label,
        col.transactionId ?? '',
        col.purpose,
        col.collectedBy,
        col.status,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  static String exportExpensesToCsv(List<ExpenseEntity> expenses) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final List<List<dynamic>> rows = [
      [
        'Expense ID',
        'Date',
        'Category',
        'Description',
        'Paid To',
        'Amount',
        'Payment Mode',
        'Added By',
        'Status'
      ],
    ];

    for (final exp in expenses) {
      rows.add([
        exp.id,
        dateFormat.format(exp.date),
        exp.categoryId,
        exp.description,
        exp.paidTo,
        exp.amount,
        exp.paymentMode.label,
        exp.addedBy,
        exp.status,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
