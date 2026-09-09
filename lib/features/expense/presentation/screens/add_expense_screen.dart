import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/core/services/storage_service.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/widgets/app_button.dart';
import 'package:durgapuja_manager/core/widgets/app_text_field.dart';
import 'package:durgapuja_manager/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:durgapuja_manager/features/expense/data/models/expense_model.dart';
import 'package:durgapuja_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:durgapuja_manager/features/expense/presentation/providers/expense_provider.dart';
import 'package:durgapuja_manager/features/expense/presentation/screens/category_management_screen.dart';
import 'package:durgapuja_manager/features/puja_event/domain/entities/puja_event.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _paidToController = TextEditingController();
  final _remarkController = TextEditingController();

  String _selectedCategoryId = 'decoration';
  PaymentMode _selectedPaymentMode = PaymentMode.cash;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  XFile? _selectedVoucherFile;
  Uint8List? _selectedVoucherBytes;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _paidToController.dispose();
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
          _selectedVoucherFile = picked;
          _selectedVoucherBytes = bytes;
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final activeEvent = ref.read(activePujaEventProvider);
    final currentUser = ref.read(currentUserProvider).value;

    if (activeEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active Puja event selected.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final authUid = FirebaseAuth.instance.currentUser?.uid ?? currentUser?.uid ?? 'system';
      final docId = FirebaseFirestore.instance.collection('expenses').doc().id;

      var newExpense = ExpenseEntity(
        id: docId,
        eventId: activeEvent.id,
        categoryId: _selectedCategoryId,
        description: _descriptionController.text.trim(),
        amount: int.parse(_amountController.text.trim()),
        paidTo: _paidToController.text.trim(),
        paymentMode: _selectedPaymentMode,
        date: _selectedDate,
        remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
        status: 'PENDING',
        addedBy: authUid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save initial expense record
      await ref.read(expenseRepositoryProvider).createExpense(newExpense);

      // Handle optional voucher image upload to Firebase Storage
      if (_selectedVoucherFile != null) {
        try {
          final storageService = StorageService();
          final uploadResult = await storageService.uploadExpenseVoucher(
            file: _selectedVoucherFile!,
            eventId: activeEvent.id,
            expenseId: docId,
            preloadedBytes: _selectedVoucherBytes,
          );

          newExpense = newExpense.copyWith(
            billUrl: uploadResult.url,
            voucherUrl: uploadResult.url,
            voucherPath: uploadResult.path,
          );

          await ref.read(expenseRepositoryProvider).updateExpense(
            ExpenseModel.fromEntity(newExpense),
          );
        } catch (uploadError) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Expense saved, but voucher upload failed: ${uploadError.toString()}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      ref.invalidate(expensesProvider);
      ref.invalidate(pendingExpensesProvider);
      ref.invalidate(dashboardProvider);

      messenger.showSnackBar(
        const SnackBar(content: Text('Expense submitted successfully for approval!')),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeEvent = ref.watch(activePujaEventProvider);
    final assignedEvents = ref.watch(userAssignedEventsProvider).value ?? [];
    final categories = ref.watch(expenseCategoriesProvider);
    final activeCategories = categories.where((c) => c.isActive).toList();
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (activeEvent != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.event, color: AppColors.primary, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Adding Expense For Event *',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (assignedEvents.length > 1)
                        DropdownButtonFormField<PujaEvent>(
                          initialValue: activeEvent,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: assignedEvents.map((event) {
                            return DropdownMenuItem<PujaEvent>(
                              value: event,
                              child: Text(
                                '${event.name} (${event.year})',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (newEvent) {
                            if (newEvent != null) {
                              ref.read(activePujaEventProvider.notifier).selectEvent(newEvent);
                            }
                          },
                        )
                      else
                        Text(
                          '${activeEvent.organizationName}\n${activeEvent.name} (${activeEvent.year})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Record pandal, sound, food, electricity, or vendor expenses for committee review.',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Expense Category *',
                  border: OutlineInputBorder(),
                ),
                items: activeCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategoryId = val);
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _descriptionController,
                labelText: 'Description / Purpose *',
                hintText: 'e.g. Stage Bamboo & Decoration Work',
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _amountController,
                labelText: 'Expense Amount (₹) *',
                hintText: 'e.g. 12000',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter amount';
                  if (int.tryParse(val.trim()) == null || int.parse(val.trim()) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _paidToController,
                labelText: 'Paid To (Vendor / Contractor) *',
                hintText: 'e.g. Bengal Decorators',
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter recipient vendor' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentMode>(
                initialValue: _selectedPaymentMode,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(),
                ),
                items: PaymentMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPaymentMode = val);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expense Date'),
                subtitle: Text(dateFormat.format(_selectedDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              // INTERACTIVE VOUCHER ATTACHMENT CARD
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade300, width: 1),
                ),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Upload Bill / Voucher (Optional)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'JPG, PNG, WEBP — Max 5 MB',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedVoucherFile == null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickVoucherImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt, size: 18),
                                label: const Text('Camera'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickVoucherImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library, size: 18),
                                label: const Text('Gallery'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: FutureBuilder<Uint8List>(
                                    future: _selectedVoucherFile!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedVoucherFile!.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Ready for upload',
                                      style: TextStyle(fontSize: 11, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedVoucherFile = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              AppTextField(
                controller: _remarkController,
                labelText: 'Voucher / Remarks',
                hintText: 'Optional notes',
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Submit Expense Entry',
                isLoading: _isLoading,
                onPressed: _submitExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
