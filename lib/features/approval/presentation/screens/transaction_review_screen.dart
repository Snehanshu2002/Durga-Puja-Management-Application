import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/widgets/app_button.dart';
import 'package:durgapuja_manager/core/widgets/status_chip.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../providers/approval_provider.dart';
import '../widgets/rejection_dialog.dart';

class TransactionReviewScreen extends ConsumerStatefulWidget {
  final CollectionEntity? collection;
  final ExpenseEntity? expense;

  const TransactionReviewScreen({
    super.key,
    this.collection,
    this.expense,
  }) : assert(collection != null || expense != null, 'Provide collection or expense');

  @override
  ConsumerState<TransactionReviewScreen> createState() =>
      _TransactionReviewScreenState();
}

class _TransactionReviewScreenState
    extends ConsumerState<TransactionReviewScreen> {
  bool _isLoading = false;

  Future<void> _approve() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      if (widget.collection != null) {
        final usecase = ref.read(approveCollectionUseCaseProvider);
        await usecase.execute(
          collection: widget.collection!,
          reviewer: user,
        );
        ref.invalidate(pendingCollectionsProvider);
      } else if (widget.expense != null) {
        final usecase = ref.read(approveExpenseUseCaseProvider);
        await usecase.execute(
          expense: widget.expense!,
          reviewer: user,
        );
        ref.invalidate(pendingExpensesProvider);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Approved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reject() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const RejectionDialog(),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      if (widget.collection != null) {
        final usecase = ref.read(rejectCollectionUseCaseProvider);
        await usecase.execute(
          collection: widget.collection!,
          reviewer: user,
          rejectionReason: reason,
        );
        ref.invalidate(pendingCollectionsProvider);
      } else if (widget.expense != null) {
        final usecase = ref.read(rejectExpenseUseCaseProvider);
        await usecase.execute(
          expense: widget.expense!,
          reviewer: user,
          rejectionReason: reason,
        );
        ref.invalidate(pendingExpensesProvider);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rejected.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImageZoomModal(String photoData) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Photo Proof Preview'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            InteractiveViewer(
              child: _buildImageWidget(photoData, height: 350, fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String dataStr, {double height = 180, BoxFit fit = BoxFit.cover}) {
    if (dataStr.startsWith('data:image')) {
      try {
        final base64Content = dataStr.split(',').last;
        final bytes = base64Decode(base64Content);
        return Image.memory(bytes, height: height, width: double.infinity, fit: fit);
      } catch (_) {
        return Container(
          height: height,
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
        );
      }
    } else if (dataStr.startsWith('http')) {
      return Image.network(dataStr, height: height, width: double.infinity, fit: fit);
    }
    return Container(
      height: height,
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCollection = widget.collection != null;
    final collection = widget.collection;
    final expense = widget.expense;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final photoProofUrl = isCollection ? collection!.paymentScreenshotUrl : expense!.billUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCollection ? 'Review Collection' : 'Review Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isCollection ? 'COLLECTION' : 'EXPENSE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCollection ? Colors.green : Colors.red,
                          ),
                        ),
                        StatusChip(
                          status: isCollection
                              ? collection!.status
                              : expense!.status,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      '₹${isCollection ? collection!.amount : expense!.amount}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: isCollection
                      ? [
                          _buildDetailRow('Donor Name', collection!.donorName),
                          if (collection.mobileNumber != null)
                            _buildDetailRow('Mobile', collection.mobileNumber!),
                          _buildDetailRow('Purpose', collection.purpose),
                          _buildDetailRow(
                              'Payment Mode', collection.paymentMode.label),
                          if (collection.transactionId != null)
                            _buildDetailRow(
                                'Transaction ID', collection.transactionId!),
                          _buildDetailRow(
                              'Date', dateFormat.format(collection.date)),
                          if (collection.remark != null)
                            _buildDetailRow('Remark', collection.remark!),
                        ]
                      : [
                          _buildDetailRow('Paid To', expense!.paidTo),
                          _buildDetailRow('Category', expense.categoryId),
                          _buildDetailRow('Description', expense.description),
                          _buildDetailRow(
                              'Payment Mode', expense.paymentMode.label),
                          _buildDetailRow(
                              'Date', dateFormat.format(expense.date)),
                          if (expense.remark != null)
                            _buildDetailRow('Remark', expense.remark!),
                        ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // PHOTO PROOF PREVIEW FOR APPROVER
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.blueAccent, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Text(
                              'Photo Proof / Receipt Voucher',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                        if (photoProofUrl != null && photoProofUrl.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => _showImageZoomModal(photoProofUrl),
                            icon: const Icon(Icons.zoom_in, size: 18),
                            label: const Text('Zoom'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (photoProofUrl != null && photoProofUrl.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showImageZoomModal(photoProofUrl),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildImageWidget(photoProofUrl, height: 200),
                        ),
                      )
                    else
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'No photo proof attached for this entry.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Reject',
                    isOutlined: true,
                    isLoading: _isLoading,
                    onPressed: _reject,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: 'Approve',
                    isLoading: _isLoading,
                    onPressed: _approve,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
