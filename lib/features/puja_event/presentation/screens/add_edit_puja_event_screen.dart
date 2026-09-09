import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/utils/validators.dart';
import 'package:durgapuja_manager/core/widgets/app_button.dart';
import 'package:durgapuja_manager/core/widgets/app_text_field.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../../domain/entities/puja_event.dart';
import '../providers/puja_event_provider.dart';

class AddEditPujaEventScreen extends ConsumerStatefulWidget {
  final PujaEvent? event;

  const AddEditPujaEventScreen({super.key, this.event});

  @override
  ConsumerState<AddEditPujaEventScreen> createState() =>
      _AddEditPujaEventScreenState();
}

class _AddEditPujaEventScreenState
    extends ConsumerState<AddEditPujaEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _yearController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'ACTIVE';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _nameController = TextEditingController(text: event?.name ?? '');
    _yearController = TextEditingController(
      text: (event?.year ?? DateTime.now().year).toString(),
    );
    _locationController = TextEditingController(text: event?.location ?? '');
    _descriptionController =
        TextEditingController(text: event?.description ?? '');
    _startDate = event?.startDate ?? DateTime.now();
    _endDate = event?.endDate ?? DateTime.now().add(const Duration(days: 4));
    _status = event?.status ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now(),
        end: _endDate ?? DateTime.now().add(const Duration(days: 4)),
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _yearController.text = picked.start.year.toString();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates.')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(pujaEventRepositoryProvider);
      final currentUser = ref.read(currentUserProvider).value;

      final year = int.tryParse(_yearController.text) ?? _startDate!.year;

      if (widget.event == null) {
        final newEvent = PujaEvent(
          id: '',
          name: _nameController.text.trim(),
          year: year,
          startDate: _startDate!,
          endDate: _endDate!,
          location: _locationController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _status,
          createdBy: currentUser?.uid ?? 'system',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.createEvent(newEvent);
      } else {
        final updatedEvent = widget.event!.copyWith(
          name: _nameController.text.trim(),
          year: year,
          startDate: _startDate!,
          endDate: _endDate!,
          location: _locationController.text.trim(),
          description: _descriptionController.text.trim(),
          status: _status,
          updatedAt: DateTime.now(),
        );
        await repo.updateEvent(updatedEvent);
      }

      ref.invalidate(pujaEventsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.event == null
                  ? 'Puja Event created successfully!'
                  : 'Puja Event updated successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving event: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isEdit = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Puja Event' : 'Add Puja Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _nameController,
                labelText: 'Event Name *',
                hintText: 'e.g. Durga Puja 2026',
                validator: (val) => Validators.validateRequired(val, 'Event Name'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _yearController,
                labelText: 'Year *',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Year is required';
                  final parsed = int.tryParse(val);
                  if (parsed == null || parsed < 2000 || parsed > 2100) {
                    return 'Enter a valid 4-digit year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Event Date Range *'),
                  subtitle: Text(
                    _startDate != null && _endDate != null
                        ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
                        : 'Tap to select dates',
                  ),
                  trailing: const Icon(Icons.date_range),
                  onTap: _pickDateRange,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _locationController,
                labelText: 'Location',
                hintText: 'e.g. Committee Ground',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Additional details...',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Event Status',
                ),
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED')),
                  DropdownMenuItem(value: 'ARCHIVED', child: Text('ARCHIVED')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 32),
              AppButton(
                text: isEdit ? 'Update Event' : 'Create Event',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
