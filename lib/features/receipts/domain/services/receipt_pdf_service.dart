import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/utils/number_to_words.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';

class ReceiptPdfService {
  static Future<Uint8List> generateDonationReceipt({
    required CollectionEntity collection,
    required String eventName,
    required String committeeName,
    required String reviewerRoleName,
    String? receiptNumber,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMMM yyyy');
    final formattedDate = dateFormat.format(collection.date);
    final amountWords = NumberToWords.convert(collection.amount);
    final displayReceiptNo = receiptNumber ??
        'DP-${collection.date.year}-${collection.id.substring(0, 6).toUpperCase()}';

    const brandColor = PdfColor.fromInt(0xFF1E3A8A); // Royal Indigo

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: 450,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: brandColor, width: 2),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    committeeName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: brandColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    eventName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: brandColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'DONATION RECEIPT',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.Divider(color: brandColor, thickness: 1.5),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Receipt No: $displayReceiptNo',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: brandColor,
                        ),
                      ),
                      pw.Text(
                        'Date: $formattedDate',
                        style: const pw.TextStyle(color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),
                  _buildPdfDetailRow('Received From:', collection.donorName, isHeader: true),
                  if (collection.mobileNumber != null && collection.mobileNumber!.isNotEmpty)
                    _buildPdfDetailRow('Mobile:', collection.mobileNumber!),
                  _buildPdfDetailRow(
                    'Amount:',
                    MoneyFormatter.formatForPdf(collection.amount),
                    valueColor: PdfColors.green800,
                    isHeader: true,
                  ),
                  _buildPdfDetailRow('Amount in Words:', amountWords),
                  _buildPdfDetailRow('Payment Mode:', collection.paymentMode.label),
                  if (collection.transactionId != null && collection.transactionId!.isNotEmpty)
                    _buildPdfDetailRow('Transaction ID:', collection.transactionId!),
                  _buildPdfDetailRow('Purpose:', collection.purpose),
                  _buildPdfDetailRow('Collected By:', collection.collectedBy),
                  _buildPdfDetailRow('Approved By:', reviewerRoleName),
                  pw.SizedBox(height: 24),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Thank you for your generous contribution!',
                        style: pw.TextStyle(
                          fontStyle: pw.FontStyle.italic,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Authorized Signatory',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfDetailRow(
    String label,
    String value, {
    bool isHeader = false,
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: isHeader ? 12 : 10,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
                fontSize: isHeader ? 12 : 10,
                color: valueColor ?? PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
