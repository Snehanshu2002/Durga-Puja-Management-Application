import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/dashboard/domain/entities/financial_summary.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_entity.dart';

class ReportPdfExportService {
  static Future<Uint8List> generateFinancialSummaryPdf({
    required FinancialSummary summary,
    required List<CollectionEntity> collections,
    required List<ExpenseEntity> expenses,
    required String committeeName,
    required String generatedBy,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final itemDateFormat = DateFormat('dd MMM yyyy');
    final formattedDate = dateFormat.format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  committeeName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red900,
                  ),
                ),
                pw.Text(
                  'Event: ${summary.eventName}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.red900, thickness: 1.5),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey400),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated on $formattedDate by $generatedBy',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'OFFICIAL FINANCIAL & COLLECTION REPORT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
          ),
          pw.SizedBox(height: 14),

          // Summary Overview Box
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              children: [
                _buildRow('Total Approved Collection', MoneyFormatter.formatForPdf(summary.totalApprovedCollection), valueColor: PdfColors.green800),
                _buildRow('Total Approved Expense', MoneyFormatter.formatForPdf(summary.totalApprovedExpense), valueColor: PdfColors.red800),
                pw.Divider(),
                _buildRow(
                  summary.isDeficit ? 'Deficit Balance' : 'Net Balance',
                  MoneyFormatter.formatForPdf(summary.currentBalance),
                  valueColor: summary.isDeficit ? PdfColors.red900 : PdfColors.blue900,
                  isBold: true,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Itemized Donor-Wise Collections List Section
          pw.Text(
            'Itemized Donor & Public Collections (${collections.length} entries)',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.red900),
          ),
          pw.SizedBox(height: 6),

          if (collections.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Text('No collection entries recorded yet.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Donor Name', 'Mobile', 'Purpose', 'Mode', 'Amount', 'Status'],
              data: collections.map((col) {
                return [
                  itemDateFormat.format(col.date),
                  col.donorName,
                  col.mobileNumber ?? '-',
                  col.purpose,
                  col.paymentMode.label,
                  MoneyFormatter.formatForPdf(col.amount),
                  col.status,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.red900),
              cellStyle: const pw.TextStyle(fontSize: 8),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
            ),

          pw.SizedBox(height: 16),

          // Itemized Expenses List Section
          if (expenses.isNotEmpty) ...[
            pw.Text(
              'Itemized Puja Expenses (${expenses.length} entries)',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.red900),
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Paid To', 'Category', 'Description', 'Mode', 'Amount', 'Status'],
              data: expenses.map((exp) {
                return [
                  itemDateFormat.format(exp.date),
                  exp.paidTo,
                  exp.categoryId,
                  exp.description,
                  exp.paymentMode.label,
                  MoneyFormatter.formatForPdf(exp.amount),
                  exp.status,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
              cellStyle: const pw.TextStyle(fontSize: 8),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
            ),
            pw.SizedBox(height: 16),
          ],

          pw.Text(
            '* Official Financial Rule: Only APPROVED transactions are included in total collection, total expense, and balance calculations.',
            style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildRow(String title, String value, {PdfColor? valueColor, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: valueColor ?? PdfColors.black)),
        ],
      ),
    );
  }
}
