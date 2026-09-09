import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/features/chanda/presentation/providers/chanda_provider.dart';
import 'package:durgapuja_manager/features/collection/presentation/providers/collection_provider.dart';
import 'package:durgapuja_manager/features/collection/presentation/widgets/edit_collection_dialog.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../providers/reports_provider.dart';

class PersonWiseCollectionScreen extends ConsumerStatefulWidget {
  const PersonWiseCollectionScreen({super.key});

  @override
  ConsumerState<PersonWiseCollectionScreen> createState() => _PersonWiseCollectionScreenState();
}

class _PersonWiseCollectionScreenState extends ConsumerState<PersonWiseCollectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  Future<void> _showEditPersonDialog(BuildContext context, PersonDonationSummary item) async {
    final nameController = TextEditingController(text: item.donorName);
    final mobileController = TextEditingController(text: item.mobile ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_pin, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Edit Person Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Updating will rename this person and update mobile number across all ${item.transactionCount} transaction(s) and targets.',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Person / Donor Name *',
                      hintText: 'Enter full name (e.g. Titu Behera)',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Name cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      hintText: '10-digit mobile number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final newName = nameController.text.trim();
                      final newMobile = mobileController.text.trim();

                      setDialogState(() => isSubmitting = true);

                      try {
                        final firestore = FirebaseFirestore.instance;
                        final batch = firestore.batch();

                        // 1. Update all collections for this person
                        for (final col in item.items) {
                          final ref = firestore.collection('collections').doc(col.id);
                          batch.update(ref, {
                            'donorName': newName,
                            'mobileNumber': newMobile.isNotEmpty ? newMobile : null,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                        }

                        // 2. Also update matching chanda_targets if any
                        final targetSnap = await firestore
                            .collection('chanda_targets')
                            .where('personName', isEqualTo: item.donorName)
                            .get();
                        for (final doc in targetSnap.docs) {
                          batch.update(doc.reference, {
                            'personName': newName,
                            if (newMobile.isNotEmpty) 'mobileNumber': newMobile,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                        }

                        await batch.commit();

                        if (context.mounted) {
                          ref.invalidate(collectionsProvider);
                          ref.invalidate(personWiseReportProvider);
                          ref.invalidate(chandaTargetsProvider);
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Updated to "$newName" successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating: ${e.toString()}'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              label: Text(isSubmitting ? 'Saving...' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(personWiseReportProvider);
    final namesMap = ref.watch(userNamesMapProvider).value ?? {};
    final userRole = ref.watch(effectiveRoleProvider);
    final canEditCollection = PermissionService().hasPermission(userRole, Permission.editCollection);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Report'),
      ),
      body: reportAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No approved donor records found.'),
            );
          }

          final filteredList = list.where((item) {
            if (_searchQuery.isEmpty) return true;
            final query = _searchQuery.toLowerCase();
            final nameMatch = item.donorName.toLowerCase().contains(query);
            final mobileMatch = item.mobile?.toLowerCase().contains(query) ?? false;
            final transactionMatch = item.items.any((tx) =>
                tx.purpose.toLowerCase().contains(query) ||
                (tx.remark?.toLowerCase().contains(query) ?? false) ||
                tx.amount.toString().contains(query));
            return nameMatch || mobileMatch || transactionMatch;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search donor name, mobile, month...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No donors matching "$_searchQuery"',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Text('Clear Search'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.donorName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  if (canEditCollection)
                                    IconButton(
                                      icon: const Icon(Icons.edit_note, size: 24, color: AppColors.primary),
                                      tooltip: 'Edit Person Name & Mobile',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _showEditPersonDialog(context, item),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                'Total: ${MoneyFormatter.format(item.totalAmount)} (${item.transactionCount} donations)',
                                style: const TextStyle(color: Colors.green),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (item.mobile != null && item.mobile!.isNotEmpty)
                                            Text(
                                              'Mobile: ${item.mobile}',
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                            )
                                          else
                                            const Text(
                                              'No Mobile Number',
                                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.grey),
                                            ),
                                          if (canEditCollection)
                                            OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                visualDensity: VisualDensity.compact,
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              ),
                                              icon: const Icon(Icons.edit, size: 15),
                                              label: const Text('Edit Person', style: TextStyle(fontSize: 12)),
                                              onPressed: () => _showEditPersonDialog(context, item),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'All Transactions:',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 8),
                                      ...item.items.asMap().entries.map((entry) {
                                        final idx = entry.key + 1;
                                        final tx = entry.value;

                                        final collectorRaw = tx.collectedBy.isNotEmpty ? tx.collectedBy : tx.createdBy;
                                        final collectedByName = namesMap[collectorRaw] ??
                                            (collectorRaw.startsWith('user_pre_')
                                                ? collectorRaw.replaceAll('user_pre_', '').toUpperCase()
                                                : collectorRaw);
                                        final approvedByName = tx.approvedBy != null && tx.approvedBy!.isNotEmpty
                                            ? (namesMap[tx.approvedBy!] ?? tx.approvedBy!)
                                            : 'Super Admin';

                                        final approvedDateStr = tx.approvedAt != null
                                            ? dateFormat.format(tx.approvedAt!)
                                            : null;

                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Transaction #$idx • ${dateFormat.format(tx.date)}',
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                    ),
                                                    if (tx.remark != null && tx.remark!.isNotEmpty) ...[
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        tx.remark!,
                                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                                      ),
                                                    ] else if (tx.purpose.isNotEmpty) ...[
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        tx.purpose,
                                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                                      ),
                                                    ],
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Payment Mode: ${tx.paymentMode.label}',
                                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(color: Colors.grey.shade200),
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
                                                                  'Collected by: $collectedByName • ${dateFormat.format(tx.date)}',
                                                                  style: const TextStyle(
                                                                    fontSize: 10,
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
                                                                    fontSize: 10,
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
                                                      color: Colors.green,
                                                      fontSize: 14,
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
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const LoadingView(message: 'Generating person report...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(personWiseReportProvider),
        ),
      ),
    );
  }
}
