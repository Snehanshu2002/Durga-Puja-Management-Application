import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/utils/number_to_words.dart';

void main() {
  group('Number To Words Converter Tests', () {
    test('Converts amounts into correct Indian currency English words', () {
      expect(NumberToWords.convert(0), 'Zero Rupees Only');
      expect(NumberToWords.convert(500), 'Five Hundred Rupees Only');
      expect(NumberToWords.convert(5000), 'Five Thousand Rupees Only');
      expect(NumberToWords.convert(25500), 'Twenty Five Thousand Five Hundred Rupees Only');
      expect(NumberToWords.convert(125000), 'One Lakh Twenty Five Thousand Rupees Only');
      expect(NumberToWords.convert(1050000), 'Ten Lakh Fifty Thousand Rupees Only');
    });
  });
}
