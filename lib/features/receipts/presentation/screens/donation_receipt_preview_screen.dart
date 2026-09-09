import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:durgapuja_manager/core/utils/whatsapp_share_helper.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import '../../domain/services/receipt_pdf_service.dart';

class DonationReceiptPreviewScreen extends StatelessWidget {
  final CollectionEntity collection;
  final String eventName;
  final String committeeName;
  final String reviewerRoleName;
  final String? receiptNumber;

  const DonationReceiptPreviewScreen({
    super.key,
    required this.collection,
    required this.eventName,
    this.committeeName = 'Durga Puja Committee',
    this.reviewerRoleName = 'Treasurer',
    this.receiptNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Receipt Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'Share on WhatsApp / Email',
            onPressed: () async {
              await WhatsAppShareHelper.shareReceiptToWhatsApp(
                collection: collection,
                eventName: eventName,
                committeeName: committeeName,
                receiptNumber: receiptNumber,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PdfPreview(
        build: (format) => ReceiptPdfService.generateDonationReceipt(
          collection: collection,
          eventName: eventName,
          committeeName: committeeName,
          reviewerRoleName: reviewerRoleName,
          receiptNumber: receiptNumber,
        ),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}
