import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/widgets/app_button.dart';
import 'package:durgapuja_manager/core/widgets/app_text_field.dart';
import 'package:durgapuja_manager/features/audit/domain/entities/audit_log.dart';
import 'package:durgapuja_manager/features/audit/presentation/providers/audit_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../../domain/entities/collection_custody.dart';
import '../../domain/entities/user_custody_balance.dart';
import '../providers/custody_provider.dart';

class AddBankDepositScreen extends ConsumerStatefulWidget {
  final UserCustodyBalance? prefilledSender;

  const AddBankDepositScreen({super.key, this.prefilledSender});

  @override
  ConsumerState<AddBankDepositScreen> createState() => _AddBankDepositScreenState();
}

class _AddBankDepositScreenState extends ConsumerState<AddBankDepositScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedSenderUid;
  String? _selectedSenderName;

  final _amountController = TextEditingController();
  final _bankNameController = TextEditingController(text: 'State Bank of India');
  final _accountRefController = TextEditingController(text: 'Puja Committee Official Account');
  final _referenceNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _depositDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledSender != null) {
      _selectedSenderUid = widget.prefilledSender!.userId;
      _selectedSenderName = widget.prefilledSender!.userName;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountRefController.dispose();
    _referenceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _getSenderAvailableCustody(List<UserCustodyBalance> balances, String senderUid) {
    try {
      final b = balances.firstWhere((element) => element.userId == senderUid);
      return b.availableForHandover;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _submitBankDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    final activeEvent = ref.read(activePujaEventProvider);
    final currentUser = ref.read(currentUserProvider).value;
    final balances = ref.read(userCustodyBalancesProvider);

    if (activeEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active Puja event selected.')),
      );
      return;
    }

    final senderUid = _selectedSenderUid ?? currentUser?.uid ?? '';
    final senderName = _selectedSenderName ?? currentUser?.name ?? 'Treasurer';

    if (senderUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a depositor holding custody.')),
      );
      return;
    }

    final enteredAmount = int.tryParse(_amountController.text.trim()) ?? 0;
    final availableCustody = _getSenderAvailableCustody(balances, senderUid);

    if (enteredAmount > availableCustody) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient cash available for deposit. (Available: ${MoneyFormatter.format(availableCustody)})',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final authUid = FirebaseAuth.instance.currentUser?.uid ?? currentUser?.uid ?? 'system';
      final docId = FirebaseFirestore.instance.collection('collection_custody').doc().id;

      final bankName = _bankNameController.text.trim();
      final accountRef = _accountRefController.text.trim();
      final refNumber = _referenceNumberController.text.trim();
      final userNotes = _notesController.text.trim();

      final combinedNotes = [
        if (accountRef.isNotEmpty) 'Account: $accountRef',
        if (refNumber.isNotEmpty) 'Ref/Challan: $refNumber',
        if (userNotes.isNotEmpty) userNotes,
      ].join(' | ');

      final newRecord = CollectionCustody(
        id: docId,
        eventId: activeEvent.id,
        eventType: activeEvent.eventType,
        eventYear: activeEvent.year,
        organizationName: activeEvent.organizationName,
        amount: enteredAmount,
        fromUserId: senderUid,
        fromUserName: senderName,
        toUserId: 'BANK',
        toUserName: bankName.isNotEmpty ? bankName : 'Bank Account',
        handoverType: CollectionCustody.typeBankDeposit,
        status: CollectionCustody.statusDeposited,
        handedOverAt: _depositDate,
        receivedAt: _depositDate,
        notes: combinedNotes.isEmpty ? null : combinedNotes,
        createdBy: authUid,
        createdAt: DateTime.now(),
      );

      await ref.read(custodyRepositoryProvider).createCustodyRecord(newRecord);

      // Audit Log
      try {
        final auditRepo = ref.read(auditRepositoryProvider);
        await auditRepo.logAction(AuditLog(
          id: FirebaseFirestore.instance.collection('audit_logs').doc().id,
          eventId: activeEvent.id,
          userId: authUid,
          userName: currentUser?.name ?? senderName,
          action: 'BANK_DEPOSIT_CREATE',
          entityType: 'COLLECTION_CUSTODY',
          entityId: docId,
          timestamp: DateTime.now(),
          metadata: {
            'amount': enteredAmount,
            'fromUserId': senderUid,
            'fromUserName': senderName,
            'bankName': bankName,
            'accountRef': accountRef,
            'refNumber': refNumber,
            'handoverType': CollectionCustody.typeBankDeposit,
          },
        ));
      } catch (_) {}

      ref.invalidate(custodyRecordsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Bank deposit of ${MoneyFormatter.format(enteredAmount)} successfully recorded!',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to record bank deposit: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeEvent = ref.watch(activePujaEventProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final balances = ref.watch(userCustodyBalancesProvider);
    final dateFormat = DateFormat('dd MMMM yyyy');

    final senderUid = _selectedSenderUid ?? currentUser?.uid ?? '';
    final availableCustody = _getSenderAvailableCustody(balances, senderUid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Bank Deposit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Context Banner
              if (activeEvent != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Event: ${activeEvent.name} (${activeEvent.year})',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Depositor Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Depositing Member / Treasurer',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedSenderName ?? currentUser?.name ?? 'You',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: availableCustody > 0 ? AppColors.successLight : AppColors.expenseLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            availableCustody > 0 ? Icons.check_circle : Icons.warning_amber,
                            size: 16,
                            color: availableCustody > 0 ? AppColors.success : AppColors.expense,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Available Cash in Custody: ${MoneyFormatter.format(availableCustody)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: availableCustody > 0 ? AppColors.success : AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Amount
              AppTextField(
                labelText: 'Deposit Amount (₹) *',
                hintText: 'Enter amount (up to ${MoneyFormatter.format(availableCustody)})',
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  final parsed = int.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  if (parsed > availableCustody) {
                    return 'Insufficient cash available for deposit (Max: ${MoneyFormatter.format(availableCustody)})';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Bank Name
              AppTextField(
                labelText: 'Destination Bank Name *',
                hintText: 'e.g. State Bank of India, HDFC Bank',
                controller: _bankNameController,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter bank name' : null,
              ),

              const SizedBox(height: 16),

              // Account Reference
              AppTextField(
                labelText: 'Account Name / Account Reference (Optional)',
                hintText: 'e.g. Maa Durga Puja A/C No. 382910...',
                controller: _accountRefController,
              ),

              const SizedBox(height: 16),

              // Deposit Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _depositDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => _depositDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Deposit Date', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                          const SizedBox(height: 2),
                          Text(dateFormat.format(_depositDate), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Deposit Reference Number / Challan / UTR
              AppTextField(
                labelText: 'Deposit Reference / Challan / UTR No. (Optional)',
                hintText: 'e.g. CHN-2025-9921',
                controller: _referenceNumberController,
              ),

              const SizedBox(height: 16),

              // Notes
              AppTextField(
                labelText: 'Notes / Remarks (Optional)',
                hintText: 'e.g. Branch counter deposit by Titu',
                controller: _notesController,
              ),

              const SizedBox(height: 28),

              AppButton(
                text: 'Record Bank Deposit',
                isLoading: _isLoading,
                onPressed: availableCustody > 0 ? _submitBankDeposit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
