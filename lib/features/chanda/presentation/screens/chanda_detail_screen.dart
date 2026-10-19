import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/utils/phone_launcher.dart';
import 'package:durgapuja_manager/core/providers/whatsapp_settings_provider.dart';
import 'package:durgapuja_manager/core/utils/whatsapp_share_helper.dart';
import 'package:durgapuja_manager/core/widgets/status_chip.dart';
import 'package:durgapuja_manager/features/audit/domain/entities/audit_log.dart';
import 'package:durgapuja_manager/features/audit/presentation/providers/audit_provider.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/collection/presentation/screens/add_collection_screen.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/receipts/domain/services/receipt_pdf_service.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../../domain/entities/chanda_target_with_progress.dart';
import '../providers/chanda_provider.dart';
import 'add_edit_chanda_target_screen.dart';

class ChandaDetailScreen extends ConsumerWidget {
  final String targetId;

  const ChandaDetailScreen({super.key, required this.targetId});

  void _logAuditAction({
    required WidgetRef ref,
    required String action,
    required String eventId,
    required String targetId,
    required String memberName,
    Map<String, dynamic>? metadata,
  }) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final log = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: eventId,
      userId: user.uid,
      userName: user.name,
      action: action,
      entityType: 'CHANDA_TARGET',
      entityId: targetId,
      timestamp: DateTime.now(),
      metadata: {
        'memberName': memberName,
        ...?metadata,
      },
    );

    ref.read(auditRepositoryProvider).logAction(log).catchError((_) {});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(chandaWithProgressListProvider);
    final activeEvent = ref.watch(activePujaEventProvider);
    final effectiveRole = ref.watch(effectiveRoleProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final permissionService = PermissionService();
    final waConfig = ref.watch(whatsAppSettingsProvider);

    final foundList = list.where((element) => element.target.id == targetId).toList();
    if (foundList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pledge Detail')),
        body: const Center(child: Text('Chanda target not found.')),
      );
    }
    final item = foundList.first;

    final canAddPayment = permissionService.hasPermission(effectiveRole, Permission.addCollection);
    final canEditTarget = permissionService.hasAnyPermission(
      effectiveRole,
      [Permission.managePujaEvents, Permission.approveCollection],
    );
    final canDeleteTarget = effectiveRole.isSuperAdmin || (currentUser != null && currentUser.role.isSuperAdmin);

    final eventName = activeEvent?.name ?? 'Opera / Jatra';
    final eventYear = activeEvent?.year ?? 2026;
    final hasPhone = item.target.mobileNumber != null && item.target.mobileNumber!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.target.personName),
        actions: [
          if (canEditTarget)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Pledge Target',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditChandaTargetScreen(target: item.target),
                  ),
                );
              },
            ),
          if (canDeleteTarget)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'Delete Chanda Target',
              onPressed: () => _confirmDeleteTarget(context, ref, item),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Target Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.target.personName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (hasPhone)
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => PhoneLauncher.makePhoneCall(context, item.target.mobileNumber!),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.phone_in_talk, size: 15, color: AppColors.primary),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.target.mobileNumber!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                InkWell(
                                  onTap: () {
                                    if (canEditTarget) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddEditChandaTargetScreen(target: item.target),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber.shade900),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Missing Phone • Add Number',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        StatusChip(status: item.computedStatus),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Quick Action Buttons (WhatsApp Reminder, Call, Edit)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          onPressed: () {
                            final msg = WhatsAppShareHelper.formatChandaDueReminder(
                              orgName: 'Durga Puja Committee',
                              eventName: eventName,
                              eventYear: eventYear,
                              memberName: item.target.personName,
                              targetAmount: item.targetAmount,
                              paidAmount: item.paidAmount,
                              remainingAmount: item.remainingAmount,
                              config: waConfig,
                            );

                            WhatsAppShareHelper.shareToWhatsApp(
                              context: context,
                              phoneNumber: item.target.mobileNumber,
                              message: msg,
                              onShareSuccess: () {
                                _logAuditAction(
                                  ref: ref,
                                  action: AuditLog.actionWhatsappShare,
                                  eventId: item.target.eventId,
                                  targetId: item.target.id,
                                  memberName: item.target.personName,
                                  metadata: {'type': 'CHANDA_REMINDER'},
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                          label: const Text('WhatsApp Reminder', style: TextStyle(fontSize: 12)),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            side: const BorderSide(color: Color(0xFF5f259f)),
                            foregroundColor: const Color(0xFF5f259f),
                          ),
                          onPressed: () => WhatsAppShareHelper.showPaymentQrDialog(context, config: waConfig),
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                          label: const Text('QR Scanner', style: TextStyle(fontSize: 12)),
                        ),
                        if (hasPhone)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              side: const BorderSide(color: AppColors.success),
                              foregroundColor: AppColors.success,
                            ),
                            onPressed: () => PhoneLauncher.makePhoneCall(context, item.target.mobileNumber!),
                            icon: const Icon(Icons.phone_in_talk, size: 15),
                            label: const Text('Call', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricTile(
                          label: 'Target Pledge',
                          amount: item.targetAmount,
                          color: AppColors.primary,
                        ),
                        _buildMetricTile(
                          label: 'Approved Paid',
                          amount: item.paidAmount,
                          color: AppColors.success,
                        ),
                        if (item.hasExcess)
                          _buildMetricTile(
                            label: 'Excess Paid',
                            amount: item.excessAmount,
                            color: Colors.teal,
                          )
                        else
                          _buildMetricTile(
                            label: 'Remaining Due',
                            amount: item.remainingAmount,
                            color: item.remainingAmount > 0 ? AppColors.expense : AppColors.success,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: item.progressPercentage,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.isFullyPaid
                              ? AppColors.success
                              : item.isPartial
                                  ? Colors.orange
                                  : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(item.progressPercentage * 100).toStringAsFixed(1)}% Paid',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section Header & Add Payment Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment History (${item.linkedCollections.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                if (canAddPayment && !item.isFullyPaid && !item.isCancelled)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddCollectionScreen(
                            initialChandaTargetId: item.target.id,
                            initialDonorName: item.target.personName,
                            initialMobileNumber: item.target.mobileNumber,
                            initialAmount: item.remainingAmount,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Add Payment'),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            if (item.linkedCollections.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    const Text(
                      'No payments recorded yet for this pledge.',
                      style: TextStyle(color: AppColors.textSecondaryLight),
                    ),
                    if (canAddPayment && !item.isCancelled) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddCollectionScreen(
                                initialChandaTargetId: item.target.id,
                                initialDonorName: item.target.personName,
                                initialMobileNumber: item.target.mobileNumber,
                                initialAmount: item.remainingAmount,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Record First Payment'),
                      ),
                    ],
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: item.linkedCollections.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final c = item.linkedCollections[index];
                  return _buildPaymentCard(
                    context,
                    ref,
                    c,
                    eventName,
                    eventYear,
                    item.target.personName,
                    item.target.mobileNumber,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required int amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 4),
        Text(
          MoneyFormatter.format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    WidgetRef ref,
    CollectionEntity c,
    String eventName,
    int eventYear,
    String memberName,
    String? memberMobile,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final receiptNo = 'DP-${c.date.year}-${c.id.hashCode.abs().toString().padLeft(6, '0')}';
    final displayName = memberName.isNotEmpty ? memberName : c.donorName;
    final displayMobile = (memberMobile != null && memberMobile.isNotEmpty) ? memberMobile : c.mobileNumber;
    final waConfig = ref.watch(whatsAppSettingsProvider);
    final receiptCollection = c.copyWith(
      donorName: displayName,
      mobileNumber: displayMobile,
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.isApproved
                            ? AppColors.successLight
                            : c.isPending
                                ? Colors.amber.shade50
                                : AppColors.expenseLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        c.isApproved
                            ? Icons.check_circle_outline
                            : c.isPending
                                ? Icons.pending_outlined
                                : Icons.cancel_outlined,
                        color: c.isApproved
                            ? AppColors.success
                            : c.isPending
                                ? Colors.amber.shade800
                                : AppColors.expense,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MoneyFormatter.format(c.amount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          '${c.paymentMode.label} • ${dateFormat.format(c.date)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                StatusChip(status: c.status),
              ],
            ),
            if (c.transactionId != null && c.transactionId!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Ref / Txn ID: ${c.transactionId}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
            ],
            if (c.remark != null && c.remark!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Remark: ${c.remark}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
            if (c.isApproved) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // WhatsApp Share Receipt Button
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: const Color(0xFF128C7E),
                    ),
                    onPressed: () {
                      final msg = WhatsAppShareHelper.formatCollectionReceipt(
                        orgName: 'Durga Puja Committee',
                        eventName: eventName,
                        eventYear: eventYear,
                        donorName: displayName,
                        amount: c.amount,
                        paymentMode: c.paymentMode.label,
                        receiptNumber: receiptNo,
                        date: c.date,
                        collectedBy: c.collectedBy,
                        language: waConfig.language,
                      );

                      WhatsAppShareHelper.shareToWhatsApp(
                        context: context,
                        phoneNumber: displayMobile,
                        message: msg,
                        onShareSuccess: () {
                          _logAuditAction(
                            ref: ref,
                            action: AuditLog.actionWhatsappShare,
                            eventId: c.eventId,
                            targetId: c.id,
                            memberName: displayName,
                            metadata: {'type': 'COLLECTION_RECEIPT', 'receiptNumber': receiptNo},
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                    label: const Text('Share Receipt', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () async {
                      final pdfBytes = await ReceiptPdfService.generateDonationReceipt(
                        collection: receiptCollection,
                        receiptNumber: receiptNo,
                        committeeName: 'Durga Puja Committee',
                        eventName: eventName,
                        reviewerRoleName: 'Treasurer',
                      );
                      await Printing.layoutPdf(
                        onLayout: (_) => pdfBytes,
                        name: 'Receipt_$displayName.pdf',
                      );
                    },
                    icon: const Icon(Icons.print, size: 15),
                    label: const Text('Print Receipt', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTarget(
    BuildContext context,
    WidgetRef ref,
    ChandaTargetWithProgress item,
  ) {
    if (item.paidAmount > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.expense),
              const SizedBox(width: 8),
              const Text('Cannot Delete Target'),
            ],
          ),
          content: Text(
            'Cannot delete pledge for "${item.target.personName}" because approved collections totaling ${MoneyFormatter.format(item.paidAmount)} have already been recorded.\n\nTo protect financial data integrity, records with existing transactions cannot be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: AppColors.expense),
            const SizedBox(width: 8),
            const Text('Delete Chanda Target'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete the Chanda pledge for "${item.target.personName}" (Target: ${MoneyFormatter.format(item.targetAmount)})?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog

              try {
                final repo = ref.read(chandaRepositoryProvider);
                await repo.deleteChandaTarget(item.target.id);

                _logAuditAction(
                  ref: ref,
                  action: AuditLog.actionChandaTargetDelete,
                  eventId: item.target.eventId,
                  targetId: item.target.id,
                  memberName: item.target.personName,
                  metadata: {
                    'targetAmount': item.targetAmount,
                    'deletedBy': ref.read(currentUserProvider).value?.name ?? 'Admin',
                  },
                );

                ref.invalidate(chandaTargetsProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pledge for "${item.target.personName}" deleted successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.pop(context); // Go back to ChandaDashboardScreen
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete target: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
