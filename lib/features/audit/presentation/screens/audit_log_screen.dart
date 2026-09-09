import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import '../providers/audit_provider.dart';

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(auditLogsProvider);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log History'),
      ),
      body: auditLogsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(
              child: Text('No audit logs recorded for this event.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getActionColor(log.action).withValues(alpha: 0.15),
                    child: Icon(
                      _getActionIcon(log.action),
                      color: _getActionColor(log.action),
                      size: 20,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        log.action,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getActionColor(log.action),
                        ),
                      ),
                      Text(
                        log.entityType,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text('By: ${log.userName} (${log.userId})'),
                      Text(
                        dateFormat.format(log.timestamp),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      if (log.metadata != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Details: ${log.metadata}',
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(message: 'Loading audit logs...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(auditLogsProvider),
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    if (action.contains('APPROVE') || action.contains('CREATE')) return Colors.green;
    if (action.contains('REJECT') || action.contains('DELETE') || action.contains('DEACTIVATE')) return Colors.red;
    if (action.contains('ROLE')) return Colors.purple;
    return Colors.blue;
  }

  IconData _getActionIcon(String action) {
    if (action.contains('APPROVE')) return Icons.check_circle;
    if (action.contains('REJECT')) return Icons.cancel;
    if (action.contains('CREATE')) return Icons.add_circle;
    if (action.contains('ROLE')) return Icons.security;
    return Icons.history;
  }
}
