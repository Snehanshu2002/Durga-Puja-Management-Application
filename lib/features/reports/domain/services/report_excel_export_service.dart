import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_entity.dart';

class ReportExcelExportService {
  static List<int>? exportCollectionsToExcel({
    required List<CollectionEntity> collections,
    required String eventName,
  }) {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Collections'];
    excel.delete('Sheet1'); // Remove default sheet

    final dateFormat = DateFormat('yyyy-MM-dd');

    // Header
    sheet.appendRow([
      TextCellValue('Receipt No'),
      TextCellValue('Date'),
      TextCellValue('Donor Name'),
      TextCellValue('Mobile'),
      TextCellValue('Amount (INR)'),
      TextCellValue('Payment Mode'),
      TextCellValue('Transaction ID'),
      TextCellValue('Purpose'),
      TextCellValue('Collected By'),
      TextCellValue('Status'),
    ]);

    for (final col in collections) {
      sheet.appendRow([
        TextCellValue(col.id),
        TextCellValue(dateFormat.format(col.date)),
        TextCellValue(col.donorName),
        TextCellValue(col.mobileNumber ?? ''),
        IntCellValue(col.amount),
        TextCellValue(col.paymentMode.label),
        TextCellValue(col.transactionId ?? ''),
        TextCellValue(col.purpose),
        TextCellValue(col.collectedBy),
        TextCellValue(col.status),
      ]);
    }

    return excel.encode();
  }

  static List<int>? exportExpensesToExcel({
    required List<ExpenseEntity> expenses,
    required String eventName,
  }) {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Expenses'];
    excel.delete('Sheet1');

    final dateFormat = DateFormat('yyyy-MM-dd');

    sheet.appendRow([
      TextCellValue('Expense ID'),
      TextCellValue('Date'),
      TextCellValue('Category'),
      TextCellValue('Description'),
      TextCellValue('Paid To'),
      TextCellValue('Amount (INR)'),
      TextCellValue('Payment Mode'),
      TextCellValue('Added By'),
      TextCellValue('Status'),
    ]);

    for (final exp in expenses) {
      sheet.appendRow([
        TextCellValue(exp.id),
        TextCellValue(dateFormat.format(exp.date)),
        TextCellValue(exp.categoryId),
        TextCellValue(exp.description),
        TextCellValue(exp.paidTo),
        IntCellValue(exp.amount),
        TextCellValue(exp.paymentMode.label),
        TextCellValue(exp.addedBy),
        TextCellValue(exp.status),
      ]);
    }

    return excel.encode();
  }
}
