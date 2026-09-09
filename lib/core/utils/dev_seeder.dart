import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:durgapuja_manager/core/config/app_environment.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_category.dart';

class DevBootstrapSeeder {
  // 1. DEV Events
  static const List<Map<String, dynamic>> devEvents = [
    {
      'id': 'bhasani_utsab_2026',
      'eventId': 'bhasani_utsab_2026',
      'name': 'Bhasani Utsab (2026)',
      'eventName': 'Bhasani Utsab (2026)',
      'year': 2026,
      'eventType': 'BHASANI_UTSAB',
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'startDate': '2026-10-01T00:00:00.000Z',
      'endDate': '2026-10-10T23:59:59.000Z',
      'location': 'Main Pandal',
      'description': 'Bhasani Utsab 2026 Celebrations (DEV)',
      'status': 'ACTIVE',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'opera_jatra_2025',
      'eventId': 'opera_jatra_2025',
      'name': 'Opera / Jatra (2025)',
      'eventName': 'Opera / Jatra (2025)',
      'year': 2025,
      'eventType': 'OPERA_JATRA',
      'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
      'startDate': '2025-10-01T00:00:00.000Z',
      'endDate': '2025-10-10T23:59:59.000Z',
      'location': 'Opera Stage',
      'description': 'Opera / Jatra Festival 2025 (DEV)',
      'status': 'COMPLETED',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'opera_jatra_2026',
      'eventId': 'opera_jatra_2026',
      'name': 'Opera / Jatra (2026)',
      'eventName': 'Opera / Jatra (2026)',
      'year': 2026,
      'eventType': 'OPERA_JATRA',
      'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
      'startDate': '2026-10-01T00:00:00.000Z',
      'endDate': '2026-10-10T23:59:59.000Z',
      'location': 'Opera Stage',
      'description': 'Opera / Jatra Festival 2026 (DEV)',
      'status': 'ACTIVE',
      'createdBy': 'user_dev_super_admin',
    },
  ];

  // 2. DEV User Profiles
  static const List<Map<String, dynamic>> devUsers = [
    {
      'uid': 'user_dev_super_admin',
      'name': 'DEV Super Admin',
      'email': 'admin.dev@durgapuja.org',
      'mobile': '9876543210',
      'roleId': 'super_admin',
      'status': 'ACTIVE',
      'assignedEventIds': ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'],
      'eventAccess': [
        {
          'eventId': 'bhasani_utsab_2026',
          'eventType': 'BHASANI_UTSAB',
          'year': 2026,
          'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
          'roleId': 'super_admin',
        },
        {
          'eventId': 'opera_jatra_2025',
          'eventType': 'OPERA_JATRA',
          'year': 2025,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'super_admin',
        },
        {
          'eventId': 'opera_jatra_2026',
          'eventType': 'OPERA_JATRA',
          'year': 2026,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'super_admin',
        },
      ],
      'isOnline': false,
      'createdBy': 'dev_init',
    },
    {
      'uid': 'user_dev_president',
      'name': 'DEV President',
      'email': 'president.dev@durgapuja.org',
      'mobile': '9876543211',
      'roleId': 'president',
      'status': 'ACTIVE',
      'assignedEventIds': ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'],
      'eventAccess': [
        {
          'eventId': 'bhasani_utsab_2026',
          'eventType': 'BHASANI_UTSAB',
          'year': 2026,
          'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
          'roleId': 'president',
        },
        {
          'eventId': 'opera_jatra_2025',
          'eventType': 'OPERA_JATRA',
          'year': 2025,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'president',
        },
        {
          'eventId': 'opera_jatra_2026',
          'eventType': 'OPERA_JATRA',
          'year': 2026,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'president',
        },
      ],
      'isOnline': false,
      'createdBy': 'user_dev_super_admin',
    },
    {
      'uid': 'user_dev_treasurer',
      'name': 'DEV Treasurer',
      'email': 'treasurer.dev@durgapuja.org',
      'mobile': '9876543212',
      'roleId': 'treasurer',
      'status': 'ACTIVE',
      'assignedEventIds': ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'],
      'eventAccess': [
        {
          'eventId': 'bhasani_utsab_2026',
          'eventType': 'BHASANI_UTSAB',
          'year': 2026,
          'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
          'roleId': 'treasurer',
        },
        {
          'eventId': 'opera_jatra_2025',
          'eventType': 'OPERA_JATRA',
          'year': 2025,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'treasurer',
        },
        {
          'eventId': 'opera_jatra_2026',
          'eventType': 'OPERA_JATRA',
          'year': 2026,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'treasurer',
        },
      ],
      'isOnline': false,
      'createdBy': 'user_dev_super_admin',
    },
    {
      'uid': 'user_dev_manager',
      'name': 'DEV Manager (Opera 2026)',
      'email': 'manager.dev@durgapuja.org',
      'mobile': '9876543213',
      'roleId': 'manager',
      'status': 'ACTIVE',
      'assignedEventIds': ['opera_jatra_2026'],
      'eventAccess': [
        {
          'eventId': 'opera_jatra_2026',
          'eventType': 'OPERA_JATRA',
          'year': 2026,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'manager',
        },
      ],
      'isOnline': false,
      'createdBy': 'user_dev_super_admin',
    },
    {
      'uid': 'user_dev_collector',
      'name': 'DEV Collector (Opera 2026)',
      'email': 'collector.dev@durgapuja.org',
      'mobile': '9876543214',
      'roleId': 'collection_member',
      'status': 'ACTIVE',
      'assignedEventIds': ['opera_jatra_2026'],
      'eventAccess': [
        {
          'eventId': 'opera_jatra_2026',
          'eventType': 'OPERA_JATRA',
          'year': 2026,
          'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
          'roleId': 'collection_member',
        },
      ],
      'isOnline': false,
      'createdBy': 'user_dev_super_admin',
    },
    {
      'uid': 'user_dev_viewer',
      'name': 'DEV Viewer (Bhasani 2026)',
      'email': 'viewer.dev@durgapuja.org',
      'mobile': '9876543215',
      'roleId': 'viewer',
      'status': 'ACTIVE',
      'assignedEventIds': ['bhasani_utsab_2026'],
      'eventAccess': [
        {
          'eventId': 'bhasani_utsab_2026',
          'eventType': 'BHASANI_UTSAB',
          'year': 2026,
          'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
          'roleId': 'viewer',
        },
      ],
      'isOnline': false,
      'createdBy': 'user_dev_super_admin',
    },
    {
      'uid': 'user_rashmi_ranjan',
      'name': 'Rashmi Ranjan',
      'email': 'rashmiranjan@gmail.com',
      'mobile': '9876543216',
      'roleId': 'manager',
      'status': 'ACTIVE',
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
      'isOnline': false,
      'createdBy': 'user_dev_super_admin',
    },
    {
      'uid': 'user_filu',
      'name': 'Filu',
      'email': 'filu@gmail.com',
      'mobile': '9876543217',
      'roleId': 'collection_member',
      'status': 'ACTIVE',
      'assignedEventIds': ['bhasani_utsab_2026'],
      'eventAccess': [
        {
          'eventId': 'bhasani_utsab_2026',
          'eventType': 'BHASANI_UTSAB',
          'year': 2026,
          'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
          'roleId': 'collection_member',
        },
      ],
      'isOnline': false,
      'createdBy': 'user_dev_super_admin',
    },
    {
      'uid': 'user_biren',
      'name': 'Biren',
      'email': 'biren@gmail.com',
      'mobile': '9876543218',
      'roleId': 'collection_member',
      'status': 'ACTIVE',
      'assignedEventIds': ['bhasani_utsab_2026'],
      'eventAccess': [
        {
          'eventId': 'bhasani_utsab_2026',
          'eventType': 'BHASANI_UTSAB',
          'year': 2026,
          'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
          'roleId': 'collection_member',
        },
      ],
      'isOnline': false,
      'createdBy': 'user_dev_super_admin',
    },
  ];

  // 3. DEV Chanda Targets
  static const List<Map<String, dynamic>> devChandaTargets = [
    {
      'id': 'target_bhasani_2026_1',
      'personName': 'Subhasish Bhola',
      'mobileNumber': null,
      'targetAmount': 10000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_2',
      'personName': 'BirenRaj Pradhan',
      'mobileNumber': '6371761909',
      'targetAmount': 10000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_3',
      'personName': 'Sunil Barik',
      'mobileNumber': '6305146607',
      'targetAmount': 6000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_4',
      'personName': 'Snehanshu Sahoo',
      'mobileNumber': '7735382544',
      'targetAmount': 5000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_5',
      'personName': 'Chandan Swain',
      'mobileNumber': '9692373661',
      'targetAmount': 3500,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_6',
      'personName': 'Sumanta Sahoo',
      'mobileNumber': '8637237371',
      'targetAmount': 2000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_7',
      'personName': 'Sudhanshu Sahoo',
      'mobileNumber': null,
      'targetAmount': 2000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_8',
      'personName': 'Ashish Praadhan',
      'mobileNumber': '8328944626',
      'targetAmount': 2000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_9',
      'personName': 'Niranjan Pradhan',
      'mobileNumber': '7377302833',
      'targetAmount': 2000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_10',
      'personName': 'Siba Bhola',
      'mobileNumber': null,
      'targetAmount': 2500,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_11',
      'personName': 'Sankar Bhola',
      'mobileNumber': '6370530902',
      'targetAmount': 3000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_12',
      'personName': 'Prasant Swain',
      'mobileNumber': '9337095668',
      'targetAmount': 2000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_13',
      'personName': 'Deepak Pradhan',
      'mobileNumber': null,
      'targetAmount': 1000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_14',
      'personName': 'Rajesh Bhola',
      'mobileNumber': '8984405680',
      'targetAmount': 2000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_15',
      'personName': 'Natabar Pradhan',
      'mobileNumber': '6371594685',
      'targetAmount': 1000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_16',
      'personName': 'Ganthi Sahoo',
      'mobileNumber': '6370337471',
      'targetAmount': 500,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_17',
      'personName': 'Ameeya Pradhan',
      'mobileNumber': '7894590135',
      'targetAmount': 1000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_18',
      'personName': 'Debasish Bhola',
      'mobileNumber': '9337904909',
      'targetAmount': 1000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_19',
      'personName': 'Gopal Swain',
      'mobileNumber': '7991043679',
      'targetAmount': 1000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_20',
      'personName': 'Titu Behera',
      'mobileNumber': null,
      'targetAmount': 1000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_21',
      'personName': 'Babul Behera',
      'mobileNumber': '7815006100',
      'targetAmount': 1000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_22',
      'personName': 'Nilu Bhola',
      'mobileNumber': '7377889457',
      'targetAmount': 1500,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_bhasani_2026_23',
      'personName': 'Tophan Singh',
      'mobileNumber': '8018666097',
      'targetAmount': 1000,
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'status': 'PENDING',
      'createdBy': 'user_dev_super_admin',
    },
    {
      'id': 'target_opera26_chandan',
      'userId': 'user_chandan',
      'personName': 'Chandan Pradhan',
      'mobileNumber': '9876543219',
      'targetAmount': 5000,
      'eventId': 'opera_jatra_2026',
      'eventType': 'OPERA_JATRA',
      'eventYear': 2026,
      'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
      'status': 'PAID',
      'createdBy': 'user_dev_manager',
    },
  ];

  // 4. DEV Collections
  static const List<Map<String, dynamic>> devCollections = [
    {
      'id': 'col_bhasani_main_sponsor',
      'eventId': 'bhasani_utsab_2026',
      'userId': null,
      'donorName': 'Sri Jagannath Steel Works (Patron)',
      'mobileNumber': '9876543200',
      'amount': 50000,
      'paymentMode': 'bank_transfer',
      'transactionId': 'NEFT/20260901/112233',
      'purpose': 'Grand Pandal & Bhasani Main Sponsorship',
      'collectedBy': 'DEV President',
      'date': '2026-09-01T09:00:00.000Z',
      'remark': 'Corporate patron donation received via NEFT',
      'status': 'APPROVED',
      'createdBy': 'user_dev_president',
      'approvedBy': 'user_dev_treasurer',
      'approvedAt': '2026-09-01T10:00:00.000Z',
    },
    {
      'id': 'col_bhasani_community',
      'eventId': 'bhasani_utsab_2026',
      'userId': null,
      'donorName': 'Ward No. 5 Residents Welfare Association',
      'mobileNumber': '9876543201',
      'amount': 25000,
      'paymentMode': 'cheque',
      'transactionId': 'CHQ-998877',
      'purpose': 'Community Chanda Collection',
      'collectedBy': 'DEV Collection Member',
      'date': '2026-09-01T09:30:00.000Z',
      'remark': 'Cheque cleared into Samiti SBI account',
      'status': 'APPROVED',
      'createdBy': 'user_dev_collector',
      'approvedBy': 'user_dev_treasurer',
      'approvedAt': '2026-09-01T10:30:00.000Z',
    },
    {
      'id': 'col_bhasani_filu_1',
      'eventId': 'bhasani_utsab_2026',
      'userId': 'user_filu',
      'donorName': 'Filu',
      'mobileNumber': '9876543217',
      'amount': 3000,
      'paymentMode': 'cash',
      'transactionId': null,
      'purpose': 'Chanda Donation',
      'collectedBy': 'user_dev_collector',
      'date': '2026-09-01T10:00:00.000Z',
      'remark': 'First installment paid in cash',
      'status': 'APPROVED',
      'createdBy': 'user_dev_collector',
      'chandaTargetId': 'target_bhasani_filu',
      'approvedBy': 'user_dev_treasurer',
      'approvedAt': '2026-09-01T12:00:00.000Z',
    },
    {
      'id': 'col_bhasani_biren_1',
      'eventId': 'bhasani_utsab_2026',
      'userId': 'user_biren',
      'donorName': 'Biren',
      'mobileNumber': '9876543218',
      'amount': 3000,
      'paymentMode': 'upi',
      'transactionId': 'UPI/20260901/789123',
      'purpose': 'Chanda Donation',
      'collectedBy': 'user_dev_collector',
      'date': '2026-09-01T11:00:00.000Z',
      'remark': 'Paid full target via GooglePay UPI',
      'status': 'APPROVED',
      'createdBy': 'user_dev_collector',
      'chandaTargetId': 'target_bhasani_biren',
      'approvedBy': 'user_dev_treasurer',
      'approvedAt': '2026-09-01T12:30:00.000Z',
    },
    {
      'id': 'col_opera26_chandan_1',
      'eventId': 'opera_jatra_2026',
      'userId': 'user_chandan',
      'donorName': 'Chandan Pradhan',
      'mobileNumber': '9876543219',
      'amount': 6000,
      'paymentMode': 'bank_transfer',
      'transactionId': 'NEFT/20260902/554433',
      'purpose': 'Opera Patron Chanda',
      'collectedBy': 'user_dev_manager',
      'date': '2026-09-02T14:00:00.000Z',
      'remark': 'Direct NEFT transfer with 1000 excess donation',
      'status': 'APPROVED',
      'createdBy': 'user_dev_manager',
      'chandaTargetId': 'target_opera26_chandan',
      'approvedBy': 'user_dev_treasurer',
      'approvedAt': '2026-09-02T16:00:00.000Z',
    },
    {
      'id': 'col_bhasani_public_pending',
      'eventId': 'bhasani_utsab_2026',
      'userId': null,
      'donorName': 'Amitabh Sen (General Public)',
      'mobileNumber': '9876543220',
      'amount': 5000,
      'paymentMode': 'cheque',
      'transactionId': 'CHQ-445566',
      'purpose': 'Public Pandal Sponsorship',
      'collectedBy': 'user_dev_collector',
      'date': '2026-09-03T09:00:00.000Z',
      'remark': 'Cheque handed over, pending bank clearing',
      'status': 'PENDING',
      'createdBy': 'user_dev_collector',
    },
    {
      'id': 'col_bhasani_rejected_1',
      'eventId': 'bhasani_utsab_2026',
      'userId': null,
      'donorName': 'Test Rejected Entry',
      'mobileNumber': '9876543221',
      'amount': 2000,
      'paymentMode': 'cash',
      'transactionId': null,
      'purpose': 'Duplicate Entry',
      'collectedBy': 'user_dev_collector',
      'date': '2026-09-03T10:00:00.000Z',
      'remark': 'Duplicate cash entry entered by mistake',
      'status': 'REJECTED',
      'createdBy': 'user_dev_collector',
      'rejectionReason': 'Duplicate cash entry by collector',
    },
  ];

  // 5. DEV Expenses
  static const List<Map<String, dynamic>> devExpenses = [
    {
      'id': 'exp_bhasani_tent_1',
      'eventId': 'bhasani_utsab_2026',
      'categoryId': 'tent',
      'description': 'Pandal structure advance payment',
      'amount': 15000,
      'paidTo': 'M/S Maa Samaleswari Tent Works',
      'paymentMode': 'cash',
      'date': '2026-09-02T11:00:00.000Z',
      'remark': 'First installment of tent fabric & poles',
      'status': 'APPROVED',
      'addedBy': 'user_dev_manager',
      'approvedBy': 'user_dev_treasurer',
      'approvedAt': '2026-09-02T13:00:00.000Z',
    },
    {
      'id': 'exp_bhasani_samagri_1',
      'eventId': 'bhasani_utsab_2026',
      'categoryId': 'puja_material',
      'description': 'Ghee, Havan Samagri, Flowers & Sweets',
      'amount': 4500,
      'paidTo': 'Sri Durga Bhandar',
      'paymentMode': 'upi',
      'date': '2026-09-03T15:00:00.000Z',
      'remark': 'Items received for Maha Ashtami Puja',
      'status': 'APPROVED',
      'addedBy': 'user_dev_manager',
      'approvedBy': 'user_dev_treasurer',
      'approvedAt': '2026-09-03T17:00:00.000Z',
    },
    {
      'id': 'exp_bhasani_light_pending',
      'eventId': 'bhasani_utsab_2026',
      'categoryId': 'electricity',
      'description': 'Lighting & Generator Stage 1 quotation',
      'amount': 8000,
      'paidTo': 'Star Lightings Ltd',
      'paymentMode': 'bank_transfer',
      'date': '2026-09-04T09:00:00.000Z',
      'remark': 'Quotation submitted for review',
      'status': 'PENDING',
      'addedBy': 'user_dev_manager',
    },
    {
      'id': 'exp_bhasani_rejected_1',
      'eventId': 'bhasani_utsab_2026',
      'categoryId': 'other',
      'description': 'Unverified local conveyance claim',
      'amount': 1000,
      'paidTo': 'Local Driver',
      'paymentMode': 'cash',
      'date': '2026-09-04T10:00:00.000Z',
      'remark': 'Claim without fuel slip',
      'status': 'REJECTED',
      'addedBy': 'user_dev_manager',
      'rejectionReason': 'Voucher missing proper bill receipts',
    },
  ];

  // 6. DEV Collection Custody
  static const List<Map<String, dynamic>> devCustody = [
    {
      'id': 'custody_bhasani_handover_1',
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'amount': 2000,
      'fromUserId': 'user_dev_collector',
      'fromUserName': 'DEV Collector',
      'toUserId': 'user_dev_treasurer',
      'toUserName': 'DEV Treasurer',
      'handoverType': 'CASH_HANDOVER',
      'status': 'RECEIVED',
      'handedOverAt': '2026-09-02T12:00:00.000Z',
      'receivedAt': '2026-09-02T13:00:00.000Z',
      'notes': 'Partial cash collection handover from Pandal counter',
      'createdBy': 'user_dev_collector',
    },
    {
      'id': 'custody_bhasani_bank_dep_1',
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'amount': 1500,
      'fromUserId': 'user_dev_treasurer',
      'fromUserName': 'DEV Treasurer',
      'toUserId': 'BANK_SBI',
      'toUserName': 'State Bank of India (Samiti A/C)',
      'handoverType': 'BANK_DEPOSIT',
      'status': 'DEPOSITED',
      'handedOverAt': '2026-09-03T11:00:00.000Z',
      'receivedAt': '2026-09-03T11:30:00.000Z',
      'notes': 'Deposited into SBI Current Account',
      'createdBy': 'user_dev_treasurer',
    },
    {
      'id': 'custody_bhasani_pending_handover',
      'eventId': 'bhasani_utsab_2026',
      'eventType': 'BHASANI_UTSAB',
      'eventYear': 2026,
      'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
      'amount': 500,
      'fromUserId': 'user_dev_collector',
      'fromUserName': 'DEV Collector',
      'toUserId': 'user_dev_treasurer',
      'toUserName': 'DEV Treasurer',
      'handoverType': 'CASH_HANDOVER',
      'status': 'PENDING',
      'handedOverAt': '2026-09-04T10:00:00.000Z',
      'notes': 'Handover requested by collector, pending treasurer receipt',
      'createdBy': 'user_dev_collector',
    },
  ];

  // 7. DEV Audit Logs
  static const List<Map<String, dynamic>> devAuditLogs = [
    {
      'id': 'audit_dev_login_1',
      'eventId': 'global',
      'userId': 'user_dev_super_admin',
      'userName': 'DEV Super Admin',
      'action': 'LOGIN',
      'entityType': 'SESSION',
      'entityId': 'sess_initial',
      'timestamp': '2026-09-01T08:00:00.000Z',
      'metadata': {'email': 'admin@durgapuja.org', 'platform': 'Chrome Web'},
    },
    {
      'id': 'audit_dev_col_app_1',
      'eventId': 'bhasani_utsab_2026',
      'userId': 'user_dev_treasurer',
      'userName': 'DEV Treasurer',
      'action': 'COLLECTION_APPROVED',
      'entityType': 'COLLECTION',
      'entityId': 'col_bhasani_filu_1',
      'timestamp': '2026-09-01T12:00:00.000Z',
      'metadata': {'amount': 3000, 'donor': 'Filu'},
    },
    {
      'id': 'audit_dev_exp_app_1',
      'eventId': 'bhasani_utsab_2026',
      'userId': 'user_dev_treasurer',
      'userName': 'DEV Treasurer',
      'action': 'EXPENSE_APPROVED',
      'entityType': 'EXPENSE',
      'entityId': 'exp_bhasani_tent_1',
      'timestamp': '2026-09-02T13:00:00.000Z',
      'metadata': {'amount': 15000, 'category': 'tent'},
    },
    {
      'id': 'audit_dev_custody_1',
      'eventId': 'bhasani_utsab_2026',
      'userId': 'user_dev_treasurer',
      'userName': 'DEV Treasurer',
      'action': 'CASH_RECEIVED',
      'entityType': 'CUSTODY',
      'entityId': 'custody_bhasani_handover_1',
      'timestamp': '2026-09-02T13:00:00.000Z',
      'metadata': {'amount': 2000, 'from': 'DEV Collector'},
    },
    {
      'id': 'audit_dev_bank_dep_1',
      'eventId': 'bhasani_utsab_2026',
      'userId': 'user_dev_treasurer',
      'userName': 'DEV Treasurer',
      'action': 'BANK_DEPOSIT',
      'entityType': 'CUSTODY',
      'entityId': 'custody_bhasani_bank_dep_1',
      'timestamp': '2026-09-03T11:30:00.000Z',
      'metadata': {'amount': 1500, 'bank': 'SBI'},
    },
  ];

  /// Comprehensive seeding method executed in DEV after authentication
  static Future<void> seedDevEnvironment([User? fbUser]) async {
    if (!AppEnvironment.isDev) return;

    final currentAuthUser = fbUser ?? FirebaseAuth.instance.currentUser;
    if (currentAuthUser == null) {
      debugPrint('[DevBootstrap] No authenticated user present yet. Skipping pre-auth seed.');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      // STEP 1: Always ensure current user's profile is created FIRST as Super Admin.
      final userDocRef = firestore.collection('users').doc(currentAuthUser.uid);
      final userSnap = await userDocRef.get();

      if (!userSnap.exists) {
        await userDocRef.set({
          'uid': currentAuthUser.uid,
          'name': currentAuthUser.displayName?.isNotEmpty == true
              ? currentAuthUser.displayName!
              : 'Super Admin',
          'email': currentAuthUser.email ?? 'admin@durgapuja.org',
          'roleId': 'super_admin',
          'status': 'ACTIVE',
          'assignedEventIds': [
            'bhasani_utsab_2026',
            'opera_jatra_2025',
            'opera_jatra_2026',
          ],
          'eventAccess': [
            {
              'eventId': 'bhasani_utsab_2026',
              'eventType': 'BHASANI_UTSAB',
              'year': 2026,
              'organizationName': 'Maa Durga Debi Bhashani Ustav SamitI',
              'roleId': 'super_admin',
            },
            {
              'eventId': 'opera_jatra_2025',
              'eventType': 'OPERA_JATRA',
              'year': 2025,
              'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
              'roleId': 'super_admin',
            },
            {
              'eventId': 'opera_jatra_2026',
              'eventType': 'OPERA_JATRA',
              'year': 2026,
              'organizationName': 'MAA DURGA DEVI YOUTH ASSOCIATION',
              'roleId': 'super_admin',
            },
          ],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'createdBy': 'dev_bootstrap',
        });
        debugPrint('[DevBootstrap] Seeded Dev Super Admin user: ${currentAuthUser.uid}');
      }

      // STEP 2: Seed DEV events
      for (final event in devEvents) {
        final docRef = firestore.collection('puja_events').doc(event['id'] as String);
        final snap = await docRef.get();
        if (!snap.exists) {
          await docRef.set({
            ...event,
            'startDate': Timestamp.fromDate(DateTime.parse(event['startDate'] as String)),
            'endDate': Timestamp.fromDate(DateTime.parse(event['endDate'] as String)),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('[DevBootstrap] Seeded event: ${event['id']}');
        }
      }

      // STEP 3: Seed Default Expense Categories
      for (final cat in ExpenseCategory.defaultCategories) {
        final docRef = firestore.collection('expense_categories').doc(cat.id);
        final snap = await docRef.get();
        if (!snap.exists) {
          await docRef.set({
            'id': cat.id,
            'name': cat.name,
            'description': cat.description ?? '',
            'isActive': cat.isActive,
            'usageCount': cat.usageCount,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('[DevBootstrap] Seeded expense category: ${cat.name}');
        }
      }

      // STEP 4: Seed All DEV Users
      for (final user in devUsers) {
        final docRef = firestore.collection('users').doc(user['uid'] as String);
        final snap = await docRef.get();
        if (!snap.exists) {
          await docRef.set({
            ...user,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('[DevBootstrap] Seeded user profile: ${user['name']}');
        }
      }

      // STEP 5: Seed Chanda Targets
      for (final target in devChandaTargets) {
        final docRef = firestore.collection('chanda_targets').doc(target['id'] as String);
        final snap = await docRef.get();
        if (!snap.exists) {
          await docRef.set({
            ...target,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('[DevBootstrap] Seeded chanda target: ${target['id']}');
        }
      }

      // STEP 6: Seed Collections
      for (final col in devCollections) {
        final docRef = firestore.collection('collections').doc(col['id'] as String);
        final snap = await docRef.get();
        if (!snap.exists) {
          await docRef.set({
            ...col,
            'date': Timestamp.fromDate(DateTime.parse(col['date'] as String)),
            'approvedAt': col['approvedAt'] != null
                ? Timestamp.fromDate(DateTime.parse(col['approvedAt'] as String))
                : null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('[DevBootstrap] Seeded collection: ${col['id']}');
        }
      }

      // STEP 7: Seed Expenses
      for (final exp in devExpenses) {
        final docRef = firestore.collection('expenses').doc(exp['id'] as String);
        final snap = await docRef.get();
        if (!snap.exists) {
          await docRef.set({
            ...exp,
            'date': Timestamp.fromDate(DateTime.parse(exp['date'] as String)),
            'approvedAt': exp['approvedAt'] != null
                ? Timestamp.fromDate(DateTime.parse(exp['approvedAt'] as String))
                : null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('[DevBootstrap] Seeded expense: ${exp['id']}');
        }
      }

      // STEP 8: Seed Custody Records
      for (final c in devCustody) {
        final docRef = firestore.collection('collection_custody').doc(c['id'] as String);
        final snap = await docRef.get();
        if (!snap.exists) {
          await docRef.set({
            ...c,
            'handedOverAt': Timestamp.fromDate(DateTime.parse(c['handedOverAt'] as String)),
            'receivedAt': c['receivedAt'] != null
                ? Timestamp.fromDate(DateTime.parse(c['receivedAt'] as String))
                : null,
            'createdAt': FieldValue.serverTimestamp(),
          });
          debugPrint('[DevBootstrap] Seeded custody record: ${c['id']}');
        }
      }

      // STEP 9: Seed Audit Logs
      for (final log in devAuditLogs) {
        final docRef = firestore.collection('audit_logs').doc(log['id'] as String);
        final snap = await docRef.get();
        if (!snap.exists) {
          await docRef.set({
            ...log,
            'timestamp': Timestamp.fromDate(DateTime.parse(log['timestamp'] as String)),
          });
          debugPrint('[DevBootstrap] Seeded audit log: ${log['id']}');
        }
      }

      debugPrint('[DevBootstrap] ✅ Complete DEV Dataset Seeded Successfully!');
    } catch (e) {
      debugPrint('[DevBootstrap] Note: $e');
    }
  }

  static Future<void> seedDevEnvironmentIfEmpty(User fbUser) => seedDevEnvironment(fbUser);
}
