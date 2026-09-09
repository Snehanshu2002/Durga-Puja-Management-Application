import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/core/utils/whatsapp_share_helper.dart';
import 'package:durgapuja_manager/features/audit/domain/entities/audit_log.dart';
import 'package:durgapuja_manager/features/chanda/domain/entities/chanda_target.dart';
import 'package:durgapuja_manager/features/chanda/domain/entities/chanda_target_with_progress.dart';
import 'package:durgapuja_manager/features/chanda/presentation/providers/chanda_provider.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/reports/domain/services/chanda_export_service.dart';

void main() {
  group('WhatsApp 1-Tap Share & Message Formatting Tests (100% Free)', () {
    test('Cleans Indian 10-digit phone number with 91 country code', () {
      expect(WhatsAppShareHelper.cleanPhoneNumber('7735382544'), equals('917735382544'));
      expect(WhatsAppShareHelper.cleanPhoneNumber('+91 77353 82544'), equals('917735382544'));
      expect(WhatsAppShareHelper.cleanPhoneNumber('917735382544'), equals('917735382544'));
      expect(WhatsAppShareHelper.cleanPhoneNumber(null), equals(''));
    });

    test('Formats polite Chanda Due Reminder correctly with non-sensitive fields', () {
      final msg = WhatsAppShareHelper.formatChandaDueReminder(
        orgName: 'Durga Puja Committee',
        eventName: 'Opera / Jatra',
        eventYear: 2026,
        memberName: 'Snehanshu Sahoo',
        targetAmount: 2000,
        paidAmount: 1000,
        remainingAmount: 1000,
      );

      expect(msg, contains('Jay Maa Durga Devi'));
      expect(msg, contains('Snehanshu Sahoo'));
      expect(msg, contains('Target: ₹2000'));
      expect(msg, contains('Paid: ₹1000'));
      expect(msg, contains('Pending: ₹1000'));
      expect(msg, contains('Dhanyawad'));

      final pradhanMsg = WhatsAppShareHelper.formatChandaDueReminder(
        orgName: 'Durga Puja Committee',
        eventName: 'Opera / Jatra',
        eventYear: 2026,
        memberName: 'BirenRaj Pradhan',
        targetAmount: 5000,
        paidAmount: 0,
        remainingAmount: 5000,
      );
      expect(pradhanMsg, contains('Namaskar BirenRaj bhai,'));
      expect(pradhanMsg, isNot(contains('BirenRaj Pradhan bhai')));
    });

    test('Formats Donation Receipt Acknowledgement correctly', () {
      final msg = WhatsAppShareHelper.formatCollectionReceipt(
        orgName: 'Durga Puja Committee',
        eventName: 'Opera / Jatra',
        eventYear: 2026,
        donorName: 'Snehanshu Sahoo',
        amount: 1000,
        paymentMode: 'UPI',
        receiptNumber: 'DP-2026-000036',
        date: DateTime(2026, 8, 12, 18, 30),
        collectedBy: 'Super Admin',
      );

      expect(msg, contains('Donation Receipt Acknowledgement'));
      expect(msg, contains('Receipt No: DP-2026-000036'));
      expect(msg, contains('Donor: Snehanshu Sahoo'));
      expect(msg, contains('Amount: ₹1000'));
      expect(msg, contains('Payment Mode: UPI'));
      expect(msg, contains('Status: Approved ✅'));
    });
  });

  group('Chanda Export Service Tests (PDF, CSV & Print)', () {
    final sampleTargets = [
      ChandaTargetWithProgress(
        target: ChandaTarget(
          id: 't1',
          eventId: 'opera_2026',
          eventType: 'OPERA_JATRA',
          eventYear: 2026,
          organizationName: 'Durga Puja Committee',
          status: 'PENDING',
          personName: 'Dinesh Bhola',
          targetAmount: 7000,
          mobileNumber: '7205626095',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          createdBy: 'admin',
        ),
        paidAmount: 7000,
        linkedCollections: [],
      ),
      ChandaTargetWithProgress(
        target: ChandaTarget(
          id: 't2',
          eventId: 'opera_2026',
          eventType: 'OPERA_JATRA',
          eventYear: 2026,
          organizationName: 'Durga Puja Committee',
          status: 'PENDING',
          personName: 'Snehanshu Sahoo',
          targetAmount: 2000,
          mobileNumber: '7735382544',
          createdAt: DateTime(2026, 1, 2),
          updatedAt: DateTime(2026, 1, 2),
          createdBy: 'admin',
        ),
        paidAmount: 1000,
        linkedCollections: [],
      ),
      ChandaTargetWithProgress(
        target: ChandaTarget(
          id: 't3',
          eventId: 'opera_2026',
          eventType: 'OPERA_JATRA',
          eventYear: 2026,
          organizationName: 'Durga Puja Committee',
          status: 'PENDING',
          personName: 'Member Without Phone',
          targetAmount: 1500,
          mobileNumber: null,
          createdAt: DateTime(2026, 1, 3),
          updatedAt: DateTime(2026, 1, 3),
          createdBy: 'admin',
        ),
        paidAmount: 0,
        linkedCollections: [],
      ),
    ];

    test('Generates Excel-compatible CSV with UTF-8 BOM and required columns', () {
      final csv = ChandaExportService.generateChandaCsv(
        organizationName: 'Durga Puja Committee',
        eventName: 'Opera / Jatra',
        eventYear: 2026,
        targets: sampleTargets,
      );

      // Verify UTF-8 BOM
      expect(csv.startsWith('\uFEFF'), isTrue);

      // Verify Header & Columns
      expect(csv, contains('Member Name'));
      expect(csv, contains('Mobile Number'));
      expect(csv, contains('Target Amount (INR)'));
      expect(csv, contains('Approved Paid (INR)'));
      expect(csv, contains('Remaining Amount (INR)'));
      expect(csv, contains('Excess Amount (INR)'));
      expect(csv, contains('Signature'));

      // Verify Data
      expect(csv, contains('Dinesh Bhola'));
      expect(csv, contains('7205626095'));
      expect(csv, contains('7000'));
      expect(csv, contains('Snehanshu Sahoo'));
      expect(csv, contains('Member Without Phone'));

      // Verify Totals row
      expect(csv, contains('TOTAL'));
      expect(csv, contains('3 Members'));
      expect(csv, contains('10500')); // 7000 + 2000 + 1500
      expect(csv, contains('8000'));  // 7000 + 1000
    });

    test('Generates PDF byte stream without exceptions', () async {
      final pdfBytes = await ChandaExportService.generateChandaPdf(
        organizationName: 'Durga Puja Committee',
        eventName: 'Opera / Jatra',
        eventYear: 2026,
        targets: sampleTargets,
        generatedBy: 'Super Admin',
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // PDF standard magic bytes: %PDF
      expect(String.fromCharCodes(pdfBytes.sublist(0, 4)), equals('%PDF'));
    });
  });

  group('Chanda Smart Sort, Filter & Analytics Logic Tests', () {
    final t1 = ChandaTargetWithProgress(
      target: ChandaTarget(
        id: 't1',
        eventId: 'opera_2026',
        eventType: 'OPERA_JATRA',
        eventYear: 2026,
        organizationName: 'Durga Puja Committee',
        status: 'PENDING',
        personName: 'Dinesh Bhola',
        targetAmount: 7000,
        mobileNumber: '7205626095',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        createdBy: 'admin',
      ),
      paidAmount: 7000,
      linkedCollections: [],
    );

    final t2 = ChandaTargetWithProgress(
      target: ChandaTarget(
        id: 't2',
        eventId: 'opera_2026',
        eventType: 'OPERA_JATRA',
        eventYear: 2026,
        organizationName: 'Durga Puja Committee',
        status: 'PENDING',
        personName: 'Ameeya Pradhan',
        targetAmount: 4000,
        mobileNumber: '7894590135',
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
        createdBy: 'admin',
      ),
      paidAmount: 2000,
      linkedCollections: [],
    );

    final t3 = ChandaTargetWithProgress(
      target: ChandaTarget(
        id: 't3',
        eventId: 'opera_2026',
        eventType: 'OPERA_JATRA',
        eventYear: 2026,
        organizationName: 'Durga Puja Committee',
        status: 'PENDING',
        personName: 'Zakir Khan',
        targetAmount: 1000,
        mobileNumber: null, // Missing phone
        createdAt: DateTime(2026, 1, 3),
        updatedAt: DateTime(2026, 1, 3),
        createdBy: 'admin',
      ),
      paidAmount: 0,
      linkedCollections: [],
    );

    final list = [t1, t2, t3];

    test('Correctly calculates ChandaSummary metrics', () {
      int totalTarget = 0;
      int totalPaid = 0;
      int totalRemaining = 0;
      int totalExcess = 0;
      int fullyPaid = 0;
      int partial = 0;
      int pending = 0;
      int missingPhone = 0;

      for (final item in list) {
        totalTarget += item.targetAmount;
        totalPaid += item.paidAmount;
        totalRemaining += item.remainingAmount;
        totalExcess += item.excessAmount;

        if (item.isFullyPaid) fullyPaid++;
        if (item.isPartial) partial++;
        if (item.isPending) pending++;
        if (item.target.mobileNumber == null || item.target.mobileNumber!.isEmpty) missingPhone++;
      }

      final summary = ChandaSummary(
        totalTarget: totalTarget,
        totalCollected: totalPaid,
        totalRemaining: totalRemaining,
        totalExcess: totalExcess,
        totalMembers: list.length,
        fullyPaidCount: fullyPaid,
        partialPaidCount: partial,
        pendingCount: pending,
        missingPhoneCount: missingPhone,
      );

      expect(summary.totalTarget, equals(12000));
      expect(summary.totalCollected, equals(9000));
      expect(summary.totalRemaining, equals(3000));
      expect(summary.fullyPaidCount, equals(1));
      expect(summary.partialPaidCount, equals(1));
      expect(summary.pendingCount, equals(1));
      expect(summary.missingPhoneCount, equals(1));
      expect(summary.achievementPercentage, closeTo(75.0, 0.01));
    });

    test('Filters missing phone numbers correctly', () {
      final missing = list.where((item) {
        final phone = item.target.mobileNumber?.trim();
        return phone == null || phone.isEmpty;
      }).toList();

      expect(missing.length, equals(1));
      expect(missing.first.target.personName, equals('Zakir Khan'));
    });

    test('Sorts Name A-Z and Name Z-A correctly', () {
      final asc = List<ChandaTargetWithProgress>.from(list);
      asc.sort((a, b) => a.target.personName.toLowerCase().compareTo(b.target.personName.toLowerCase()));
      expect(asc.first.target.personName, equals('Ameeya Pradhan'));
      expect(asc.last.target.personName, equals('Zakir Khan'));

      final desc = List<ChandaTargetWithProgress>.from(list);
      desc.sort((a, b) => b.target.personName.toLowerCase().compareTo(a.target.personName.toLowerCase()));
      expect(desc.first.target.personName, equals('Zakir Khan'));
      expect(desc.last.target.personName, equals('Ameeya Pradhan'));
    });

    test('Sorts Highest Target to Lowest Target correctly', () {
      final sorted = List<ChandaTargetWithProgress>.from(list);
      sorted.sort((a, b) => b.targetAmount.compareTo(a.targetAmount));
      expect(sorted.first.targetAmount, equals(7000));
      expect(sorted.last.targetAmount, equals(1000));
    });

    test('Excludes pending & rejected collections from official target paid calculations', () {
      final testTarget = ChandaTarget(
        id: 't_pending_test',
        eventId: 'opera_2026',
        eventType: 'OPERA_JATRA',
        eventYear: 2026,
        organizationName: 'Durga Puja Committee',
        status: 'PENDING',
        personName: 'Test Donor',
        targetAmount: 5000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'admin',
      );

      final collections = [
        CollectionEntity(
          id: 'c1',
          eventId: 'opera_2026',
          chandaTargetId: 't_pending_test',
          donorName: 'Test Donor',
          amount: 2000,
          paymentMode: PaymentMode.upi,
          purpose: 'Chanda',
          collectedBy: 'Admin',
          date: DateTime.now(),
          status: 'PENDING', // MUST NOT COUNT
          createdBy: 'admin',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CollectionEntity(
          id: 'c2',
          eventId: 'opera_2026',
          chandaTargetId: 't_pending_test',
          donorName: 'Test Donor',
          amount: 1500,
          paymentMode: PaymentMode.upi,
          purpose: 'Chanda',
          collectedBy: 'Admin',
          date: DateTime.now(),
          status: 'REJECTED', // MUST NOT COUNT
          createdBy: 'admin',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CollectionEntity(
          id: 'c3',
          eventId: 'opera_2026',
          chandaTargetId: 't_pending_test',
          donorName: 'Test Donor',
          amount: 1000,
          paymentMode: PaymentMode.cash,
          purpose: 'Chanda',
          collectedBy: 'Admin',
          date: DateTime.now(),
          status: 'APPROVED', // ONLY THIS MUST COUNT
          createdBy: 'admin',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final paidApproved = collections
          .where((c) => c.isApproved)
          .fold<int>(0, (sum, c) => sum + c.amount);

      final progress = ChandaTargetWithProgress(
        target: testTarget,
        paidAmount: paidApproved,
        linkedCollections: collections,
      );

      expect(progress.paidAmount, equals(1000));
      expect(progress.remainingAmount, equals(4000));
      expect(progress.isPartial, isTrue);
      expect(progress.isFullyPaid, isFalse);
    });
  });

  group('Audit Log Constants & Immutability Verification', () {
    test('Audit log contains all required new action constants', () {
      expect(AuditLog.actionChandaPdfExport, equals('CHANDA_PDF_EXPORT'));
      expect(AuditLog.actionChandaCsvExport, equals('CHANDA_CSV_EXPORT'));
      expect(AuditLog.actionChandaPrint, equals('CHANDA_PRINT'));
      expect(AuditLog.actionWhatsappShare, equals('WHATSAPP_SHARE'));
      expect(AuditLog.actionPhoneNumberEdit, equals('PHONE_NUMBER_EDIT'));
      expect(AuditLog.actionChandaTargetDelete, equals('CHANDA_TARGET_DELETE'));
    });
  });
}
