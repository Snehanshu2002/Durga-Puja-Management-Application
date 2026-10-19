import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:durgapuja_manager/core/providers/whatsapp_settings_provider.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';

class WhatsAppShareHelper {
  /// Clean phone number for international WhatsApp wa.me links.
  /// Standard Indian 10-digit numbers get prefixed with country code 91.
  static String cleanPhoneNumber(String? raw) {
    if (raw == null) return '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '91$digits';
    }
    return digits;
  }

  /// Get the currently saved WhatsApp language from local preferences
  static Future<WhatsAppMessageLanguage> getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString('whatsapp_message_language');
      return WhatsAppMessageLanguage.fromCode(code);
    } catch (_) {
      return WhatsAppMessageLanguage.odia;
    }
  }

  /// Get the currently saved WhatsApp configuration from local preferences
  static Future<WhatsAppConfig> getSavedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString('whatsapp_message_language');
      final includeQr = prefs.getBool('whatsapp_include_payment_qr') ?? true;
      final upiId = prefs.getString('whatsapp_upi_id') ?? '7735382544-7@axl';
      final payee = prefs.getString('whatsapp_payee_name') ?? 'SNEHANSHU SEKHAR SAHOO';
      final qrUrl = prefs.getString('whatsapp_qr_image_url') ?? 'https://durga-puja-manager.web.app/payment_qr.jpg';
      final note = prefs.getString('whatsapp_custom_note');

      return WhatsAppConfig(
        language: WhatsAppMessageLanguage.fromCode(code),
        includePaymentQr: includeQr,
        upiId: upiId,
        payeeName: payee,
        qrImageUrl: qrUrl,
        customNote: note,
      );
    } catch (_) {
      return const WhatsAppConfig();
    }
  }

  /// Template A: Chanda Due / Pledge Reminder with optional QR Scanner and screenshot instructions
  static String formatChandaDueReminder({
    required String orgName,
    required String eventName,
    required int eventYear,
    required String memberName,
    required int targetAmount,
    required int paidAmount,
    required int remainingAmount,
    WhatsAppMessageLanguage language = WhatsAppMessageLanguage.odia,
    WhatsAppConfig? config,
    bool? includePaymentQr,
    String? upiId,
    String? payeeName,
    String? qrImageUrl,
    String? customScreenshotNote,
  }) {
    // If a full WhatsAppConfig is supplied, extract defaults from it
    final effectiveLang = config?.language ?? language;
    final effectiveIncludeQr = includePaymentQr ?? config?.includePaymentQr ?? true;
    final effectiveUpiId = upiId ?? config?.upiId ?? '7735382544-7@axl';
    final effectivePayee = payeeName ?? config?.payeeName ?? 'SNEHANSHU SEKHAR SAHOO';
    final effectiveQrUrl = qrImageUrl ?? config?.qrImageUrl ?? 'https://durga-puja-manager.web.app/payment_qr.jpg';
    final effectiveNote = customScreenshotNote ?? config?.customNote;

    // Remove "Pradhan" from member name in greeting as requested
    final cleanedName = memberName.replaceAll(RegExp(r'\s*\bpradhan\b', caseSensitive: false), '').trim();
    final nameToUse = cleanedName.isNotEmpty ? cleanedName : memberName;
    final isPaid = remainingAmount <= 0;

    if (effectiveLang == WhatsAppMessageLanguage.english) {
      final buffer = StringBuffer();
      buffer.writeln('🙏 Jay Maa Durga Devi 🙏');
      buffer.writeln();
      buffer.writeln('Namaskar $nameToUse bhai,');
      buffer.writeln();
      buffer.writeln('Durga Puja Chanda Details:');
      buffer.writeln('Target: ₹$targetAmount');
      buffer.writeln('Paid: ₹$paidAmount');
      buffer.writeln('Pending: ₹$remainingAmount');

      if (!isPaid && effectiveIncludeQr) {
        buffer.writeln();
        buffer.writeln('📲 Scan & Pay using QR Code (PhonePe / GPay / Paytm):');
        buffer.writeln('UPI ID: $effectiveUpiId ($effectivePayee)');
        buffer.writeln('QR Scanner: $effectiveQrUrl');
        buffer.writeln();
        buffer.writeln('⚠️ Note:');
        buffer.writeln(effectiveNote ?? 'After payment, please send the payment screenshot on this number or committee WhatsApp group.');
      }

      buffer.writeln();
      if (isPaid) {
        buffer.writeln('Thank you for your generous contribution! 🙏');
      } else {
        buffer.writeln('Please clear your pending chanda at your earliest convenience.');
        buffer.writeln('Dhanyawad 🙏');
      }
      return buffer.toString().trim();
    }

    // Default Odia format
    final buffer = StringBuffer();
    buffer.writeln('🙏 ଜୟ ମା ଦୁର୍ଗା 🙏');
    buffer.writeln();
    buffer.writeln('ନମସ୍କାର $nameToUse ଭାଇ,');
    buffer.writeln();
    buffer.writeln('ଦୁର୍ଗା ପୂଜା ଚାନ୍ଦା ବିବରଣୀ:');
    buffer.writeln('ଧାର୍ଯ୍ୟ ଚାନ୍ଦା (Target): ₹$targetAmount');
    buffer.writeln('ପୈଠ ରାଶି (Paid): ₹$paidAmount');
    buffer.writeln('ବାକି ରାଶି (Pending): ₹$remainingAmount');

    if (!isPaid && effectiveIncludeQr) {
      buffer.writeln();
      buffer.writeln('📲 QR Code ସ୍କାନର୍ରେ Pay କରନ୍ତୁ (PhonePe / GPay / Paytm):');
      buffer.writeln('UPI ID: $effectiveUpiId ($effectivePayee)');
      buffer.writeln('QR Scanner Link: $effectiveQrUrl');
      buffer.writeln();
      buffer.writeln('⚠️ ସୂଚନା:');
      buffer.writeln(effectiveNote ?? 'ପେମେଣ୍ଟ କରିସାରିବା ପରେ Payment Screenshot ଏହି ନମ୍ବର କିମ୍ବା WhatsApp Group ରେ ନିଶ୍ଚୟ ପଠାନ୍ତୁ।');
    }

    buffer.writeln();
    if (isPaid) {
      buffer.writeln('ଆପଣଙ୍କ ସହଯୋଗ ପାଇଁ ଅଶେଷ ଧନ୍ୟବାଦ! 🙏');
    } else {
      buffer.writeln('ଦୟାକରି ଆପଣଙ୍କର ବକେୟା ଚାନ୍ଦା ପୈଠ କରି ସହଯୋଗ କରନ୍ତୁ।');
      buffer.writeln('ଧନ୍ୟବାଦ 🙏');
    }
    return buffer.toString().trim();
  }

  /// Template B: Approved Collection Receipt Acknowledgement
  static String formatCollectionReceipt({
    required String orgName,
    required String eventName,
    required int eventYear,
    required String donorName,
    required int amount,
    required String paymentMode,
    required String receiptNumber,
    required DateTime date,
    required String collectedBy,
    WhatsAppMessageLanguage language = WhatsAppMessageLanguage.odia,
  }) {
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    if (language == WhatsAppMessageLanguage.english) {
      return '''
🙏 Jay Maa Durga Devi 🙏

Donation Receipt Acknowledgement
Organization: $orgName
Event: $eventName ($eventYear)
Receipt No: $receiptNumber
Donor: $donorName
Amount: ₹$amount
Payment Mode: $paymentMode
Status: Approved ✅
Date: $formattedDate
Collected By: $collectedBy

Jay Maa Durga! 🙏'''.trim();
    }

    // Default Odia format
    return '''
🙏 ଜୟ ମା ଦୁର୍ଗା 🙏

ଦୁର୍ଗା ପୂଜା ଚାନ୍ଦା ରସିଦ (Donation Receipt)
ସମିତି: $orgName
ଉତ୍ସବ: $eventName ($eventYear)
ରସିଦ ନଂ: $receiptNumber
ଦାତାଙ୍କ ନାମ: $donorName
ଚାନ୍ଦା ପରିମାଣ: ₹$amount
ପେମେଣ୍ଟ ମୋଡ୍: $paymentMode
ସ୍ଥିତି: ଅନୁମୋଦିତ (Approved ✅)
ତାରିଖ: $formattedDate
ଆଦାୟକାରୀ: $collectedBy

ମା ଦୁର୍ଗା ଆପଣଙ୍କ ଓ ଆପଙ୍କ ପରିବାରର ମଙ୍ଗଳ କରନ୍ତୁ! 🙏'''.trim();
  }

  /// 1-Tap WhatsApp Share with graceful fallback to system share / clipboard
  static Future<bool> shareToWhatsApp({
    required BuildContext context,
    String? phoneNumber,
    required String message,
    VoidCallback? onShareSuccess,
  }) async {
    final cleanPhone = cleanPhoneNumber(phoneNumber);
    final encodedMessage = Uri.encodeComponent(message);

    Uri uri;
    if (cleanPhone.isNotEmpty) {
      uri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');
    } else {
      uri = Uri.parse('https://wa.me/?text=$encodedMessage');
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) {
        onShareSuccess?.call();
        return true;
      }
    } catch (_) {
      // Fallback below
    }

    // Fallback 1: Try custom scheme
    try {
      final schemeUri = cleanPhone.isNotEmpty
          ? Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMessage')
          : Uri.parse('whatsapp://send?text=$encodedMessage');
      final schemeLaunched = await launchUrl(schemeUri, mode: LaunchMode.externalApplication);
      if (schemeLaunched) {
        onShareSuccess?.call();
        return true;
      }
    } catch (_) {
      // Fallback below
    }

    // Fallback 2: System Share sheet + Clipboard Copy
    try {
      await Clipboard.setData(ClipboardData(text: message));
      await Share.share(message, subject: 'Durga Puja Message');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message copied & opened in system share!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
      onShareSuccess?.call();
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share message: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  /// Direct Share of the PhonePe Payment QR Scanner Image File
  static Future<void> sharePaymentQrImage({
    required BuildContext context,
    String? caption,
  }) async {
    try {
      final byteData = await rootBundle.load('assets/images/payment_qr.jpg');
      final bytes = byteData.buffer.asUint8List();
      final xfile = XFile.fromData(
        bytes,
        mimeType: 'image/jpeg',
        name: 'phonepe_durga_puja_qr.jpg',
      );
      final defaultCaption = caption ??
          '🙏 ଜୟ ମା ଦୁର୍ଗା 🙏\nଦୁର୍ଗା ପୂଜା ଚାନ୍ଦା ପେମେଣ୍ଟ QR Scanner (PhonePe / GPay / Paytm)\nUPI ID: 7735382544-7@axl (SNEHANSHU SEKHAR SAHOO)\n⚠️ Payment କଲା ପରେ Screenshot ଏହି ନମ୍ବର କିମ୍ବା WhatsApp Group ରେ ନିଶ୍ଚୟ ପଠାନ୍ତୁ।';
      await Share.shareXFiles([xfile], text: defaultCaption);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share QR image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Interactive Modal Dialog displaying the PhonePe QR Scanner with 1-Tap Share
  static void showPaymentQrDialog(BuildContext context, {WhatsAppConfig? config}) {
    final cfg = config ?? const WhatsAppConfig();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF5f259f), size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'PhonePe Payment QR Scanner',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/payment_qr.jpg',
                    height: 290,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('UPI ID:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(cfg.upiId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF5f259f))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payee Name:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(cfg.payeeName, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment କଲା ପରେ Screenshot ଏହି ନମ୍ବର କିମ୍ବା WhatsApp Group ରେ ନିଶ୍ଚୟ ପଠାନ୍ତୁ।',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              sharePaymentQrImage(context: context);
            },
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Share QR Image'),
          ),
        ],
      ),
    );
  }

  /// Convenience helper for donation receipt sharing
  static Future<bool> shareReceiptToWhatsApp({
    BuildContext? context,
    required dynamic collection,
    required String eventName,
    String committeeName = 'Durga Puja Committee',
    String? receiptNumber,
    WhatsAppMessageLanguage? language,
  }) async {
    final effectiveLang = language ?? await getSavedLanguage();
    final effectiveReceiptNo = receiptNumber ??
        'DP-${collection.date.year}-${collection.id.hashCode.abs().toString().padLeft(6, '0')}';
    final msg = formatCollectionReceipt(
      orgName: committeeName,
      eventName: eventName,
      eventYear: collection.date.year,
      donorName: collection.donorName,
      amount: collection.amount,
      paymentMode: collection.paymentMode.label,
      receiptNumber: effectiveReceiptNo,
      date: collection.date,
      collectedBy: collection.collectedBy,
      language: effectiveLang,
    );

    final cleanPhone = cleanPhoneNumber(collection.mobileNumber);
    final encoded = Uri.encodeComponent(msg);
    final uri = cleanPhone.isNotEmpty
        ? Uri.parse('https://wa.me/$cleanPhone?text=$encoded')
        : Uri.parse('https://wa.me/?text=$encoded');

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return true;
    } catch (_) {}

    try {
      await Share.share(msg, subject: 'Donation Receipt');
      return true;
    } catch (_) {
      return false;
    }
  }
}
