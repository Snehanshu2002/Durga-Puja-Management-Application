import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:durgapuja_manager/core/providers/language_provider.dart';

class DynamicTranslationService {
  static final Map<String, String> _cache = {};

  /// Local dictionary for instant, accurate Odia translations of common Puja terms
  static final Map<String, String> _knownOdiaDictionary = {
    // Categories & Purposes
    'Pandal': 'ମଣ୍ଡପ ସଜାବଟ',
    'Pandal Decoration': 'ମଣ୍ଡପ ସଜାବଟ',
    'Decoration': 'ସଜାବଟ',
    'Pratima': 'ମା\'ଙ୍କ ମୂର୍ତ୍ତି',
    'Idol': 'ମା\'ଙ୍କ ମୂର୍ତ୍ତି',
    'Murti': 'ମା\'ଙ୍କ ମୂର୍ତ୍ତି',
    'Puja Samagri': 'ପୂଜା ସାମଗ୍ରୀ',
    'Puja Material': 'ପୂଜା ସାମଗ୍ରୀ',
    'Bhog': 'ଭୋଗ ଓ ପ୍ରସାଦ',
    'Prasad': 'ଭୋଗ ଓ ପ୍ରସାଦ',
    'Lighting': 'ଆଲୋକ ସଜ୍ଜା',
    'Electric': 'ବିଦ୍ୟୁତ୍ ଓ ଆଲୋକ ସଜ୍ଜା',
    'Sound': 'ମାଇକ୍ ଓ ସାଉଣ୍ଡ',
    'Sound System': 'ମାଇକ୍ ଓ ସାଉଣ୍ଡ ସିଷ୍ଟମ୍',
    'Cultural Program': 'ସାଂସ୍କୃତିକ କାର୍ଯ୍ୟକ୍ରମ',
    'Opera': 'ଯାତ୍ରା / ଅପେରା',
    'Jatra': 'ଯାତ୍ରା / ଅପେରା',
    'Donation': 'ଚାନ୍ଦା',
    'Membership': 'ସଭ୍ୟ ଚାନ୍ଦା',
    'Sponsorship': 'ପ୍ରୟୋଜକ ଚାନ୍ଦା',
    'Cash': 'ନଗଦ (Cash)',
    'UPI': 'ୟୁ.ପି.ଆଇ (UPI)',
    'Bank Transfer': 'ବ୍ୟାଙ୍କ ଟ୍ରାନ୍ସଫର',
    'Cheque': 'ଚେକ୍',
    'Approved': 'ଅନୁମୋଦିତ',
    'Pending': 'ବିଚାରାଧୀନ',
    'Rejected': 'ନାକଚ',
    'Super Admin': 'ମୁଖ୍ୟ ପ୍ରଶାସକ (Super Admin)',
    'Treasurer': 'କୋଷାଧ୍ୟକ୍ଷ (Treasurer)',
    'Collector': 'ଚାନ୍ଦା ସଂଗ୍ରାହକ (Collector)',
    'Viewer': 'ଦର୍ଶକ (Viewer)',
  };

  /// Translate dynamic string using built-in Odia terms or free Google Translate API
  static Future<String> translate(String text, AppLanguage targetLanguage) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || targetLanguage == AppLanguage.english) {
      return text;
    }

    // Check custom Odia dictionary first for authentic terms
    if (targetLanguage == AppLanguage.odia && _knownOdiaDictionary.containsKey(cleanText)) {
      return _knownOdiaDictionary[cleanText]!;
    }

    final cacheKey = '${cleanText}_${targetLanguage.code}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=${targetLanguage.code}&dt=t&q=${Uri.encodeComponent(cleanText)}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        if (json.isNotEmpty && json[0] != null && json[0].isNotEmpty) {
          final StringBuffer sb = StringBuffer();
          for (var item in json[0]) {
            if (item != null && item.isNotEmpty && item[0] != null) {
              sb.write(item[0].toString());
            }
          }
          final translated = sb.toString();
          if (translated.isNotEmpty) {
            _cache[cacheKey] = translated;
            return translated;
          }
        }
      }
    } catch (_) {
      // Fallback to original text on network timeout or error
    }

    return text;
  }
}

/// Family FutureProvider for on-the-fly text translation
final dynamicTranslateProvider = FutureProvider.family<String, String>((ref, text) async {
  final lang = ref.watch(languageProvider);
  if (lang == AppLanguage.english || text.trim().isEmpty) {
    return text;
  }
  return await DynamicTranslationService.translate(text, lang);
});

/// Smart Flutter Widget that auto-translates dynamic user data in real time
class DynamicText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const DynamicText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVal = ref.watch(dynamicTranslateProvider(text));

    return asyncVal.when(
      data: (translatedText) => Text(
        translatedText,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
      loading: () => Text(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
      error: (err, stack) => Text(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}
