import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/core/services/storage_service.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/collection/presentation/providers/collection_provider.dart';
import 'package:durgapuja_manager/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:durgapuja_manager/features/reports/presentation/providers/reports_provider.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';

class EditCollectionDialog extends ConsumerStatefulWidget {
  final CollectionEntity collection;

  const EditCollectionDialog({
    super.key,
    required this.collection,
  });

  static Future<void> show(BuildContext context, CollectionEntity collection) {
    return showDialog<void>(
      context: context,
      builder: (context) => EditCollectionDialog(collection: collection),
    );
  }

  @override
  ConsumerState<EditCollectionDialog> createState() => _EditCollectionDialogState();
}

class _EditCollectionDialogState extends ConsumerState<EditCollectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _donorNameController;
  late TextEditingController _mobileController;
  late TextEditingController _amountController;
  late TextEditingController _purposeController;
  late TextEditingController _remarkController;
  late PaymentMode _selectedPaymentMode;
  
  bool _isSaving = false;
  XFile? _newImageFile;
  Uint8List? _newImageBytes;
  String? _currentPhotoUrl;
  bool _removePhoto = false;

  @override
  void initState() {
    super.initState();
    _donorNameController = TextEditingController(text: widget.collection.donorName);
    _mobileController = TextEditingController(text: widget.collection.mobileNumber ?? '');
    _amountController = TextEditingController(text: widget.collection.amount.toString());
    _purposeController = TextEditingController(text: widget.collection.purpose);
    _remarkController = TextEditingController(text: widget.collection.remark ?? '');
    _selectedPaymentMode = widget.collection.paymentMode;
    _currentPhotoUrl = widget.collection.paymentScreenshotUrl;
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _mobileController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
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
          _newImageFile = picked;
          _newImageBytes = bytes;
          _removePhoto = false;
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

  Future<void> _submit() async {
    final userRole = ref.read(effectiveRoleProvider);
    if (!PermissionService().hasPermission(userRole, Permission.editCollection)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied: You do not have permission to edit collection entries.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.collection.isApproved) {
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
      String? finalPhotoUrl = _removePhoto ? null : _currentPhotoUrl;
      String? finalPhotoPath = _removePhoto ? null : widget.collection.paymentScreenshotPath;

      if (_newImageFile != null && _newImageBytes != null) {
        final storageService = StorageService();
        final uploadResult = await storageService.uploadCollectionReceipt(
          file: _newImageFile!,
          eventId: widget.collection.eventId,
          collectionId: widget.collection.id,
          preloadedBytes: _newImageBytes,
        );
        finalPhotoUrl = uploadResult.url;
        finalPhotoPath = uploadResult.path;
      }

      final updatedCollection = CollectionEntity(
        id: widget.collection.id,
        eventId: widget.collection.eventId,
        donorName: _donorNameController.text.trim(),
        mobileNumber: _mobileController.text.trim().isNotEmpty
            ? _mobileController.text.trim()
            : null,
        amount: parsedAmount,
        paymentMode: _selectedPaymentMode,
        transactionId: widget.collection.transactionId,
        purpose: _purposeController.text.trim(),
        collectedBy: widget.collection.collectedBy,
        date: widget.collection.date,
        remark: _remarkController.text.trim().isNotEmpty
            ? _remarkController.text.trim()
            : null,
        paymentScreenshotUrl: finalPhotoUrl,
        paymentScreenshotPath: finalPhotoPath,
        status: widget.collection.status,
        createdBy: widget.collection.createdBy,
        createdAt: widget.collection.createdAt,
        updatedAt: DateTime.now(),
        approvedBy: widget.collection.approvedBy,
        approvedAt: widget.collection.approvedAt,
        rejectionReason: widget.collection.rejectionReason,
      );

      await ref.read(collectionRepositoryProvider).updateCollection(
        updatedCollection,
      );

      // Invalidate relevant providers to force fresh data load
      ref.invalidate(personWiseReportProvider);
      ref.invalidate(collectorWiseReportProvider);
      ref.invalidate(collectionsProvider);
      ref.invalidate(dashboardProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Collection entry updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update collection: ${e.toString()}'),
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
        title: const Text('Delete Pending Collection'),
        content: Text('Are you sure you want to delete this pending collection of ₹${widget.collection.amount}?'),
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
      await ref.read(collectionRepositoryProvider).deleteCollection(
        collection: widget.collection,
        user: currentUser,
      );

      ref.invalidate(personWiseReportProvider);
      ref.invalidate(collectorWiseReportProvider);
      ref.invalidate(collectionsProvider);
      ref.invalidate(dashboardProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pending collection deleted successfully.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete collection: ${e.toString()}'),
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
    final isOwner = currentUser != null && widget.collection.createdBy == currentUser.uid;
    final canDelete = PermissionService().canDeleteCollection(
      role: userRole,
      status: widget.collection.status,
      isOwner: isOwner,
      isCustodyLinked: widget.collection.isCustodyLinked,
    );

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit_note, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(widget.collection.isApproved ? 'View Collection Entry' : 'Edit Collection Entry'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _donorNameController,
                decoration: const InputDecoration(
                  labelText: 'Donor Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Donor name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
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
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose / Title *',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Purpose is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _remarkController,
                decoration: const InputDecoration(
                  labelText: 'Remark / Notes',
                  prefixIcon: Icon(Icons.comment),
                ),
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
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPaymentMode = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // PHOTO ATTACHMENT SECTION (VIEW / CHANGE / UPLOAD)
              Card(
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.photo_library, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Receipt Screenshot / Photo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_newImageBytes != null) ...[
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.memory(_newImageBytes!, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _newImageFile?.name ?? 'Selected Image',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => setState(() {
                                _newImageFile = null;
                                _newImageBytes = null;
                              }),
                            ),
                          ],
                        ),
                      ] else if (!_removePhoto && _currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) ...[
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showImageZoom(_currentPhotoUrl!),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Image.network(
                                    _currentPhotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Existing Photo Attached',
                                style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.zoom_in, color: Colors.blue, size: 20),
                              onPressed: () => _showImageZoom(_currentPhotoUrl!),
                              tooltip: 'View Photo',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => setState(() => _removePhoto = true),
                              tooltip: 'Remove Photo',
                            ),
                          ],
                        ),
                      ] else ...[
                        const Text(
                          'No photo attached.',
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt, size: 16),
                              label: Text(_currentPhotoUrl != null || _newImageBytes != null ? 'Change (Camera)' : 'Camera'),
                              style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo, size: 16),
                              label: Text(_currentPhotoUrl != null || _newImageBytes != null ? 'Change (Gallery)' : 'Gallery'),
                              style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.collection.isApproved)
          const Expanded(
            child: Text(
              'Approved transactions cannot be deleted.',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          )
        else if (widget.collection.isCustodyLinked)
          const Expanded(
            child: Text(
              'Cannot delete: linked to cash custody.',
              style: TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic),
            ),
          )
        else if (canDelete)
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: _isSaving ? null : _delete,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
          ),
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (!widget.collection.isApproved)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
