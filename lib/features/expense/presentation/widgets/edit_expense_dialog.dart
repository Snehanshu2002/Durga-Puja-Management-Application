import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/core/services/storage_service.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:durgapuja_manager/features/expense/presentation/providers/expense_provider.dart';
import 'package:durgapuja_manager/features/expense/presentation/screens/category_management_screen.dart';
import 'package:durgapuja_manager/features/reports/presentation/providers/reports_provider.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';

class EditExpenseDialog extends ConsumerStatefulWidget {
  final ExpenseEntity expense;

  const EditExpenseDialog({
    super.key,
    required this.expense,
  });

  static Future<void> show(BuildContext context, ExpenseEntity expense) {
    return showDialog<void>(
      context: context,
      builder: (context) => EditExpenseDialog(expense: expense),
    );
  }

  @override
  ConsumerState<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends ConsumerState<EditExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _paidToController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _remarkController;
  late String _selectedCategoryId;
  late PaymentMode _selectedPaymentMode;

  bool _isSaving = false;
  XFile? _newVoucherFile;
  Uint8List? _newVoucherBytes;
  String? _currentVoucherUrl;
  bool _removeVoucher = false;

  @override
  void initState() {
    super.initState();
    _paidToController = TextEditingController(text: widget.expense.paidTo);
    _descriptionController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _remarkController = TextEditingController(text: widget.expense.remark ?? '');
    _selectedCategoryId = widget.expense.categoryId;
    _selectedPaymentMode = widget.expense.paymentMode;
    _currentVoucherUrl = widget.expense.voucherUrl ?? widget.expense.billUrl;
  }

  @override
  void dispose() {
    _paidToController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _pickVoucherImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 55,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _newVoucherFile = picked;
          _newVoucherBytes = bytes;
          _removeVoucher = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageZoom(String imageUrl) {
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
                title: const Text('Expense Voucher / Bill'),
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

  Future<void> _submit() async {
    final userRole = ref.read(effectiveRoleProvider);
    if (!PermissionService().hasPermission(userRole, Permission.editExpense)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied: You do not have permission to edit expense entries.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.expense.isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Approved transactions cannot be modified directly. Accounting history must be preserved.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final parsedAmount = int.tryParse(_amountController.text.trim());
    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? finalVoucherUrl = _removeVoucher ? null : _currentVoucherUrl;
      String? finalVoucherPath = _removeVoucher ? null : widget.expense.voucherPath;

      if (_newVoucherFile != null && _newVoucherBytes != null) {
        final storageService = StorageService();
        final uploadResult = await storageService.uploadExpenseVoucher(
          file: _newVoucherFile!,
          eventId: widget.expense.eventId,
          expenseId: widget.expense.id,
          preloadedBytes: _newVoucherBytes,
        );
        finalVoucherUrl = uploadResult.url;
        finalVoucherPath = uploadResult.path;
      }

      final updatedExpense = ExpenseEntity(
        id: widget.expense.id,
        eventId: widget.expense.eventId,
        categoryId: _selectedCategoryId,
        description: _descriptionController.text.trim(),
        amount: parsedAmount,
        paidTo: _paidToController.text.trim(),
        paymentMode: _selectedPaymentMode,
        date: widget.expense.date,
        remark: _remarkController.text.trim().isNotEmpty
            ? _remarkController.text.trim()
            : null,
        billUrl: finalVoucherUrl,
        voucherUrl: finalVoucherUrl,
        voucherPath: finalVoucherPath,
        status: widget.expense.status,
        addedBy: widget.expense.addedBy,
        createdAt: widget.expense.createdAt,
        updatedAt: DateTime.now(),
        approvedBy: widget.expense.approvedBy,
        approvedAt: widget.expense.approvedAt,
        rejectionReason: widget.expense.rejectionReason,
      );

      await ref.read(expenseRepositoryProvider).updateExpense(
        updatedExpense,
      );

      // Invalidate relevant providers
      ref.invalidate(categoryWiseExpenseReportProvider);
      ref.invalidate(expensesProvider);
      ref.invalidate(pendingExpensesProvider);
      ref.invalidate(dashboardProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense entry updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update expense: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _delete() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Pending Expense'),
        content: Text('Are you sure you want to delete this pending expense of ₹${widget.expense.amount}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(expenseRepositoryProvider).deleteExpense(
        expense: widget.expense,
        user: currentUser,
      );

      ref.invalidate(categoryWiseExpenseReportProvider);
      ref.invalidate(expensesProvider);
      ref.invalidate(pendingExpensesProvider);
      ref.invalidate(dashboardProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pending expense deleted successfully.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete expense: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(effectiveRoleProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final isOwner = currentUser != null && widget.expense.addedBy == currentUser.uid;
    final canDelete = PermissionService().canDeleteExpense(
      role: userRole,
      status: widget.expense.status,
      isOwner: isOwner,
    );
    final isApproved = widget.expense.isApproved;

    final categories = ref.watch(expenseCategoriesProvider);
    final activeCategories = categories.where((c) => c.isActive).toList();

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isApproved ? Icons.receipt_long : Icons.edit_note,
            color: isApproved ? Colors.green : Colors.redAccent,
          ),
          const SizedBox(width: 8),
          Text(isApproved ? 'View Expense Entry' : 'Edit Expense Entry'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isApproved)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This expense is Approved & verified. Records cannot be modified or deleted.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: _paidToController,
                readOnly: isApproved,
                decoration: const InputDecoration(
                  labelText: 'Paid To (Vendor / Contractor) *',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Recipient / vendor is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                readOnly: isApproved,
                decoration: const InputDecoration(
                  labelText: 'Description / Purpose *',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                readOnly: isApproved,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹) *',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Amount is required';
                  final n = int.tryParse(val.trim());
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: activeCategories.any((c) => c.id == _selectedCategoryId)
                    ? _selectedCategoryId
                    : activeCategories.firstOrNull?.id,
                decoration: const InputDecoration(
                  labelText: 'Expense Category *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: activeCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: isApproved ? null : (val) {
                  if (val != null) setState(() => _selectedCategoryId = val);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMode>(
                initialValue: _selectedPaymentMode,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  prefixIcon: Icon(Icons.payments),
                ),
                items: PaymentMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode.label),
                  );
                }).toList(),
                onChanged: isApproved ? null : (val) {
                  if (val != null) setState(() => _selectedPaymentMode = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _remarkController,
                readOnly: isApproved,
                decoration: const InputDecoration(
                  labelText: 'Voucher / Remarks',
                  prefixIcon: Icon(Icons.comment),
                ),
              ),
              const SizedBox(height: 16),

              // VOUCHER / BILL ATTACHMENT SECTION
              Card(
                color: Colors.orange.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.orange.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt, size: 18, color: Colors.deepOrange),
                          SizedBox(width: 8),
                          Text(
                            'Bill / Voucher Photo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_newVoucherBytes != null) ...[
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.memory(_newVoucherBytes!, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _newVoucherFile?.name ?? 'Selected Bill Photo',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isApproved)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => setState(() {
                                  _newVoucherFile = null;
                                  _newVoucherBytes = null;
                                }),
                              ),
                          ],
                        ),
                      ] else if (!_removeVoucher && _currentVoucherUrl != null && _currentVoucherUrl!.isNotEmpty) ...[
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showImageZoom(_currentVoucherUrl!),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Image.network(
                                    _currentVoucherUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Existing Bill Photo Attached',
                                style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.zoom_in, color: Colors.blue, size: 20),
                              onPressed: () => _showImageZoom(_currentVoucherUrl!),
                              tooltip: 'View Bill',
                            ),
                            if (!isApproved)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => setState(() => _removeVoucher = true),
                                tooltip: 'Remove Bill',
                              ),
                          ],
                        ),
                      ] else ...[
                        const Text(
                          'No voucher photo attached.',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                      if (!isApproved) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickVoucherImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt, size: 16),
                                label: Text(_currentVoucherUrl != null || _newVoucherBytes != null ? 'Change (Camera)' : 'Camera'),
                                style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickVoucherImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo, size: 16),
                                label: Text(_currentVoucherUrl != null || _newVoucherBytes != null ? 'Change (Gallery)' : 'Gallery'),
                                style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (!isApproved && canDelete)
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: _isSaving ? null : _delete,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
          ),
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(isApproved ? 'Close' : 'Cancel'),
        ),
        if (!isApproved)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: _isSaving ? null : _submit,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save, size: 18),
            label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
          ),
      ],
    );
  }
}
