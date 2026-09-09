import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class AddCashHandoverScreen extends ConsumerStatefulWidget {
  final UserCustodyBalance? prefilledSender;

  const AddCashHandoverScreen({super.key, this.prefilledSender});

  @override
  ConsumerState<AddCashHandoverScreen> createState() => _AddCashHandoverScreenState();
}

class _AddCashHandoverScreenState extends ConsumerState<AddCashHandoverScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedSenderUid;
  String? _selectedSenderName;

  String? _selectedReceiverUid;
  String? _selectedReceiverName;

  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

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

  Future<void> _submitCashHandover() async {
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
    final senderName = _selectedSenderName ?? currentUser?.name ?? 'Collector';

    if (senderUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sender holding custody.')),
      );
      return;
    }

    final enteredAmount = int.tryParse(_amountController.text.trim()) ?? 0;
    final availableCustody = _getSenderAvailableCustody(balances, senderUid);

    // Strict validation: cannot hand over more than available physical cash
    if (enteredAmount > availableCustody) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient amount available for handover. (Available: ${MoneyFormatter.format(availableCustody)})',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedReceiverUid == null || _selectedReceiverUid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a receiver member/treasurer.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final authUid = FirebaseAuth.instance.currentUser?.uid ?? currentUser?.uid ?? 'system';
      final docId = FirebaseFirestore.instance.collection('collection_custody').doc().id;

      final newRecord = CollectionCustody(
        id: docId,
        eventId: activeEvent.id,
        eventType: activeEvent.eventType,
        eventYear: activeEvent.year,
        organizationName: activeEvent.organizationName,
        amount: enteredAmount,
        fromUserId: senderUid,
        fromUserName: senderName,
        toUserId: _selectedReceiverUid!,
        toUserName: _selectedReceiverName ?? 'Treasurer',
        handoverType: CollectionCustody.typeCashHandover,
        status: CollectionCustody.statusPending,
        handedOverAt: DateTime.now(),
        receivedAt: null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
          action: 'CUSTODY_HANDOVER_CREATE',
          entityType: 'COLLECTION_CUSTODY',
          entityId: docId,
          timestamp: DateTime.now(),
          metadata: {
            'amount': enteredAmount,
            'fromUserId': senderUid,
            'fromUserName': senderName,
            'toUserId': _selectedReceiverUid,
            'toUserName': _selectedReceiverName,
            'handoverType': CollectionCustody.typeCashHandover,
          },
        ));
      } catch (_) {}

      ref.invalidate(custodyRecordsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Cash handover of ${MoneyFormatter.format(enteredAmount)} submitted for receiver confirmation!',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to record handover: ${e.toString()}'), backgroundColor: AppColors.error),
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
    final usersMap = ref.watch(userNamesMapProvider).value ?? {};

    final senderUid = _selectedSenderUid ?? currentUser?.uid ?? '';
    final availableCustody = _getSenderAvailableCustody(balances, senderUid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Cash Handover'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Context
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
                      const Icon(Icons.event, color: AppColors.primary, size: 20),
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

              // Sender / Current Custody Holder
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
                      'From (Person Handing Over Cash)',
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

              // Receiver Field
              const Text(
                'To (Receiver Member / Treasurer) *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimaryLight),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedReceiverUid,
                decoration: InputDecoration(
                  hintText: 'Select receiver member/treasurer',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: usersMap.entries
                    .where((e) => e.key != senderUid && !e.key.contains('@') && !e.key.startsWith('user_pre_'))
                    .map((entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedReceiverUid = val;
                    _selectedReceiverName = usersMap[val] ?? 'Treasurer';
                  });
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please select receiver';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Amount Field
              AppTextField(
                labelText: 'Handover Amount (₹) *',
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
                    return 'Insufficient amount available for handover (Max: ${MoneyFormatter.format(availableCustody)})';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              AppTextField(
                labelText: 'Notes / Remarks (Optional)',
                hintText: 'e.g. Handed over evening collection batch 1',
                controller: _notesController,
              ),

              const SizedBox(height: 28),

              AppButton(
                text: 'Submit Cash Handover',
                isLoading: _isLoading,
                onPressed: availableCustody > 0 ? _submitCashHandover : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
