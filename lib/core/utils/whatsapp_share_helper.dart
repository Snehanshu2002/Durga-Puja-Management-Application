import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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

  /// Template A: Chanda Due / Pledge Reminder
  static String formatChandaDueReminder({
    required String orgName,
    required String eventName,
    required int eventYear,
    required String memberName,
    required int targetAmount,
    required int paidAmount,
    required int remainingAmount,
  }) {
    // Remove "Pradhan" from member name in greeting as requested
    final cleanedName = memberName.replaceAll(RegExp(r'\s*\bpradhan\b', caseSensitive: false), '').trim();
    final nameToUse = cleanedName.isNotEmpty ? cleanedName : memberName;

    return '''
🙏 Jay Maa Durga Devi 🙏

Namaskar $nameToUse bhai,

Durga Puja Chanda Details:
Target: ₹$targetAmount
Paid: ₹$paidAmount
Pending: ₹$remainingAmount

Dhanyawad 🙏'''.trim();
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
  }) {
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
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

  /// Convenience helper for donation receipt sharing
  static Future<bool> shareReceiptToWhatsApp({
    BuildContext? context,
    required dynamic collection,
    required String eventName,
    String committeeName = 'Durga Puja Committee',
    String? receiptNumber,
  }) async {
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
