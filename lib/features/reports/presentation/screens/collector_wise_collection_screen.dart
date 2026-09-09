import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/features/collection/presentation/widgets/edit_collection_dialog.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../providers/reports_provider.dart';

class CollectorWiseCollectionScreen extends ConsumerStatefulWidget {
  const CollectorWiseCollectionScreen({super.key});

  @override
  ConsumerState<CollectorWiseCollectionScreen> createState() =>
      _CollectorWiseCollectionScreenState();
}

class _CollectorWiseCollectionScreenState
    extends ConsumerState<CollectorWiseCollectionScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showImageZoom(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          width: MediaQuery.of(ctx).size.width * 0.95,
          height: MediaQuery.of(ctx).size.height * 0.85,
          child: Column(
            children: [
              AppBar(
                title: const Text('Receipt Photo Proof'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, e, s) => const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Failed to load image.'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(collectorWiseReportProvider);
    final namesMap = ref.watch(userNamesMapProvider).value ?? {};
    final userRole = ref.watch(effectiveRoleProvider);
    final canEditCollection = PermissionService().hasPermission(userRole, Permission.editCollection);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collector Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(collectorWiseReportProvider),
          ),
        ],
      ),
      body: reportAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No collector transaction records found.'),
            );
          }

          // Filter collectors based on search query
          final query = _searchQuery.trim().toLowerCase();
          final filteredList = list.where((item) {
            if (query.isEmpty) return true;
            final nameMatch = item.collectorName.toLowerCase().contains(query);
            final emailMatch = (item.collectorEmail ?? '').toLowerCase().contains(query);
            final uidMatch = item.collectorUid.toLowerCase().contains(query);
            final itemMatch = item.items.any((tx) =>
                tx.donorName.toLowerCase().contains(query) ||
                tx.purpose.toLowerCase().contains(query) ||
                tx.amount.toString().contains(query));
            return nameMatch || emailMatch || uidMatch || itemMatch;
          }).toList();

          final grandTotal = list.fold<int>(0, (sum, i) => sum + i.totalAmount);
          final totalTxCount = list.fold<int>(0, (sum, i) => sum + i.transactionCount);

          return Column(
            children: [
              // Search Bar
              Container(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search collector by name, email, or donor...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              // Overview Header Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Collectors: ${list.length}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalTxCount Approved Collections',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Grand Collection',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          MoneyFormatter.format(grandTotal),
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Collector List
              Expanded(
                child: filteredList.isEmpty
                    ? const Center(
                        child: Text('No collectors match your search query.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primarySurface,
                                  child: Text(
                                    item.collectorName.isNotEmpty
                                        ? item.collectorName[0].toUpperCase()
                                        : '${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.collectorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.collectorEmail != null && item.collectorEmail!.isNotEmpty)
                                      Text(
                                        item.collectorEmail!,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                      ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (item.collectorRole != null) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.collectorRole!,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryDark,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Text(
                                          '${item.transactionCount} transactions',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      MoneyFormatter.format(item.totalAmount),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const Text(
                                      'Tap to view',
                                      style: TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                children: [
                                  const Divider(height: 1),
                                  Container(
                                    color: Colors.grey.shade50,
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Text(
                                            'Collections by ${item.collectorName} (${item.items.length}):',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                        ),
                                        ...item.items.map((tx) {
                                          final collectorRaw = tx.collectedBy.isNotEmpty ? tx.collectedBy : tx.createdBy;
                                          final collectedByName = namesMap[collectorRaw] ??
                                              (collectorRaw.startsWith('user_pre_')
                                                  ? collectorRaw.replaceAll('user_pre_', '').toUpperCase()
                                                  : collectorRaw);
                                          final approvedByName = tx.approvedBy != null && tx.approvedBy!.isNotEmpty
                                              ? (namesMap[tx.approvedBy!] ?? tx.approvedBy!)
                                              : 'Super Admin';

                                          final dateStr =
                                              '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}';
                                          final approvedDateStr = tx.approvedAt != null
                                              ? '${tx.approvedAt!.day.toString().padLeft(2, '0')}/${tx.approvedAt!.month.toString().padLeft(2, '0')}/${tx.approvedAt!.year}'
                                              : null;

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        tx.donorName,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Purpose: ${tx.purpose}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade700,
                                                        ),
                                                      ),
                                                      if (tx.remark?.isNotEmpty == true)
                                                        Text(
                                                          'Remark: ${tx.remark}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.grey.shade600,
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                        ),
                                                      const SizedBox(height: 6),
                                                      Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade100,
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                const Icon(Icons.person, size: 12, color: AppColors.primary),
                                                                const SizedBox(width: 4),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Collected by: $collectedByName • $dateStr',
                                                                    style: const TextStyle(
                                                                      fontSize: 11,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: Colors.black87,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Row(
                                                              children: [
                                                                const Icon(Icons.verified, size: 12, color: Colors.green),
                                                                const SizedBox(width: 4),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Approved by: $approvedByName${approvedDateStr != null ? ' • $approvedDateStr' : ''}',
                                                                    style: const TextStyle(
                                                                      fontSize: 11,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: Colors.green,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      MoneyFormatter.format(tx.amount),
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                        color: AppColors.primaryDark,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if (tx.paymentScreenshotUrl != null && tx.paymentScreenshotUrl!.isNotEmpty) ...[
                                                          IconButton(
                                                            icon: const Icon(Icons.photo, size: 20, color: Colors.blue),
                                                            tooltip: 'View Receipt Photo',
                                                            constraints: const BoxConstraints(),
                                                            padding: const EdgeInsets.all(4),
                                                            onPressed: () => _showImageZoom(context, tx.paymentScreenshotUrl!),
                                                          ),
                                                          const SizedBox(width: 4),
                                                        ],
                                                        if (canEditCollection) ...[
                                                          IconButton(
                                                            icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                                                            tooltip: 'Edit Collection Entry',
                                                            constraints: const BoxConstraints(),
                                                            padding: const EdgeInsets.all(4),
                                                            onPressed: () => EditCollectionDialog.show(context, tx),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const LoadingView(message: 'Generating collector report...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(collectorWiseReportProvider),
        ),
      ),
    );
  }
}
