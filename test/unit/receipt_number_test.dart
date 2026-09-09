import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/features/receipts/domain/services/receipt_number_generator.dart';

void main() {
  group('Receipt Number Generator Tests', () {
    test('Formats receipt numbers with 6-digit zero padding', () {
      expect(ReceiptNumberGenerator.formatReceiptNumber(2026, 1), 'DP-2026-000001');
      expect(ReceiptNumberGenerator.formatReceiptNumber(2026, 125), 'DP-2026-000125');
      expect(ReceiptNumberGenerator.formatReceiptNumber(2026, 999999), 'DP-2026-999999');
    });
  });
}
