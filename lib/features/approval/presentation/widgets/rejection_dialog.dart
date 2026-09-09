import 'package:flutter/material.dart';

class RejectionDialog extends StatefulWidget {
  final String title;

  const RejectionDialog({
    super.key,
    this.title = 'Reject Transaction',
  });

  @override
  State<RejectionDialog> createState() => _RejectionDialogState();
}

class _RejectionDialogState extends State<RejectionDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason for Rejection *',
            hintText: 'e.g. Incorrect donor amount or missing proof',
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please enter a rejection reason.';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
