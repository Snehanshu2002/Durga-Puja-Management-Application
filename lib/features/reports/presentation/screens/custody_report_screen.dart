import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/features/custody/presentation/providers/custody_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';

class CustodyReportScreen extends ConsumerStatefulWidget {
  const CustodyReportScreen({super.key});

  @override
  ConsumerState<CustodyReportScreen> createState() => _CustodyReportScreenState();
}

class _CustodyReportScreenState extends ConsumerState<CustodyReportScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeEvent = ref.watch(activePujaEventProvider);
    final summary = ref.watch(custodySummaryProvider);
    final balances = ref.watch(userCustodyBalancesProvider);

    final query = _searchQuery.trim().toLowerCase();
    final filtered = balances.where((b) {
      if (query.isEmpty) return true;
      return b.userName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Custody Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(custodyRecordsProvider);
            },
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

            const SizedBox(height: 14),

            // Reconciliation Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryMetric('Approved Cash', summary.totalApprovedCashCollection, AppColors.primary),
                      _buildSummaryMetric('Bank Deposited', summary.totalDeposited, AppColors.success),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryMetric('With Collectors', summary.totalWithCollectors, Colors.amber.shade900),
                      _buildSummaryMetric('With Treasurer', summary.totalWithTreasurer, Colors.purple.shade800),
                      _buildSummaryMetric('In-Flight (Pending)', summary.totalPendingHandovers, Colors.orange.shade800),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reconciliation: ${MoneyFormatter.format(summary.reconciledTotal)} / ${MoneyFormatter.format(summary.totalApprovedCashCollection)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: summary.isReconciled ? AppColors.success : AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          summary.isReconciled ? 'MATCHED ✓' : 'MISMATCH: ${MoneyFormatter.format(summary.reconciliationDifference)}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search collector name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),

            const SizedBox(height: 16),

            // Collector List
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No collector records found.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final b = filtered[index];
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
                              Text(
                                b.userName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: b.hasActiveCustody ? Colors.amber.shade50 : AppColors.successLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'In Custody: ${MoneyFormatter.format(b.currentCustody)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: b.hasActiveCustody ? Colors.amber.shade900 : AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Collected: ${MoneyFormatter.format(b.totalCollected)}', style: const TextStyle(fontSize: 12)),
                              Text('Handed Over: ${MoneyFormatter.format(b.totalHandedOver)}', style: const TextStyle(fontSize: 12)),
                              Text('Deposited: ${MoneyFormatter.format(b.totalDeposited)}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
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

  Widget _buildSummaryMetric(String label, int amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
        const SizedBox(height: 4),
        Text(
          MoneyFormatter.format(amount),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
