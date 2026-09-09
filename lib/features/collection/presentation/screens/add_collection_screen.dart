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
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/widgets/app_button.dart';
import 'package:durgapuja_manager/core/widgets/app_text_field.dart';
import 'package:durgapuja_manager/core/widgets/searchable_picker_field.dart';
import 'package:durgapuja_manager/core/widgets/status_chip.dart';
import 'package:durgapuja_manager/features/chanda/domain/entities/chanda_target_with_progress.dart';
import 'package:durgapuja_manager/features/chanda/presentation/providers/chanda_provider.dart';
import 'package:durgapuja_manager/features/chanda/presentation/screens/add_edit_chanda_target_screen.dart';
import 'package:durgapuja_manager/features/collection/data/models/collection_model.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/collection/presentation/providers/collection_provider.dart';
import 'package:durgapuja_manager/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:durgapuja_manager/features/puja_event/domain/entities/puja_event.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/receipts/domain/services/receipt_pdf_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import 'package:printing/printing.dart';

class _CollectionMemberChoice {
  final String id;
  final String name;
  final String? phone;
  final String subtitle;
  final String? targetId;
  final String? userId;
  final int? remainingAmount;
  final bool isTarget;

  const _CollectionMemberChoice({
    required this.id,
    required this.name,
    this.phone,
    required this.subtitle,
    this.targetId,
    this.userId,
    this.remainingAmount,
    required this.isTarget,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CollectionMemberChoice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AddCollectionScreen extends ConsumerStatefulWidget {
  final String? initialUserId;
  final String? initialChandaTargetId;
  final String? initialDonorName;
  final String? initialMobileNumber;
  final int? initialAmount;

  const AddCollectionScreen({
    super.key,
    this.initialUserId,
    this.initialChandaTargetId,
    this.initialDonorName,
    this.initialMobileNumber,
    this.initialAmount,
  });

  @override
  ConsumerState<AddCollectionScreen> createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends ConsumerState<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isMemberMode = true;

  String? _selectedUserId;
  String? _selectedUserName;
  String? _selectedUserMobile;
  String? _linkedChandaTargetId;

  late final TextEditingController _donorNameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _amountController;
  final _purposeController = TextEditingController(text: 'Puja Chanda');
  final _transactionIdController = TextEditingController();
  final _remarkController = TextEditingController();

  PaymentMode _selectedPaymentMode = PaymentMode.upi;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.initialUserId;
    _linkedChandaTargetId = widget.initialChandaTargetId;
    _selectedUserName = widget.initialDonorName;
    _selectedUserMobile = widget.initialMobileNumber;

    _donorNameController = TextEditingController(text: widget.initialDonorName ?? '');
    _mobileController = TextEditingController(text: widget.initialMobileNumber ?? '');
    _amountController = TextEditingController(
      text: widget.initialAmount != null && widget.initialAmount! > 0
          ? widget.initialAmount.toString()
          : '',
    );

    if (widget.initialDonorName != null && widget.initialUserId == null && widget.initialChandaTargetId == null) {
      _isMemberMode = false;
    }
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _mobileController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    _transactionIdController.dispose();
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
          _selectedImageFile = picked;
          _selectedImageBytes = bytes;
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

  String _getReferenceLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.upi:
        return 'Transaction ID (UPI Ref ID) *';
      case PaymentMode.cheque:
        return 'Cheque Number / Bank Details *';
      case PaymentMode.bankTransfer:
        return 'UTR / Reference Number *';
      case PaymentMode.cash:
        return '';
      case PaymentMode.other:
        return 'Reference Number';
    }
  }

  String _getReferenceHint(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.upi:
        return 'e.g. 312345678901';
      case PaymentMode.cheque:
        return 'e.g. CHQ-654321 (SBI)';
      case PaymentMode.bankTransfer:
        return 'e.g. UTR-987654321';
      case PaymentMode.cash:
        return '';
      case PaymentMode.other:
        return 'Reference number (Optional)';
    }
  }

  String? _validateReference(String? val, PaymentMode mode) {
    if (mode == PaymentMode.cash || mode == PaymentMode.other) {
      return null;
    }
    if (val == null || val.trim().isEmpty) {
      switch (mode) {
        case PaymentMode.upi:
          return 'Please enter UPI Transaction ID';
        case PaymentMode.cheque:
          return 'Please enter Cheque Number / Bank Details';
        case PaymentMode.bankTransfer:
          return 'Please enter UTR / Reference Number';
        default:
          return 'Please enter reference number';
      }
    }
    return null;
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

  Future<void> _submitCollection() async {
    if (!_formKey.currentState!.validate()) return;

    final activeEvent = ref.read(activePujaEventProvider);
    final currentUser = ref.read(currentUserProvider).value;

    if (activeEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active Puja event selected.')),
      );
      return;
    }

    if (_isMemberMode && _selectedUserId == null && _selectedUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final authUid = FirebaseAuth.instance.currentUser?.uid ?? currentUser?.uid ?? 'system';
      final docId = FirebaseFirestore.instance.collection('collections').doc().id;

      final donorName = _donorNameController.text.trim().isNotEmpty
          ? _donorNameController.text.trim()
          : (_selectedUserName ?? 'Member');
      final donorMobile = _mobileController.text.trim().isNotEmpty
          ? _mobileController.text.trim()
          : (_selectedUserMobile?.trim().isEmpty ?? true ? null : _selectedUserMobile?.trim());

      var newCollection = CollectionEntity(
        id: docId,
        eventId: activeEvent.id,
        userId: _isMemberMode ? _selectedUserId : null,
        chandaTargetId: _isMemberMode ? _linkedChandaTargetId : null,
        donorName: donorName,
        mobileNumber: donorMobile,
        amount: int.parse(_amountController.text.trim()),
        paymentMode: _selectedPaymentMode,
        transactionId: _selectedPaymentMode == PaymentMode.cash || _transactionIdController.text.trim().isEmpty
            ? null
            : _transactionIdController.text.trim(),
        purpose: _purposeController.text.trim(),
        collectedBy: currentUser?.name ?? 'Committee Member',
        date: _selectedDate,
        remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
        status: 'PENDING',
        createdBy: authUid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save initial collection record
      await ref.read(collectionRepositoryProvider).createCollection(newCollection);

      // Handle optional image upload to Firebase Storage
      if (_selectedImageFile != null) {
        try {
          final storageService = StorageService();
          final uploadResult = await storageService.uploadCollectionReceipt(
            file: _selectedImageFile!,
            eventId: activeEvent.id,
            collectionId: docId,
            preloadedBytes: _selectedImageBytes,
          );

          newCollection = newCollection.copyWith(
            paymentScreenshotUrl: uploadResult.url,
            paymentScreenshotPath: uploadResult.path,
          );

          await ref.read(collectionRepositoryProvider).updateCollection(
            CollectionModel.fromEntity(newCollection),
          );
        } catch (uploadError) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Collection saved, but receipt upload failed: ${uploadError.toString()}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      ref.invalidate(collectionsProvider);
      ref.invalidate(pendingCollectionsProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(chandaTargetsProvider);

      messenger.showSnackBar(
        const SnackBar(content: Text('Collection entry submitted for approval!')),
      );

      if (mounted) {
        _showReceiptOptionDialog(newCollection, activeEvent.name);
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showReceiptOptionDialog(CollectionEntity collection, String eventName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Collection Submitted (Pending Approval)'),
        content: const Text(
          'Would you like to preview/print a Provisional Donation Acknowledgement?\n\nNote: Official receipts (DP-2026-XXXXXX) are generated only after Treasurer/Admin approval.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final pdfBytes = await ReceiptPdfService.generateDonationReceipt(
                collection: collection,
                receiptNumber: 'PROVISIONAL-PENDING',
                committeeName: 'Durga Puja Committee',
                eventName: eventName,
                reviewerRoleName: 'Pending Review',
              );
              await Printing.layoutPdf(
                onLayout: (_) => pdfBytes,
                name: 'Provisional_Acknowledgement_${collection.donorName}.pdf',
              );
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Acknowledgement'),
          ),
        ],
      ),
    );
  }

  String _getAttachmentLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.upi:
        return 'Upload Payment Screenshot (Optional)';
      case PaymentMode.cheque:
        return 'Upload Cheque / Payment Proof (Optional)';
      default:
        return 'Upload Payment Receipt / Proof (Optional)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeEvent = ref.watch(activePujaEventProvider);
    final assignedEvents = ref.watch(userAssignedEventsProvider).value ?? [];
    final membersAsync = ref.watch(activeEventMembersProvider);
    final members = membersAsync.value ?? [];
    final chandaList = ref.watch(chandaWithProgressListProvider);
    final dateFormat = DateFormat('dd MMM yyyy');

    // Find Chanda target for selected user or linked target
    ChandaTargetWithProgress? selectedMemberChanda;
    if (_isMemberMode) {
      if (_linkedChandaTargetId != null) {
        try {
          selectedMemberChanda = chandaList.firstWhere(
            (item) => item.target.id == _linkedChandaTargetId,
          );
        } catch (_) {
          selectedMemberChanda = null;
        }
      } else if (_selectedUserId != null) {
        try {
          selectedMemberChanda = chandaList.firstWhere(
            (item) => item.target.userId == _selectedUserId,
          );
        } catch (_) {
          selectedMemberChanda = null;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Collection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Selector Context
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
                            'Adding Collection For Event *',
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

              // Collection Mode Switch (Member Chanda vs Direct / Public Donation)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isMemberMode = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isMemberMode ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isMemberMode
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Member Chanda / Pledge',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isMemberMode ? AppColors.primary : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isMemberMode = false;
                            _selectedUserId = null;
                            _linkedChandaTargetId = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isMemberMode ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isMemberMode
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Direct / Public Donation',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: !_isMemberMode ? AppColors.primary : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Mode 1: Member Chanda Selection
              if (_isMemberMode) ...[
                const Text(
                  'Select Committee Member / Chanda Target *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final List<_CollectionMemberChoice> memberChoices = [
                      ...chandaList.map((item) {
                        final dueText = item.remainingAmount > 0
                            ? 'Baki: ₹${item.remainingAmount}'
                            : (item.hasExcess ? 'Excess: ₹${item.excessAmount}' : 'PAID');
                        return _CollectionMemberChoice(
                          id: 'target_${item.target.id}',
                          name: item.target.personName,
                          phone: item.target.mobileNumber,
                          subtitle: 'Target: ₹${item.target.targetAmount} • $dueText',
                          targetId: item.target.id,
                          userId: item.target.userId,
                          remainingAmount: item.remainingAmount,
                          isTarget: true,
                        );
                      }),
                      ...members
                          .where((u) => !chandaList.any((t) => t.target.userId == u.uid))
                          .map((u) {
                        return _CollectionMemberChoice(
                          id: 'user_${u.uid}',
                          name: u.name,
                          phone: u.mobile,
                          subtitle: '${u.role.displayName} • No Target Set',
                          targetId: null,
                          userId: u.uid,
                          remainingAmount: null,
                          isTarget: false,
                        );
                      }),
                    ];

                    _CollectionMemberChoice? selectedChoice;
                    if (_linkedChandaTargetId != null) {
                      selectedChoice = memberChoices.where((c) => c.targetId == _linkedChandaTargetId).firstOrNull;
                    } else if (_selectedUserId != null) {
                      selectedChoice = memberChoices.where((c) => c.userId == _selectedUserId).firstOrNull;
                    }

                    return SearchablePickerField<_CollectionMemberChoice>(
                      title: 'Select Committee Member / Target',
                      searchHint: 'Search by member name, phone, target amount...',
                      placeholder: 'Tap to search & select (${memberChoices.length} members available)...',
                      prefixIcon: Icons.person_search,
                      items: memberChoices,
                      selectedItem: selectedChoice,
                      itemTitle: (c) => c.name,
                      itemSubtitle: (c) => '${c.subtitle}${c.phone != null && c.phone!.isNotEmpty ? " • 📞 ${c.phone}" : ""}',
                      searchFilter: (c, query) {
                        final name = c.name.toLowerCase();
                        final phone = (c.phone ?? '').toLowerCase();
                        final sub = c.subtitle.toLowerCase();
                        return name.contains(query) || phone.contains(query) || sub.contains(query);
                      },
                      onChanged: (choice) {
                        setState(() {
                          if (choice != null) {
                            if (choice.isTarget && choice.targetId != null) {
                              _linkedChandaTargetId = choice.targetId;
                              _selectedUserId = choice.userId;
                              _selectedUserName = choice.name;
                              _selectedUserMobile = choice.phone;
                              _donorNameController.text = choice.name;
                              _mobileController.text = choice.phone ?? '';
                              if (choice.remainingAmount != null && choice.remainingAmount! > 0) {
                                _amountController.text = choice.remainingAmount.toString();
                              }
                            } else if (choice.userId != null) {
                              _selectedUserId = choice.userId;
                              _selectedUserName = choice.name;
                              _selectedUserMobile = choice.phone;
                              _donorNameController.text = choice.name;
                              _mobileController.text = choice.phone ?? '';
                              _linkedChandaTargetId = null;
                            }
                          } else {
                            _linkedChandaTargetId = null;
                            _selectedUserId = null;
                            _selectedUserName = null;
                            _selectedUserMobile = null;
                            _donorNameController.clear();
                            _mobileController.clear();
                          }
                        });
                      },
                      validator: (val) => _isMemberMode && val == null ? 'Please select member / target' : null,
                    );
                  },
                ),

                const SizedBox(height: 14),

                // Prominent Chanda Information Display
                if (_selectedUserId != null || _linkedChandaTargetId != null) ...[
                  if (selectedMemberChanda != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.volunteer_activism, color: Colors.amber.shade900, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedUserName ?? 'Member Chanda Target',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber.shade900),
                                  ),
                                ],
                              ),
                              StatusChip(status: selectedMemberChanda.computedStatus),
                            ],
                          ),
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricTile('Chanda Target', selectedMemberChanda.targetAmount, AppColors.textPrimaryLight),
                              _buildMetricTile('Already Paid', selectedMemberChanda.paidAmount, AppColors.success),
                              if (selectedMemberChanda.hasExcess)
                                _buildMetricTile('Excess Paid', selectedMemberChanda.excessAmount, Colors.teal)
                              else
                                _buildMetricTile('Pending Due', selectedMemberChanda.remainingAmount, selectedMemberChanda.remainingAmount > 0 ? AppColors.expense : AppColors.success),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'No Chanda Target assigned for this member in this event.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditChandaTargetScreen(preselectedUserId: _selectedUserId),
                                ),
                              );
                            },
                            child: const Text('Assign Target', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ] else ...[
                // Mode 2: Direct / Public Donation Fields
                AppTextField(
                  controller: _donorNameController,
                  labelText: 'Donor / Public Name *',
                  hintText: 'e.g. Rahul Banerjee',
                  validator: (val) => !_isMemberMode && (val == null || val.trim().isEmpty) ? 'Please enter donor name' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _mobileController,
                  labelText: 'Mobile Number (Optional)',
                  hintText: 'e.g. 9876543210',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
              ],

              // Collection Amount Field
              AppTextField(
                controller: _amountController,
                labelText: 'Collection Amount (₹) *',
                hintText: 'e.g. 5000',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter amount';
                  if (int.tryParse(val.trim()) == null || int.parse(val.trim()) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
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
                  if (val != null && val != _selectedPaymentMode) {
                    setState(() {
                      _selectedPaymentMode = val;
                      _transactionIdController.clear();
                    });
                  }
                },
              ),

              const SizedBox(height: 12),

              if (_selectedPaymentMode != PaymentMode.cash) ...[
                AppTextField(
                  controller: _transactionIdController,
                  labelText: _getReferenceLabel(_selectedPaymentMode),
                  hintText: _getReferenceHint(_selectedPaymentMode),
                  validator: (val) => _validateReference(val, _selectedPaymentMode),
                ),
                const SizedBox(height: 12),
              ],

              AppTextField(
                controller: _purposeController,
                labelText: 'Purpose / Contribution Type',
                hintText: 'e.g. Puja Chanda, Bhog Sponsor, Pandal Sponsor',
              ),

              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Collection Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(dateFormat.format(_selectedDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today, color: AppColors.primary),
                  onPressed: _selectDate,
                ),
              ),

              const SizedBox(height: 12),

              AppTextField(
                controller: _remarkController,
                labelText: 'Remarks / Notes (Optional)',
                hintText: 'Any special notes regarding this collection',
              ),

              const SizedBox(height: 16),

              // Image Attachment
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getAttachmentLabel(_selectedPaymentMode),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedImageBytes != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _selectedImageBytes!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedImageFile = null;
                            _selectedImageBytes = null;
                          });
                        },
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        label: const Text('Remove Image', style: TextStyle(color: AppColors.error)),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              AppButton(
                text: 'Submit Collection Entry',
                isLoading: _isLoading,
                onPressed: _submitCollection,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, int amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
        const SizedBox(height: 2),
        Text(
          MoneyFormatter.format(amount),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
