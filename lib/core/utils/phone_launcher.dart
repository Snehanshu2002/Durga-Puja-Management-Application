import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneLauncher {
  /// Opens the device dialer with the provided phone number.
  static Future<void> makePhoneCall(BuildContext context, String rawPhone) async {
    final cleaned = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid phone number')),
        );
      }
      return;
    }

    final uri = Uri.parse('tel:$cleaned');
    try {
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!success && context.mounted) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone dialer: $rawPhone')),
        );
      }
    }
  }
}
