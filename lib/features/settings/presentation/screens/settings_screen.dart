import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/constants/app_constants.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/features/audit/presentation/screens/audit_log_screen.dart';
import 'package:durgapuja_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:durgapuja_manager/features/notifications/presentation/screens/notification_list_screen.dart';
import 'package:durgapuja_manager/features/profile/presentation/screens/profile_screen.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/screens/puja_event_list_screen.dart';
import 'package:durgapuja_manager/features/reports/presentation/screens/reports_hub_screen.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/user_management/presentation/screens/user_list_screen.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final permissionService = PermissionService();

    final canManageUsers = user != null &&
        permissionService.hasPermission(user.role, Permission.manageUsers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.expense.withValues(alpha: 0.85)),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: Icon(Icons.person, color: AppColors.primary),
            title: const Text('My Profile'),
            subtitle: Text(user?.name ?? 'View & update profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          Divider(color: AppColors.divider),
          ListTile(
            leading: Icon(Icons.event, color: AppColors.accent),
            title: const Text('Puja Events'),
            subtitle: const Text('Manage Durga Puja annual events'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PujaEventListScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: AppColors.primary),
            title: const Text('Reports & Analytics'),
            subtitle: const Text('Financial summary, Chanda & Expense reports'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsHubScreen()),
              );
            },
          ),
          if (canManageUsers) ...[
            ListTile(
              leading: Icon(Icons.people, color: AppColors.secondary),
              title: const Text('User & Role Management'),
              subtitle: const Text('Manage committee members & permissions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserListScreen()),
                );
              },
            ),
          ],
          ListTile(
            leading: Icon(Icons.notifications, color: AppColors.warning),
            title: const Text('Notifications'),
            subtitle: const Text('View approval notifications & device tokens'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationListScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history_edu, color: AppColors.textSecondaryLight),
            title: const Text('Audit Log History'),
            subtitle: const Text('Immutable audit trail of financial & admin operations'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuditLogScreen()),
              );
            },
          ),
          Divider(color: AppColors.divider),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.expense),
            title: Text(
              'Sign Out / Logout',
              style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Logout of current session'),
            onTap: () => _confirmSignOut(context, ref),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: AppColors.primarySurface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Web Application & PWA Info',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Production Web URL: https://durga-puja-manager.web.app',
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimaryLight)),
                    const SizedBox(height: 4),
                    Text('Deployment: Firebase Hosting',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 4),
                    Text('Platform: Flutter Web / Progressive Web App (PWA)',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
            ),
          ),
          AboutListTile(
            icon: Icon(Icons.info_outline, color: AppColors.textSecondaryLight),
            applicationName: AppConstants.appName,
            applicationVersion: AppConstants.appVersion,
            applicationLegalese: '© 2026 Durga Puja Committee. All rights reserved.',
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              minimumSize: const Size(0, 42),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider).signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
