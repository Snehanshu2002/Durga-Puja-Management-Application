import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/widgets/status_chip.dart';
import 'package:durgapuja_manager/features/chanda/presentation/providers/chanda_provider.dart';
import 'package:durgapuja_manager/features/chanda/presentation/screens/chanda_detail_screen.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';

class ChandaReportScreen extends ConsumerStatefulWidget {
  const ChandaReportScreen({super.key});

  @override
  ConsumerState<ChandaReportScreen> createState() => _ChandaReportScreenState();
}

class _ChandaReportScreenState extends ConsumerState<ChandaReportScreen> {
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
    final summary = ref.watch(chandaSummaryProvider);
    final list = ref.watch(chandaWithProgressListProvider);

    final query = _searchQuery.trim().toLowerCase();
    final filtered = list.where((item) {
      if (query.isEmpty) return true;
      final nameMatches = item.target.personName.toLowerCase().contains(query);
      final phoneMatches = item.target.mobileNumber?.toLowerCase().contains(query) ?? false;
      return nameMatches || phoneMatches;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chanda Pledges Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(chandaTargetsProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Banner
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

            // Summary Metrics
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
                      _buildSummaryMetric('Total Target', summary.totalTarget, AppColors.primary),
                      _buildSummaryMetric('Total Collected', summary.totalCollected, AppColors.success),
                      _buildSummaryMetric('Total Remaining', summary.totalRemaining, summary.totalRemaining > 0 ? AppColors.expense : AppColors.success),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCountBadge('Total Members', summary.totalMembers, Colors.blueGrey),
                      _buildCountBadge('Fully Paid', summary.fullyPaidCount, AppColors.success),
                      _buildCountBadge('Partial', summary.partialPaidCount, Colors.orange),
                      _buildCountBadge('Pending', summary.pendingCount, AppColors.expense),
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
                hintText: 'Search donor name or mobile...',
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

            // Data Table / List
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No pledge records match your search.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.target.personName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          StatusChip(status: item.computedStatus),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Target: ${MoneyFormatter.format(item.targetAmount)}'),
                            Text('Paid: ${MoneyFormatter.format(item.paidAmount)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                            if (item.hasExcess)
                              Text('Excess: +${MoneyFormatter.format(item.excessAmount)}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))
                            else
                              Text('Due: ${MoneyFormatter.format(item.remainingAmount)}', style: TextStyle(color: item.remainingAmount > 0 ? AppColors.expense : AppColors.success, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChandaDetailScreen(targetId: item.target.id),
                          ),
                        );
                      },
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildCountBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
      ],
    );
  }
}
