import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/features/approval/presentation/screens/approval_dashboard_screen.dart';
import '../providers/notification_provider.dart';

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final ds = ref.watch(notificationRemoteDataSourceProvider);
    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () async {
              final notifs = notificationsAsync.value;
              if (notifs != null && notifs.isNotEmpty) {
                await ds.markAllAsRead(notifs.first.userId);
                ref.invalidate(userNotificationsProvider);
              }
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications.'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Container(
                color: notif.isRead ? Colors.transparent : Colors.amber.shade50,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getTypeColor(notif.type).withValues(alpha: 0.15),
                    child: Icon(
                      _getTypeIcon(notif.type),
                      color: _getTypeColor(notif.type),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(notif.body),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(notif.createdAt),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () async {
                    if (!notif.isRead) {
                      await ds.markAsRead(notif.id);
                      ref.invalidate(userNotificationsProvider);
                    }
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ApprovalDashboardScreen(),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(message: 'Loading notifications...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(userNotificationsProvider),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    if (type.contains('APPROVED')) return Colors.green;
    if (type.contains('REJECTED')) return Colors.red;
    return Colors.amber.shade800;
  }

  IconData _getTypeIcon(String type) {
    if (type.contains('APPROVED')) return Icons.check_circle_outline;
    if (type.contains('REJECTED')) return Icons.cancel_outlined;
    return Icons.notifications_active_outlined;
  }
}
