import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', 'English', '🌐'),
  bengali('bn', 'বাংলা', '🪔'),
  hindi('hi', 'हिंदी', '🇮🇳'),
  odia('or', 'ଓଡ଼ିଆ', '🌺');

  final String code;
  final String displayName;
  final String icon;

  const AppLanguage(this.code, this.displayName, this.icon);
}

const _kLanguageKey = 'app_selected_language';

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_kLanguageKey);
      if (code != null) {
        final matched = AppLanguage.values.firstWhere(
          (l) => l.code == code,
          orElse: () => AppLanguage.english,
        );
        state = matched;
      }
    } catch (_) {
      // Ignore prefs error and retain default
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLanguageKey, language.code);
    } catch (_) {}
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});
