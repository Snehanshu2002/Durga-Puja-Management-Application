import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OperaJatra2025Seeder {
  static final List<Map<String, dynamic>> collectionList = [
    {"slNo": 1, "donorName": "Amiya Pradhan", "amount": 3000},
    {"slNo": 2, "donorName": "Fitu Bhola", "amount": 5000},
    {"slNo": 3, "donorName": "Sukant Sahoo", "amount": 5000},
    {"slNo": 4, "donorName": "Prakash Pradhan", "amount": 3000},
    {"slNo": 5, "donorName": "Santosh Bhola", "amount": 5000},
    {"slNo": 6, "donorName": "Dinesh Pradhan", "amount": 5000},
    {"slNo": 7, "donorName": "Biren Pradhan", "amount": 3000},
    {"slNo": 8, "donorName": "Gandari Pradhan", "amount": 2000},
    {"slNo": 9, "donorName": "Rabi Sahoo (Pune)", "amount": 3000},
    {"slNo": 10, "donorName": "Babuli Pradhan", "amount": 2000},
    {"slNo": 11, "donorName": "Srikant Bhola", "amount": 1500},
    {"slNo": 12, "donorName": "Sangram Bhola", "amount": 1000},
    {"slNo": 13, "donorName": "Siyaram Sethi", "amount": 2000},
    {"slNo": 14, "donorName": "Pahala Singh", "amount": 1000},
    {"slNo": 15, "donorName": "Biswajit Bhola", "amount": 1000},
    {"slNo": 16, "donorName": "Tetkal Behera", "amount": 1000},
    {"slNo": 17, "donorName": "Kalia Pradhan", "amount": 1300},
    {"slNo": 18, "donorName": "Kesab Behera", "amount": 1000},
    {"slNo": 19, "donorName": "Tapas Bhola", "amount": 2000},
    {"slNo": 20, "donorName": "Rajesh Bhola", "amount": 2500},
    {"slNo": 21, "donorName": "Bani Pradhan", "amount": 1000},
    {"slNo": 22, "donorName": "Tapan Pradhan", "amount": 1500},
    {"slNo": 23, "donorName": "Puskar Sahoo", "amount": 1000},
    {"slNo": 24, "donorName": "Bubuna Sahoo", "amount": 2000},
    {"slNo": 25, "donorName": "Santa Sahoo", "amount": 2000},
    {"slNo": 26, "donorName": "Sumanta Sahoo", "amount": 1500},
    {"slNo": 27, "donorName": "Pravata Sahoo", "amount": 2000},
    {"slNo": 28, "donorName": "Busu Barik", "amount": 1500},
    {"slNo": 29, "donorName": "Reshmi Barik", "amount": 2000},
    {"slNo": 30, "donorName": "Dinuth Pradhan", "amount": 1000},
    {"slNo": 31, "donorName": "Bmakul Swain", "amount": 2000},
    {"slNo": 32, "donorName": "Gopal Swain", "amount": 2500},
    {"slNo": 33, "donorName": "Debesh Bhola", "amount": 3000},
    {"slNo": 34, "donorName": "Lipuna Sahoo", "amount": 1500},
    {"slNo": 35, "donorName": "Sangrama Bhola (Bapi)", "amount": 1500},
    {"slNo": 36, "donorName": "Santa Sahoo", "amount": 2000},
    {"slNo": 37, "donorName": "Kalu Sahoo", "amount": 1000},
    {"slNo": 38, "donorName": "Prasana Sahoo (Badi)", "amount": 1500},
    {"slNo": 39, "donorName": "Aruna Subudhi", "amount": 1000},
    {"slNo": 40, "donorName": "Baju Pradhan", "amount": 1500},
    {"slNo": 41, "donorName": "Gupala Behera", "amount": 5000},
    {"slNo": 42, "donorName": "Mata Pradhan", "amount": 3600},
    {"slNo": 43, "donorName": "Toton Singh", "amount": 1900},
    {"slNo": 44, "donorName": "Kalia Sahoo", "amount": 2000},
    {"slNo": 45, "donorName": "Ushanta Sahoo", "amount": 1000},
    {"slNo": 46, "donorName": "Gopala Pradhan", "amount": 1000},
    {"slNo": 47, "donorName": "Sukanta Pradhan", "amount": 1500},
    {"slNo": 48, "donorName": "Ramesh Pradhan", "amount": 1500},
    {"slNo": 49, "donorName": "Alok Subudhi", "amount": 1000},
    {"slNo": 50, "donorName": "Pramod Sahoo", "amount": 3000},
    {"slNo": 51, "donorName": "Basu Swain", "amount": 520},
    {"slNo": 52, "donorName": "Rusha Swain", "amount": 520},
    {"slNo": 53, "donorName": "Bira Swain", "amount": 1500},
    {"slNo": 54, "donorName": "Jaga Bhola", "amount": 1000},
    {"slNo": 55, "donorName": "Biranchi Sahoo", "amount": 1000},
    {"slNo": 56, "donorName": "Alok Dalai (Bma Sahu)", "amount": 1000},
    {"slNo": 57, "donorName": "Narmada Pradhan", "amount": 3000},
    {"slNo": 58, "donorName": "Palu Sahoo", "amount": 940},
    {"slNo": 59, "donorName": "Titu Sahoo", "amount": 800},
    {"slNo": 61, "donorName": "Hiranya Behera", "amount": 1520},
    {"slNo": 62, "donorName": "Dinuth Pradhan", "amount": 1000},
    {"slNo": 63, "donorName": "Balaram Singh", "amount": 500},
    {"slNo": 64, "donorName": "Ganthi Sahoo", "amount": 2000},
    {"slNo": 65, "donorName": "Hemant Pradhan", "amount": 2000},
  ];

  static Future<void> seedOperaJatra2025Collections({
    String eventId = 'opera_jatra_2025',
    String adminUid = 'admin',
  }) async {
    try {
      final collectionsRef = FirebaseFirestore.instance.collection('collections');
      final existingDocs = await collectionsRef
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        debugPrint('Opera / Jatra 2025 collection entries already seeded.');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      final date = DateTime(2025, 10, 15);
      final timestamp = Timestamp.fromDate(date);

      for (final item in collectionList) {
        final slNo = item['slNo'] as int;
        final donorName = item['donorName'] as String;
        final amount = item['amount'] as int;
        final docId = 'coll_oj_2025_$slNo';
        final docRef = collectionsRef.doc(docId);

        batch.set(
          docRef,
          {
            'id': docId,
            'eventId': eventId,
            'donorName': donorName,
            'amount': amount,
            'paymentMode': 'cash',
            'purpose': 'Opera / Jatra Collection',
            'collectedBy': adminUid,
            'date': timestamp,
            'remark': 'Opera / Jatra Collection List (October 2025) - Sl. No. $slNo',
            'status': 'APPROVED',
            'createdBy': adminUid,
            'createdAt': timestamp,
            'updatedAt': timestamp,
            'approvedBy': adminUid,
            'approvedAt': timestamp,
            'collectionType': 'OPERA_JATRA',
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      debugPrint('Successfully seeded ${collectionList.length} Opera / Jatra 2025 collection entries (Total: ₹1,22,100)!');
    } catch (e) {
      debugPrint('Error seeding Opera / Jatra 2025 collections: $e');
    }
  }
}
