import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:durgapuja_manager/features/chanda/domain/entities/chanda_target.dart';

class Bhasani2026Seeder {
  static final List<Map<String, dynamic>> targetList = [
    {'slNo': 1, 'personName': 'Subhasish Bhola', 'targetAmount': 10000, 'mobileNumber': null},
    {'slNo': 2, 'personName': 'BirenRaj Pradhan', 'targetAmount': 10000, 'mobileNumber': '6371761909'},
    {'slNo': 3, 'personName': 'Sunil Barik', 'targetAmount': 6000, 'mobileNumber': '6305146607'},
    {'slNo': 4, 'personName': 'Snehanshu Sahoo', 'targetAmount': 5000, 'mobileNumber': '7735382544'},
    {'slNo': 5, 'personName': 'Chandan Swain', 'targetAmount': 3500, 'mobileNumber': '9692373661'},
    {'slNo': 6, 'personName': 'Sumanta Sahoo', 'targetAmount': 2000, 'mobileNumber': '8637237371'},
    {'slNo': 7, 'personName': 'Sudhanshu Sahoo', 'targetAmount': 2000, 'mobileNumber': null},
    {'slNo': 8, 'personName': 'Ashish Praadhan', 'targetAmount': 2000, 'mobileNumber': '8328944626'},
    {'slNo': 9, 'personName': 'Niranjan Pradhan', 'targetAmount': 2000, 'mobileNumber': '7377302833'},
    {'slNo': 10, 'personName': 'Siba Bhola', 'targetAmount': 2500, 'mobileNumber': null},
    {'slNo': 11, 'personName': 'Sankar Bhola', 'targetAmount': 3000, 'mobileNumber': '6370530902'},
    {'slNo': 12, 'personName': 'Prasant Swain', 'targetAmount': 2000, 'mobileNumber': '9337095668'},
    {'slNo': 13, 'personName': 'Deepak Pradhan', 'targetAmount': 1000, 'mobileNumber': null},
    {'slNo': 14, 'personName': 'Rajesh Bhola', 'targetAmount': 2000, 'mobileNumber': '8984405680'},
    {'slNo': 15, 'personName': 'Natabar Pradhan', 'targetAmount': 1000, 'mobileNumber': '6371594685'},
    {'slNo': 16, 'personName': 'Ganthi Sahoo', 'targetAmount': 500, 'mobileNumber': '6370337471'},
    {'slNo': 17, 'personName': 'Ameeya Pradhan', 'targetAmount': 1000, 'mobileNumber': '7894590135'},
    {'slNo': 18, 'personName': 'Debasish Bhola', 'targetAmount': 1000, 'mobileNumber': '9337904909'},
    {'slNo': 19, 'personName': 'Gopal Swain', 'targetAmount': 1000, 'mobileNumber': '7991043679'},
    {'slNo': 20, 'personName': 'Titu Behera', 'targetAmount': 1000, 'mobileNumber': null},
    {'slNo': 21, 'personName': 'Babul Behera', 'targetAmount': 1000, 'mobileNumber': '7815006100'},
    {'slNo': 22, 'personName': 'Nilu Bhola', 'targetAmount': 1500, 'mobileNumber': '7377889457'},
    {'slNo': 23, 'personName': 'Tophan Singh', 'targetAmount': 1000, 'mobileNumber': '8018666097'},
  ];

  static List<ChandaTarget> getInitialTargets({
    String eventId = 'bhasani_utsab_2026',
    String organizationName = 'Maa Durga Debi Bhashani Ustav SamitI',
  }) {
    final now = DateTime(2026, 9, 1);
    return targetList.map((item) {
      final slNo = item['slNo'] as int;
      final name = item['personName'] as String;
      final amount = item['targetAmount'] as int;
      final mobile = item['mobileNumber'] as String?;
      final docId = 'target_bhasani_2026_$slNo';

      return ChandaTarget(
        id: docId,
        personName: name,
        mobileNumber: mobile,
        targetAmount: amount,
        eventId: eventId,
        eventType: 'BHASANI_UTSAB',
        eventYear: 2026,
        organizationName: organizationName,
        status: 'PENDING',
        createdAt: now,
        updatedAt: now,
        createdBy: 'admin',
      );
    }).toList();
  }

  static Future<void> seedBhasani2026Targets({
    String eventId = 'bhasani_utsab_2026',
    String organizationName = 'Maa Durga Debi Bhashani Ustav SamitI',
    String adminUid = 'admin',
  }) async {
    try {
      final targetsRef = FirebaseFirestore.instance.collection('chanda_targets');
      final batch = FirebaseFirestore.instance.batch();
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);

      for (final item in targetList) {
        final slNo = item['slNo'] as int;
        final name = item['personName'] as String;
        final amount = item['targetAmount'] as int;
        final mobile = item['mobileNumber'] as String?;
        final docId = 'target_bhasani_2026_$slNo';
        final docRef = targetsRef.doc(docId);

        batch.set(
          docRef,
          {
            'id': docId,
            'personName': name,
            if (mobile != null && mobile.isNotEmpty) 'mobileNumber': mobile,
            'targetAmount': amount,
            'eventId': eventId,
            'eventType': 'BHASANI_UTSAB',
            'eventYear': 2026,
            'organizationName': organizationName,
            'status': 'PENDING',
            'createdBy': adminUid,
            'createdAt': timestamp,
            'updatedAt': timestamp,
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      debugPrint('Successfully seeded ${targetList.length} Bhasani 2026 Chanda Targets with mobile numbers (Total: ₹62,000)!');
    } catch (e) {
      debugPrint('Error seeding Bhasani 2026 Chanda Targets: $e');
    }
  }
}
