import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/widgets/status_chip.dart';
import 'package:durgapuja_manager/features/audit/domain/entities/audit_log.dart';
import 'package:durgapuja_manager/features/audit/presentation/providers/audit_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/widgets/event_selector.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/app_role.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../../domain/entities/collection_custody.dart';
import '../../domain/entities/user_custody_balance.dart';
import '../providers/custody_provider.dart';
import 'add_cash_handover_screen.dart';
import 'add_bank_deposit_screen.dart';

class CustodyDashboardScreen extends ConsumerWidget {
  const CustodyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvent = ref.watch(activePujaEventProvider);
    final summary = ref.watch(custodySummaryProvider);
    final balances = ref.watch(userCustodyBalancesProvider);
    final custodyRecordsAsync = ref.watch(custodyRecordsProvider);
    final custodyRecords = custodyRecordsAsync.value ?? [];
    final currentUser = ref.watch(currentUserProvider).value;

    final effectiveRole = ref.watch(effectiveRoleProvider);
    final permissionService = PermissionService();
    final canHandover = permissionService.hasAnyPermission(
      effectiveRole,
      [Permission.addCollection, Permission.approveCollection, Permission.managePujaEvents],
    );

    final pendingHandovers = custodyRecords.where((r) => r.isPending).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Custody & Handover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Custody',
            onPressed: () {
              ref.invalidate(custodyRecordsProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Custody records refreshed!'), duration: Duration(seconds: 1)),
              );
            },
          ),
          const EventSelector(),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: canHandover
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddCashHandoverScreen()),
                          );
                        },
                        icon: const Icon(Icons.people_outline, size: 18),
                        label: const Text('Cash Handover', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddBankDepositScreen()),
                          );
                        },
                        icon: const Icon(Icons.account_balance, size: 18),
                        label: const Text('Bank Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(custodyRecordsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active Event Banner
              if (activeEvent != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Custody tracking for ${activeEvent.name} (${activeEvent.year})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Summary Header Cards & Reconciliation Box
              _buildCustodySummaryHeader(summary),

              // Pending Handovers Awaiting Confirmation
              if (pendingHandovers.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildPendingHandoversSection(context, ref, pendingHandovers, currentUser, effectiveRole),
              ],

              const SizedBox(height: 20),

              // User-wise In-Hand Custody Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'User-wise Cash Holding',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                  ),
                  Text(
                    '${balances.where((b) => b.hasActiveCustody).length} holding cash',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (balances.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.person_outline, size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      const Text(
                        'No cash collection activity recorded for this event yet.',
                        style: TextStyle(color: AppColors.textSecondaryLight),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    for (int i = 0; i < balances.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _buildUserBalanceCard(context, balances[i], canHandover),
                    ],
                  ],
                ),

              const SizedBox(height: 24),

              // Handover History Timeline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Handover & Deposit History (${custodyRecords.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (custodyRecords.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      const Text(
                        'No handovers or deposits recorded yet.',
                        style: TextStyle(color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    for (int i = 0; i < custodyRecords.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _buildHandoverRecordCard(custodyRecords[i]),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustodySummaryHeader(CustodySummary summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Approved Cash',
                amount: summary.totalApprovedCashCollection,
                icon: Icons.check_circle_outline,
                bgColor: AppColors.primarySurface,
                textColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Bank Deposited',
                amount: summary.totalDeposited,
                icon: Icons.account_balance,
                bgColor: AppColors.successLight,
                textColor: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'With Collectors',
                amount: summary.totalWithCollectors,
                icon: Icons.account_balance_wallet_outlined,
                bgColor: summary.totalWithCollectors > 0 ? Colors.amber.shade50 : AppColors.successLight,
                textColor: summary.totalWithCollectors > 0 ? Colors.amber.shade900 : AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'With Treasurer',
                amount: summary.totalWithTreasurer,
                icon: Icons.shield_outlined,
                bgColor: summary.totalWithTreasurer > 0 ? Colors.purple.shade50 : Colors.grey.shade100,
                textColor: summary.totalWithTreasurer > 0 ? Colors.purple.shade800 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReconciliationCard(summary),
        if (summary.pendingHandoversCount > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade400),
            ),
            child: Row(
              children: [
                const Icon(Icons.pending_actions, size: 18, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${summary.pendingHandoversCount} Pending Handover(s) worth ${MoneyFormatter.format(summary.totalPendingHandovers)} awaiting confirmation',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReconciliationCard(CustodySummary summary) {
    final isMatched = summary.isReconciled;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMatched ? AppColors.successLight : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMatched ? AppColors.success : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isMatched ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                    color: isMatched ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Cash Custody Reconciliation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isMatched ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isMatched ? 'MATCHED ✓' : 'MISMATCH ⚠',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Formula: Approved Cash = With Collectors + With Treasurer + Bank Deposited',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Approved Cash: ${MoneyFormatter.format(summary.totalApprovedCashCollection)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                'Tracked Custody: ${MoneyFormatter.format(summary.reconciledTotal)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          if (!isMatched) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Cash Reconciliation Mismatch: ${MoneyFormatter.format(summary.reconciliationDifference)} unreconciled',
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingHandoversSection(
    BuildContext context,
    WidgetRef ref,
    List<CollectionCustody> pendingHandovers,
    dynamic currentUser,
    AppRole effectiveRole,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_top, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pending Handovers Awaiting Confirmation (${pendingHandovers.length})',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber.shade900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              for (int index = 0; index < pendingHandovers.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final r = pendingHandovers[index];
                    final isSender = currentUser?.uid == r.fromUserId;
                    final isReceiver = currentUser?.uid == r.toUserId;
                    final canConfirm = isReceiver ||
                        (!isSender && (effectiveRole == AppRole.superAdmin || effectiveRole == AppRole.president || effectiveRole == AppRole.treasurer));

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                MoneyFormatter.format(r.amount),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                              ),
                              StatusChip(status: r.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${r.fromUserName}  ➔  ${r.toUserName}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          if (r.notes != null && r.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Notes: ${r.notes}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                          ],
                          const SizedBox(height: 10),
                          if (canConfirm) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(color: AppColors.error),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _handleHandoverAction(context, ref, r, isAccept: false),
                                  child: const Text('Cancel / Reject'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () => _handleHandoverAction(context, ref, r, isAccept: true),
                                  icon: const Icon(Icons.check_circle, size: 16),
                                  label: const Text('Confirm Received'),
                                ),
                              ],
                            ),
                          ] else if (isSender) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Awaiting receiver (${r.toUserName}) confirmation',
                                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondaryLight),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () => _handleHandoverAction(context, ref, r, isAccept: false),
                                    child: const Text('Cancel Handover', style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleHandoverAction(
    BuildContext context,
    WidgetRef ref,
    CollectionCustody record, {
    required bool isAccept,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final currentUser = ref.read(currentUserProvider).value;

    try {
      final updated = record.copyWith(
        status: isAccept ? CollectionCustody.statusReceived : CollectionCustody.statusCancelled,
        receivedAt: isAccept ? DateTime.now() : null,
      );

      await ref.read(custodyRepositoryProvider).updateCustodyRecord(updated);

      // Audit Log
      try {
        final auditRepo = ref.read(auditRepositoryProvider);
        await auditRepo.logAction(AuditLog(
          id: FirebaseFirestore.instance.collection('audit_logs').doc().id,
          eventId: record.eventId,
          userId: currentUser?.uid ?? 'system',
          userName: currentUser?.name ?? 'Reviewer',
          action: isAccept ? 'CUSTODY_HANDOVER_ACCEPT' : 'CUSTODY_HANDOVER_CANCEL',
          entityType: 'COLLECTION_CUSTODY',
          entityId: record.id,
          timestamp: DateTime.now(),
          metadata: {
            'amount': record.amount,
            'fromUserId': record.fromUserId,
            'toUserId': record.toUserId,
            'isAccept': isAccept,
          },
        ));
      } catch (_) {}

      ref.invalidate(custodyRecordsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isAccept
                ? 'Handover of ${MoneyFormatter.format(record.amount)} confirmed and accepted!'
                : 'Handover cancelled.',
          ),
          backgroundColor: isAccept ? AppColors.success : Colors.grey.shade700,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Action failed: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    }
  }

  Widget _buildSummaryCard({
    required String title,
    required int amount,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            MoneyFormatter.format(amount),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBalanceCard(BuildContext context, UserCustodyBalance b, bool canHandover) {
    final hasCustody = b.hasActiveCustody;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: hasCustody ? AppColors.primarySurface : Colors.grey.shade100,
                      child: Text(
                        b.userName.isNotEmpty ? b.userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: hasCustody ? AppColors.primary : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.userName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                        ),
                        Text(
                          hasCustody ? 'Holding Cash' : 'Custody Cleared',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasCustody ? Colors.amber.shade900 : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasCustody ? Colors.amber.shade50 : AppColors.successLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: hasCustody ? Colors.amber.shade400 : AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('In Custody', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                      Text(
                        MoneyFormatter.format(b.currentCustody),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: hasCustody ? Colors.amber.shade900 : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSubMetric('Cash Collected', b.totalCollected),
                if (b.totalReceived > 0) _buildSubMetric('Received', b.totalReceived),
                if (b.totalHandedOver > 0) _buildSubMetric('Handed Over', b.totalHandedOver),
                if (b.totalDeposited > 0) _buildSubMetric('Deposited', b.totalDeposited),
                if (b.hasPendingOutgoing) _buildSubMetric('In-Flight (Pending)', b.pendingOutgoing),
              ],
            ),
            if (canHandover && hasCustody) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddCashHandoverScreen(prefilledSender: b),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people_outline, size: 15),
                      label: const Text('Cash Handover', style: TextStyle(fontSize: 12)),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddBankDepositScreen(prefilledSender: b),
                          ),
                        );
                      },
                      icon: const Icon(Icons.account_balance, size: 15),
                      label: const Text('Bank Deposit', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubMetric(String label, int amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
        const SizedBox(height: 2),
        Text(
          MoneyFormatter.format(amount),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        ),
      ],
    );
  }

  Widget _buildHandoverRecordCard(CollectionCustody r) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final isBank = r.isBankDeposit;

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
                        color: isBank ? AppColors.successLight : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isBank ? Icons.account_balance : Icons.swap_horiz,
                        color: isBank ? AppColors.success : Colors.blue.shade800,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MoneyFormatter.format(r.amount),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                        ),
                        Text(
                          dateFormat.format(r.handedOverAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ],
                ),
                StatusChip(status: r.status),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sender', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                        Text(r.fromUserName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(isBank ? 'Bank Destination' : 'Receiver', style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                        Text(
                          r.toUserName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isBank ? AppColors.success : AppColors.primary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (r.notes != null && r.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Notes: ${r.notes}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondaryLight),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
