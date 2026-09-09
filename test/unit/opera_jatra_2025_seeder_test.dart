import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/utils/opera_jatra_2025_seeder.dart';

void main() {
  group('Opera / Jatra 2025 Collection Seeder Tests', () {
    test('Seeder list contains exactly 64 entries', () {
      expect(OperaJatra2025Seeder.collectionList.length, 64);
    });

    test('Seeder collection total sum equals exactly ₹1,22,100', () {
      int totalSum = 0;
      for (final entry in OperaJatra2025Seeder.collectionList) {
        totalSum += entry['amount'] as int;
      }
      expect(totalSum, 122100);
    });

    test('All entries contain non-empty donorName, valid slNo, and positive amount', () {
      for (final entry in OperaJatra2025Seeder.collectionList) {
        expect(entry['slNo'], isA<int>());
        expect((entry['slNo'] as int) > 0, isTrue);
        expect(entry['donorName'], isA<String>());
        expect((entry['donorName'] as String).trim().isNotEmpty, isTrue);
        expect(entry['amount'], isA<int>());
        expect((entry['amount'] as int) > 0, isTrue);
      }
    });

    test('Specific entry verification matches table', () {
      final entry1 = OperaJatra2025Seeder.collectionList.firstWhere((e) => e['slNo'] == 1);
      expect(entry1['donorName'], 'Amiya Pradhan');
      expect(entry1['amount'], 3000);

      final entry2 = OperaJatra2025Seeder.collectionList.firstWhere((e) => e['slNo'] == 2);
      expect(entry2['donorName'], 'Fitu Bhola');
      expect(entry2['amount'], 5000);

      final entry41 = OperaJatra2025Seeder.collectionList.firstWhere((e) => e['slNo'] == 41);
      expect(entry41['donorName'], 'Gupala Behera');
      expect(entry41['amount'], 5000);

      final entry65 = OperaJatra2025Seeder.collectionList.firstWhere((e) => e['slNo'] == 65);
      expect(entry65['donorName'], 'Hemant Pradhan');
      expect(entry65['amount'], 2000);
    });
  });
}
