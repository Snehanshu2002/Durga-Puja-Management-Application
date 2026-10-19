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

class WhatsAppConfig {
  final WhatsAppMessageLanguage language;
  final bool includePaymentQr;
  final String upiId;
  final String payeeName;
  final String qrImageUrl;
  final String? customNote;

  const WhatsAppConfig({
    this.language = WhatsAppMessageLanguage.odia,
    this.includePaymentQr = true,
    this.upiId = '7735382544-7@axl',
    this.payeeName = 'SNEHANSHU SEKHAR SAHOO',
    this.qrImageUrl = 'https://durga-puja-manager.web.app/payment_qr.jpg',
    this.customNote,
  });

  WhatsAppConfig copyWith({
    WhatsAppMessageLanguage? language,
    bool? includePaymentQr,
    String? upiId,
    String? payeeName,
    String? qrImageUrl,
    String? customNote,
  }) {
    return WhatsAppConfig(
      language: language ?? this.language,
      includePaymentQr: includePaymentQr ?? this.includePaymentQr,
      upiId: upiId ?? this.upiId,
      payeeName: payeeName ?? this.payeeName,
      qrImageUrl: qrImageUrl ?? this.qrImageUrl,
      customNote: customNote ?? this.customNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language.code,
      'includePaymentQr': includePaymentQr,
      'upiId': upiId,
      'payeeName': payeeName,
      'qrImageUrl': qrImageUrl,
      if (customNote != null) 'customNote': customNote,
    };
  }

  factory WhatsAppConfig.fromMap(Map<String, dynamic> map) {
    return WhatsAppConfig(
      language: WhatsAppMessageLanguage.fromCode(map['language'] as String?),
      includePaymentQr: map['includePaymentQr'] as bool? ?? true,
      upiId: map['upiId'] as String? ?? '7735382544-7@axl',
      payeeName: map['payeeName'] as String? ?? 'SNEHANSHU SEKHAR SAHOO',
      qrImageUrl: map['qrImageUrl'] as String? ?? 'https://durga-puja-manager.web.app/payment_qr.jpg',
      customNote: map['customNote'] as String?,
    );
  }
}

const String _kWhatsAppLangPrefKey = 'whatsapp_message_language';
const String _kIncludePaymentQrPrefKey = 'whatsapp_include_payment_qr';
const String _kUpiIdPrefKey = 'whatsapp_upi_id';
const String _kPayeeNamePrefKey = 'whatsapp_payee_name';
const String _kQrImageUrlPrefKey = 'whatsapp_qr_image_url';
const String _kCustomNotePrefKey = 'whatsapp_custom_note';

const String _kSettingsDocPath = 'settings/whatsapp_settings';

class WhatsAppSettingsNotifier extends StateNotifier<WhatsAppConfig> {
  StreamSubscription<DocumentSnapshot>? _subscription;

  WhatsAppSettingsNotifier() : super(const WhatsAppConfig()) {
    _init();
  }

  Future<void> _init() async {
    // 1. Load from local cache first for instant responsiveness
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_kWhatsAppLangPrefKey);
      final savedIncludeQr = prefs.getBool(_kIncludePaymentQrPrefKey);
      final savedUpiId = prefs.getString(_kUpiIdPrefKey);
      final savedPayee = prefs.getString(_kPayeeNamePrefKey);
      final savedQrUrl = prefs.getString(_kQrImageUrlPrefKey);
      final savedNote = prefs.getString(_kCustomNotePrefKey);

      state = state.copyWith(
        language: savedCode != null ? WhatsAppMessageLanguage.fromCode(savedCode) : null,
        includePaymentQr: savedIncludeQr,
        upiId: savedUpiId,
        payeeName: savedPayee,
        qrImageUrl: savedQrUrl,
        customNote: savedNote,
      );
    } catch (_) {}

    // 2. Listen to Firestore settings/whatsapp_settings for real-time cloud sync
    try {
      _subscription = FirebaseFirestore.instance
          .doc(_kSettingsDocPath)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;
          final parsed = WhatsAppConfig.fromMap(data);
          state = parsed;

          SharedPreferences.getInstance().then((prefs) {
            prefs.setString(_kWhatsAppLangPrefKey, parsed.language.code);
            prefs.setBool(_kIncludePaymentQrPrefKey, parsed.includePaymentQr);
            prefs.setString(_kUpiIdPrefKey, parsed.upiId);
            prefs.setString(_kPayeeNamePrefKey, parsed.payeeName);
            prefs.setString(_kQrImageUrlPrefKey, parsed.qrImageUrl);
            if (parsed.customNote != null) {
              prefs.setString(_kCustomNotePrefKey, parsed.customNote!);
            }
          }).catchError((_) {});
        }
      });
    } catch (_) {}
  }

  Future<void> setLanguage(WhatsAppMessageLanguage language, {String? updatedBy}) async {
    await updateConfig(language: language, updatedBy: updatedBy);
  }

  Future<void> updateConfig({
    WhatsAppMessageLanguage? language,
    bool? includePaymentQr,
    String? upiId,
    String? payeeName,
    String? qrImageUrl,
    String? customNote,
    String? updatedBy,
  }) async {
    final updated = state.copyWith(
      language: language,
      includePaymentQr: includePaymentQr,
      upiId: upiId,
      payeeName: payeeName,
      qrImageUrl: qrImageUrl,
      customNote: customNote,
    );
    state = updated;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kWhatsAppLangPrefKey, updated.language.code);
      await prefs.setBool(_kIncludePaymentQrPrefKey, updated.includePaymentQr);
      await prefs.setString(_kUpiIdPrefKey, updated.upiId);
      await prefs.setString(_kPayeeNamePrefKey, updated.payeeName);
      await prefs.setString(_kQrImageUrlPrefKey, updated.qrImageUrl);
      if (updated.customNote != null) {
        await prefs.setString(_kCustomNotePrefKey, updated.customNote!);
      }
    } catch (_) {}

    try {
      final payload = updated.toMap();
      payload['updatedAt'] = FieldValue.serverTimestamp();
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
    StateNotifierProvider<WhatsAppSettingsNotifier, WhatsAppConfig>((ref) {
  return WhatsAppSettingsNotifier();
});
