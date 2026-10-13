import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WhatsAppMessageLanguage {
  odia('or', 'ଓଡ଼ିଆ (Odia)', '🌺'),
  english('en', 'English', '🌐');

  final String code;
  final String displayName;
  final String icon;

  const WhatsAppMessageLanguage(this.code, this.displayName, this.icon);

  static WhatsAppMessageLanguage fromCode(String? code) {
    if (code == 'en' || code == 'english') return WhatsAppMessageLanguage.english;
    return WhatsAppMessageLanguage.odia;
  }
}

const String _kWhatsAppLangPrefKey = 'whatsapp_message_language';
const String _kSettingsDocPath = 'settings/whatsapp_settings';

class WhatsAppSettingsNotifier extends StateNotifier<WhatsAppMessageLanguage> {
  StreamSubscription<DocumentSnapshot>? _subscription;

  WhatsAppSettingsNotifier() : super(WhatsAppMessageLanguage.odia) {
    _init();
  }

  Future<void> _init() async {
    // 1. Load from local cache first for instant responsiveness
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_kWhatsAppLangPrefKey);
      if (savedCode != null) {
        state = WhatsAppMessageLanguage.fromCode(savedCode);
      }
    } catch (_) {}

    // 2. Listen to Firestore settings/whatsapp_settings for real-time cloud sync
    try {
      _subscription = FirebaseFirestore.instance
          .doc(_kSettingsDocPath)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;
          final cloudLangCode = data['language'] as String?;
          if (cloudLangCode != null) {
            final parsed = WhatsAppMessageLanguage.fromCode(cloudLangCode);
            state = parsed;
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString(_kWhatsAppLangPrefKey, parsed.code);
            });
          }
        }
      });
    } catch (_) {}
  }

  Future<void> setLanguage(WhatsAppMessageLanguage language, {String? updatedBy}) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kWhatsAppLangPrefKey, language.code);
    } catch (_) {}

    try {
      final payload = <String, dynamic>{
        'language': language.code,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (updatedBy != null) {
        payload['updatedBy'] = updatedBy;
      }
      await FirebaseFirestore.instance.doc(_kSettingsDocPath).set(
        payload,
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final whatsAppSettingsProvider =
    StateNotifierProvider<WhatsAppSettingsNotifier, WhatsAppMessageLanguage>((ref) {
  return WhatsAppSettingsNotifier();
});
