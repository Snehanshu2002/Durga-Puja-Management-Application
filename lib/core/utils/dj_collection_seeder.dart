import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DJCollectionSeeder {
  static final List<Map<String, dynamic>> aprilEntries = [
    {"name": "Titu", "amount": 200},
    {"name": "Siba", "amount": 200},
    {"name": "Filu", "amount": 200},
    {"name": "Rasmi", "amount": 200},
    {"name": "Suma", "amount": 200},
    {"name": "Chandu", "amount": 50},
    {"name": "Silu", "amount": 50},
    {"name": "Kalu", "amount": 100},
    {"name": "Santa", "amount": 200},
    {"name": "Manoj", "amount": 200},
    {"name": "Sankar", "amount": 200},
    {"name": "Gandhi Bhai", "amount": 200},
    {"name": "Litu", "amount": 100},
    {"name": "Somu", "amount": 50},
  ];

  static final List<Map<String, dynamic>> mayEntries = [
    {"name": "Titu", "amount": 200},
    {"name": "Snehansu (Kalu)", "amount": 100},
    {"name": "Filu Bhola", "amount": 200},
    {"name": "Silu Bhola", "amount": 50},
    {"name": "Rashmi", "amount": 200},
    {"name": "Siba Bhola", "amount": 200},
    {"name": "Sumant", "amount": 200},
    {"name": "Chandu", "amount": 50},
    {"name": "Sankar", "amount": 100},
    {"name": "Santa", "amount": 200},
    {"name": "Prasanta Sahoo", "amount": 200},
  ];

  static final List<Map<String, dynamic>> juneEntries = [
    {"name": "Biswajit Bhola", "amount": 200},
    {"name": "Chandu", "amount": 50},
    {"name": "Snehasnu (Kalu)", "amount": 200},
    {"name": "Filu Bhola", "amount": 200},
    {"name": "Rasmi Barik", "amount": 200},
    {"name": "Sumanta", "amount": 200},
    {"name": "Silu Bhola", "amount": 200},
    {"name": "Titu", "amount": 200},
  ];

  static final List<Map<String, dynamic>> julyEntries = [];

  static final Map<String, String> memberPhones = {
    'Snehanshu Sahoo': '7735382544',
    'Snehanshu (Kalu)': '7735382544',
    'Snehansu (Kalu)': '7735382544',
    'Snehasnu (Kalu)': '7735382544',
    'Kalu': '7735382544',
    'BirenRaj Pradhan': '6371761909',
    'Biren': '6371761909',
    'Sunil Barik': '6305146607',
    'Chandan Swain': '9692373661',
    'Chandu': '9692373661',
    'Sumanta Sahoo': '8637237371',
    'Sumanta': '8637237371',
    'Sumant': '8637237371',
    'Suma': '8637237371',
    'Ashish Praadhan': '8328944626',
    'Niranjan Pradhan': '7377302833',
    'Sankar Bhola': '6370530902',
    'Sankar': '6370530902',
    'Prasant Swain': '9337095668',
    'Rajesh Bhola': '8984405680',
    'Natabar Pradhan': '6371594685',
    'Nata': '6371594685',
    'Ganthi Sahoo': '6370337471',
    'Ameeya Pradhan': '7894590135',
    'Debasish Bhola': '9337904909',
    'Gopal Swain': '7991043679',
    'Babul Behera': '7815006100',
    'Nilu Bhola': '7377889457',
    'Silu': '7377889457',
    'Silu Bhola': '7377889457',
    'Tophan Singh': '8018666097',
    'Santa Sahoo': '9938432170',
    'Santa': '9938432170',
  };

  static String? _lookupPhone(String name) {
    final clean = name.trim().toLowerCase();
    for (final entry in memberPhones.entries) {
      if (entry.key.toLowerCase() == clean) {
        return entry.value;
      }
    }
    return null;
  }

  static Future<void> seedDJCollections({String eventId = 'event_2026', String adminUid = 'admin'}) async {
    final batch = FirebaseFirestore.instance.batch();
    final collectionsRef = FirebaseFirestore.instance.collection('collections');

    final monthsData = [
      {'month': 'April', 'monthNum': 4, 'entries': aprilEntries},
      {'month': 'May', 'monthNum': 5, 'entries': mayEntries},
      {'month': 'June', 'monthNum': 6, 'entries': juneEntries},
      {'month': 'July', 'monthNum': 7, 'entries': julyEntries},
    ];

    int count = 0;
    for (final monthInfo in monthsData) {
      final monthName = monthInfo['month'] as String;
      final monthNum = monthInfo['monthNum'] as int;
      final entries = monthInfo['entries'] as List<Map<String, dynamic>>;

      for (int i = 0; i < entries.length; i++) {
        count++;
        final item = entries[i];
        final docId = 'coll_dj_2026_${monthName.toLowerCase()}_${i + 1}';
        final docRef = collectionsRef.doc(docId);

        final date = DateTime(2026, monthNum, 15);
        final timestamp = Timestamp.fromDate(date);

        final donorName = item['name'] as String;
        final mobileNumber = memberPhones[donorName] ?? _lookupPhone(donorName);

        batch.set(docRef, {
          'id': docId,
          'eventId': eventId,
          'donorName': donorName,
          if (mobileNumber != null) 'mobileNumber': mobileNumber,
          'amount': item['amount'],
          'paymentMode': 'cash',
          'purpose': 'DJ Collection',
          'collectedBy': adminUid,
          'date': timestamp,
          'remark': 'DJ Collection 2026 - $monthName',
          'status': 'APPROVED',
          'createdBy': adminUid,
          'createdAt': timestamp,
          'updatedAt': timestamp,
          'approvedBy': adminUid,
          'approvedAt': timestamp,
          'collectionType': 'DJ',
        }, SetOptions(merge: true));
      }
    }

    // Explicitly delete dj_collection_2026_summary document to prevent duplicate collection totals
    final summaryRef = collectionsRef.doc('dj_collection_2026_summary');
    batch.delete(summaryRef);

    await batch.commit();
    debugPrint('Successfully seeded $count DJ collection entries and removed dj_collection_2026_summary from Firestore!');
  }

  static Future<void> removeSummaryDoc() async {
    try {
      await FirebaseFirestore.instance
          .collection('collections')
          .doc('dj_collection_2026_summary')
          .delete();
      debugPrint('Successfully deleted dj_collection_2026_summary document!');
    } catch (e) {
      debugPrint('Error deleting summary doc: $e');
    }
  }
}
