import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/widgets/status_chip.dart';
import 'package:durgapuja_manager/features/custody/presentation/providers/custody_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';

class CashMovementReportScreen extends ConsumerWidget {
  const CashMovementReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvent = ref.watch(activePujaEventProvider);
    final recordsAsync = ref.watch(custodyRecordsProvider);
    final records = recordsAsync.value ?? [];
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Movement & Handover Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(custodyRecordsProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (activeEvent != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Text(
                  'Event: ${activeEvent.name} (${activeEvent.year})',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
              ),

            const SizedBox(height: 16),

            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No cash movement or handover records found.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final r = records[index];
                  final isBank = r.isBankDeposit;

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isBank ? Icons.account_balance : Icons.swap_horiz,
                                    color: isBank ? AppColors.success : Colors.blue.shade800,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    MoneyFormatter.format(r.amount),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              StatusChip(status: r.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${r.fromUserName} ➔ ${r.toUserName} (${isBank ? 'Bank Deposit' : 'Cash Handover'})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Date: ${dateFormat.format(r.handedOverAt)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                          ),
                          if (r.notes != null && r.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Notes: ${r.notes}',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
