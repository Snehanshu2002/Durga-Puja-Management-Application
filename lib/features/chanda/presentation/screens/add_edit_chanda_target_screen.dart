import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/widgets/app_button.dart';
import 'package:durgapuja_manager/core/widgets/app_text_field.dart';
import 'package:durgapuja_manager/core/widgets/searchable_picker_field.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../../domain/entities/chanda_target.dart';
import '../providers/chanda_provider.dart';
import 'chanda_detail_screen.dart';

class AddEditChandaTargetScreen extends ConsumerStatefulWidget {
  final ChandaTarget? target;
  final String? preselectedUserId;

  const AddEditChandaTargetScreen({
    super.key,
    this.target,
    this.preselectedUserId,
  });

  @override
  ConsumerState<AddEditChandaTargetScreen> createState() => _AddEditChandaTargetScreenState();
}

class _AddEditChandaTargetScreenState extends ConsumerState<AddEditChandaTargetScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedUserId;

  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _targetAmountController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.target != null) {
      _selectedUserId = widget.target!.userId;
    } else if (widget.preselectedUserId != null) {
      _selectedUserId = widget.preselectedUserId;
    }

    _nameController = TextEditingController(
      text: widget.target?.personName ?? '',
    );
    _mobileController = TextEditingController(
      text: widget.target?.mobileNumber ?? '',
    );
    _targetAmountController = TextEditingController(
      text: widget.target != null ? widget.target!.targetAmount.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _saveChandaTarget() async {
    if (!_formKey.currentState!.validate()) return;

    final activeEvent = ref.read(activePujaEventProvider);
    final currentUser = ref.read(currentUserProvider).value;
    final existingTargets = ref.read(chandaTargetsProvider).value ?? [];

    if (activeEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active Puja event selected.')),
      );
      return;
    }

    final enteredName = _nameController.text.trim();
    final enteredMobile = _mobileController.text.trim();

    if (enteredName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter member name.')),
      );
      return;
    }

    // Check duplicate target for the same userId + eventId
    if (widget.target == null && _selectedUserId != null) {
      final duplicate = existingTargets.where(
        (t) => t.userId == _selectedUserId && t.eventId == activeEvent.id,
      );
      if (duplicate.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This member already has a Chanda Target for this event.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final authUid = FirebaseAuth.instance.currentUser?.uid ?? currentUser?.uid ?? 'system';
      final repo = ref.read(chandaRepositoryProvider);

      if (widget.target == null) {
        // Create new Target linked to userId (or custom name)
        final docId = FirebaseFirestore.instance.collection('chanda_targets').doc().id;
        final newTarget = ChandaTarget(
          id: docId,
          userId: _selectedUserId,
          personName: enteredName,
          mobileNumber: enteredMobile.isEmpty ? null : enteredMobile,
          targetAmount: int.parse(_targetAmountController.text.trim()),
          eventId: activeEvent.id,
          eventType: activeEvent.eventType,
          eventYear: activeEvent.year,
          organizationName: activeEvent.organizationName,
          status: 'PENDING',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: authUid,
        );

        await repo.createChandaTarget(newTarget);
        messenger.showSnackBar(
          const SnackBar(content: Text('Chanda target assigned successfully!')),
        );
      } else {
        // Update existing Target
        final updatedTarget = widget.target!.copyWith(
          userId: _selectedUserId ?? widget.target!.userId,
          personName: enteredName,
          mobileNumber: enteredMobile.isEmpty ? null : enteredMobile,
          targetAmount: int.parse(_targetAmountController.text.trim()),
          updatedAt: DateTime.now(),
        );

        await repo.updateChandaTarget(updatedTarget);
        messenger.showSnackBar(
          const SnackBar(content: Text('Chanda target updated successfully!')),
        );
      }

      ref.invalidate(chandaTargetsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeEvent = ref.watch(activePujaEventProvider);
    final isEditing = widget.target != null;
    final membersAsync = ref.watch(activeEventMembersProvider);
    final members = membersAsync.value ?? [];
    final existingTargets = ref.watch(chandaTargetsProvider).value ?? [];

    // Check if selected member already has target in current event
    ChandaTarget? duplicateTarget;
    if (!isEditing && _selectedUserId != null && activeEvent != null) {
      try {
        duplicateTarget = existingTargets.firstWhere(
          (t) => t.userId == _selectedUserId && t.eventId == activeEvent.id,
        );
      } catch (_) {
        duplicateTarget = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Chanda Target' : 'Assign Chanda Target'),
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
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Event: ${activeEvent.name} (${activeEvent.year})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Member Selector (Single source of truth from users collection)
              if (!isEditing) ...[
                const Text(
                  'Select Member from Committee *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 8),
                SearchablePickerField<AppUser>(
                  title: 'Select Committee Member',
                  searchHint: 'Search by name, role, phone number...',
                  placeholder: 'Tap to search & select member (${members.length} available)...',
                  prefixIcon: Icons.person_search,
                  items: members,
                  selectedItem: _selectedUserId != null
                      ? members.where((u) => u.uid == _selectedUserId).firstOrNull
                      : null,
                  itemTitle: (u) => u.name,
                  itemSubtitle: (u) => '${u.role.displayName}${u.mobile != null && u.mobile!.isNotEmpty ? " • ${u.mobile}" : ""}',
                  searchFilter: (u, query) {
                    final name = u.name.toLowerCase();
                    final role = u.role.displayName.toLowerCase();
                    final mobile = (u.mobile ?? '').toLowerCase();
                    return name.contains(query) || role.contains(query) || mobile.contains(query);
                  },
                  onChanged: (selected) {
                    setState(() {
                      if (selected != null) {
                        _selectedUserId = selected.uid;
                        _nameController.text = selected.name;
                        _mobileController.text = selected.mobile ?? '';
                      } else {
                        _selectedUserId = null;
                      }
                    });
                  },
                  validator: (val) => val == null && _nameController.text.trim().isEmpty
                      ? 'Please select or enter a member name'
                      : null,
                ),
                const SizedBox(height: 16),
              ],

              // Editable Member Name Field
              AppTextField(
                labelText: 'Member / Person Name *',
                hintText: 'e.g. Ramesh Chandra Pradhan',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter member name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Editable Mobile Number Field
              AppTextField(
                labelText: 'Mobile Number (Optional)',
                hintText: 'e.g. 9876543210',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
              ),
              const SizedBox(height: 16),

              // Duplicate Target Warning Banner
              if (duplicateTarget != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This member already has a Chanda Target for this event.',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade800,
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChandaDetailScreen(targetId: duplicateTarget!.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View Existing Target'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Target Amount Input
              AppTextField(
                labelText: 'Chanda Target / Pledge Amount (₹) *',
                hintText: 'e.g. 5000',
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.currency_rupee),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter target amount';
                  }
                  final parsed = int.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              AppButton(
                text: isEditing ? 'Update Target' : 'Save Chanda Target',
                isLoading: _isLoading,
                onPressed: duplicateTarget == null ? _saveChandaTarget : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
