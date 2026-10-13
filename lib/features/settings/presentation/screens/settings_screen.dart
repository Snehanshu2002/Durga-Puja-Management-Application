import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/constants/app_constants.dart';
import 'package:durgapuja_manager/core/providers/whatsapp_settings_provider.dart';
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
    final canManageSettings = user != null &&
        permissionService.hasPermission(user.role, Permission.manageSettings);
    final currentLanguage = ref.watch(whatsAppSettingsProvider);

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
            leading: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF128C7E), size: 20),
            ),
            title: const Text('WhatsApp Message Format'),
            subtitle: Text('Default: ${currentLanguage.displayName} (${currentLanguage == WhatsAppMessageLanguage.odia ? "ଓଡ଼ିଆ" : "English"})'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentLanguage.icon, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    currentLanguage == WhatsAppMessageLanguage.odia ? 'ଓଡ଼ିଆ' : 'English',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF075E54),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 13, color: Color(0xFF075E54)),
                ],
              ),
            ),
            onTap: () => _showWhatsAppSettingsDialog(
              context,
              ref,
              currentLanguage,
              canManageSettings,
              user?.name,
            ),
          ),
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

  void _showWhatsAppSettingsDialog(
    BuildContext context,
    WidgetRef ref,
    WhatsAppMessageLanguage currentLanguage,
    bool canEdit,
    String? userName,
  ) {
    WhatsAppMessageLanguage selectedLang = currentLanguage;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Color(0xFF128C7E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WhatsApp Message Format',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Admin Configuration',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select the default language used when sharing Chanda due reminders and donation receipts via WhatsApp:',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),

                      if (!canEdit) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.amber, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Only Admin, President, or Treasurer can change the default WhatsApp format.',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Option 1: Odia (Default)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: canEdit
                            ? () {
                                setDialogState(() {
                                  selectedLang = WhatsAppMessageLanguage.odia;
                                });
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedLang == WhatsAppMessageLanguage.odia
                                ? const Color(0xFF25D366).withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedLang == WhatsAppMessageLanguage.odia
                                  ? const Color(0xFF25D366)
                                  : AppColors.divider,
                              width: selectedLang == WhatsAppMessageLanguage.odia ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selectedLang == WhatsAppMessageLanguage.odia
                                            ? const Color(0xFF128C7E)
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: selectedLang == WhatsAppMessageLanguage.odia
                                        ? Center(
                                            child: Container(
                                              width: 11,
                                              height: 11,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF128C7E),
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('🌺', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ଓଡ଼ିଆ (Odia - Default)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          'Recommended for local devotees & committee members',
                                          style: TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '🙏 ଜୟ ମା ଦୁର୍ଗା 🙏\nନମସ୍କାର ରାମ ଭାଇ,\nଦୁର୍ଗା ପୂଜା ଚାନ୍ଦା ବିବରଣୀ:\nଧାର୍ଯ୍ୟ: ₹2,000 | ପୈଠ: ₹1,000 | ବାକି: ₹1,000\nଦୟାକରି ସହଯୋଗ କରନ୍ତୁ। ଧନ୍ୟବାଦ 🙏',
                                  style: TextStyle(fontSize: 11.5, height: 1.35, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Option 2: English
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: canEdit
                            ? () {
                                setDialogState(() {
                                  selectedLang = WhatsAppMessageLanguage.english;
                                });
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedLang == WhatsAppMessageLanguage.english
                                ? const Color(0xFF25D366).withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedLang == WhatsAppMessageLanguage.english
                                  ? const Color(0xFF25D366)
                                  : AppColors.divider,
                              width: selectedLang == WhatsAppMessageLanguage.english ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selectedLang == WhatsAppMessageLanguage.english
                                            ? const Color(0xFF128C7E)
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: selectedLang == WhatsAppMessageLanguage.english
                                        ? Center(
                                            child: Container(
                                              width: 11,
                                              height: 11,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF128C7E),
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('🌐', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'English',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          'Standard English reminders and receipt formats',
                                          style: TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '🙏 Jay Maa Durga Devi 🙏\nNamaskar Ram bhai,\nDurga Puja Chanda Details:\nTarget: ₹2,000 | Paid: ₹1,000 | Pending: ₹1,000\nPlease clear your pending chanda. Dhanyawad 🙏',
                                  style: TextStyle(fontSize: 11.5, height: 1.35, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Close'),
                ),
                if (canEdit)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () async {
                      Navigator.pop(dialogCtx);
                      await ref
                          .read(whatsAppSettingsProvider.notifier)
                          .setLanguage(selectedLang, updatedBy: userName);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'WhatsApp message format set to ${selectedLang.displayName} ✅',
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: const Text('Save & Apply'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
