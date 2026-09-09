import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserSeeder {
  static final List<Map<String, dynamic>> newUsers = [
    {
      'name': 'Rashmi Ranjan',
      'email': 'rashmiranjan@gmail.com',
      'password': 'Rashmi@123',
      'roleId': 'manager',
      'assignedEventIds': ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'],
      'eventAccess': [
        {
          'eventId': 'bhasani_utsab_2026',
          'eventType': 'BHASANI_UTSAB',
          'year': 2026,
          'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
          'roleId': 'manager',
        },
        {
          'eventId': 'opera_jatra_2025',
          'eventType': 'OPERA_JATRA',
          'year': 2025,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'manager',
        },
        {
          'eventId': 'opera_jatra_2026',
          'eventType': 'OPERA_JATRA',
          'year': 2026,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'collection_member',
        },
      ],
    },
    {
      'name': 'Biren',
      'email': 'biren@gmail.com',
      'password': 'Biren@123',
      'roleId': 'manager',
      'assignedEventIds': ['bhasani_utsab_2026'],
      'eventAccess': [
        {
          'eventId': 'bhasani_utsab_2026',
          'eventType': 'BHASANI_UTSAB',
          'year': 2026,
          'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
          'roleId': 'manager',
        },
      ],
    },
    {
      'name': 'Chandan',
      'email': 'chandan@gmail.com',
      'password': 'Chandan@123',
      'roleId': 'manager',
      'assignedEventIds': ['opera_jatra_2025', 'opera_jatra_2026'],
      'eventAccess': [
        {
          'eventId': 'opera_jatra_2025',
          'eventType': 'OPERA_JATRA',
          'year': 2025,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'manager',
        },
        {
          'eventId': 'opera_jatra_2026',
          'eventType': 'OPERA_JATRA',
          'year': 2026,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'manager',
        },
      ],
    },
    {
      'name': 'Filu',
      'email': 'filu@gmail.com',
      'password': 'Filu@123',
      'roleId': 'manager',
      'assignedEventIds': ['bhasani_utsab_2026'],
      'eventAccess': [
        {
          'eventId': 'bhasani_utsab_2026',
          'eventType': 'BHASANI_UTSAB',
          'year': 2026,
          'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
          'roleId': 'manager',
        },
      ],
    },
  ];

  static Future<void> seedNewManagers() async {
    final usersRef = FirebaseFirestore.instance.collection('users');

    for (final u in newUsers) {
      final email = (u['email'] as String).trim().toLowerCase();
      final name = u['name'] as String;
      final password = u['password'] as String;
      final roleId = u['roleId'] as String;
      final assignedEventIds = u['assignedEventIds'];
      final eventAccess = u['eventAccess'];

      try {
        final existingQuery = await usersRef.where('email', isEqualTo: email).get();

        if (existingQuery.docs.isEmpty) {
          final docId = 'user_pre_${email.split('@').first}';
          await usersRef.doc(docId).set({
            'uid': docId,
            'name': name,
            'email': email,
            'password': password,
            'roleId': roleId,
            'status': 'ACTIVE',
            'assignedEventIds': assignedEventIds,
            'eventAccess': eventAccess,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'createdBy': 'admin',
          });
          debugPrint('Seeded manager user with password: $name ($email)');
        } else {
          final doc = existingQuery.docs.first;
          await doc.reference.update({
            'roleId': roleId,
            'name': name,
            'password': password,
            'status': 'ACTIVE',
            'assignedEventIds': assignedEventIds,
            'eventAccess': eventAccess,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('Updated manager user with password: $name ($email)');
        }
      } catch (e) {
        debugPrint('Error seeding user $name: $e');
      }
    }
  }
}
