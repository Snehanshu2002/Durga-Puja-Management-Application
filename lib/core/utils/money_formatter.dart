import 'package:intl/intl.dart';

class MoneyFormatter {
  static final NumberFormat _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _indianFormatWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format money integer amount into Indian format (e.g. ₹1,25,000 or -₹20,000)
  static String format(int amountInRupees, {bool includeDecimals = false}) {
    if (includeDecimals) {
      return _indianFormatWithDecimals.format(amountInRupees);
    }
    return _indianFormat.format(amountInRupees);
  }

  /// Format money for PDF engines (e.g. Rs. 1,25,000) to avoid missing font glyph errors
  static String formatForPdf(int amountInRupees) {
    return format(amountInRupees).replaceAll('₹', 'Rs. ');
  }

  /// Safe calculation helper avoiding double floating point inaccuracies
  static int parseRupees(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    final cleaned = value.replaceAll(RegExp(r'[^0-9.-]'), '');
    final parsedDouble = double.tryParse(cleaned) ?? 0.0;
    return parsedDouble.round();
  }
}
