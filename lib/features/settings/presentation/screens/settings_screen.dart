import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/constants/app_constants.dart';
import 'package:durgapuja_manager/core/providers/whatsapp_settings_provider.dart';
import 'package:durgapuja_manager/core/utils/whatsapp_share_helper.dart';
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
    final waConfig = ref.watch(whatsAppSettingsProvider);

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
            title: const Text('WhatsApp Message & QR Scanner Format'),
            subtitle: Text('Language: ${waConfig.language.displayName} • QR Scanner: ${waConfig.includePaymentQr ? "Enabled" : "Off"}'),
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
                  Text(waConfig.language.icon, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    waConfig.language == WhatsAppMessageLanguage.odia ? 'ଓଡ଼ିଆ' : 'English',
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
              waConfig,
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
    WhatsAppConfig currentConfig,
    bool canEdit,
    String? userName,
  ) {
    WhatsAppMessageLanguage selectedLang = currentConfig.language;
    bool includeQr = currentConfig.includePaymentQr;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final previewMsg = WhatsAppShareHelper.formatChandaDueReminder(
              orgName: 'Durga Puja Committee',
              eventName: 'Durga Puja 2026',
              eventYear: 2026,
              memberName: 'ରାମ ସାହୁ (Ram Sahoo)',
              targetAmount: 2000,
              paidAmount: 1000,
              remainingAmount: 1000,
              language: selectedLang,
              includePaymentQr: includeQr,
              upiId: currentConfig.upiId,
              paymentPhone: currentConfig.paymentPhone,
              payeeName: currentConfig.payeeName,
              qrImageUrl: currentConfig.qrImageUrl,
              customScreenshotNote: currentConfig.customNote,
            );

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
                          'WhatsApp & QR Scanner Format',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Admin Message & Payment Setup',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  'Only Admin, President, or Treasurer can change the WhatsApp & QR Scanner format.',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 1. Language Option: Odia (Default)
                      const Text(
                        '1. Message Language (ଭାଷା):',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: canEdit
                                  ? () => setDialogState(() => selectedLang = WhatsAppMessageLanguage.odia)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selectedLang == WhatsAppMessageLanguage.odia
                                      ? const Color(0xFF25D366).withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedLang == WhatsAppMessageLanguage.odia
                                        ? const Color(0xFF25D366)
                                        : AppColors.divider,
                                    width: selectedLang == WhatsAppMessageLanguage.odia ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🌺', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'ଓଡ଼ିଆ (Odia - Default)',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    if (selectedLang == WhatsAppMessageLanguage.odia)
                                      const Icon(Icons.check_circle, color: Color(0xFF128C7E), size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: canEdit
                                  ? () => setDialogState(() => selectedLang = WhatsAppMessageLanguage.english)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selectedLang == WhatsAppMessageLanguage.english
                                      ? const Color(0xFF25D366).withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedLang == WhatsAppMessageLanguage.english
                                        ? const Color(0xFF25D366)
                                        : AppColors.divider,
                                    width: selectedLang == WhatsAppMessageLanguage.english ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🌐', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'English',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    if (selectedLang == WhatsAppMessageLanguage.english)
                                      const Icon(Icons.check_circle, color: Color(0xFF128C7E), size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 2. PhonePe QR Scanner & Screenshot Instructions Section
                      const Text(
                        '2. PhonePe Payment QR Scanner & Screenshot Instruction:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5f259f).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF5f259f).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/payment_qr.jpg',
                                    width: 70,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.qr_code_scanner, color: Color(0xFF5f259f), size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            'PhonePe Accepted Here',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5f259f)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '📱 Mobile No: ${currentConfig.paymentPhone} (PhonePe/GPay)',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF128C7E)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'UPI ID: ${currentConfig.upiId}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'Payee: ${currentConfig.payeeName}',
                                        style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () => WhatsAppShareHelper.showPaymentQrDialog(context, config: currentConfig),
                                        child: const Text(
                                          '🔍 View / Share Full QR Image',
                                          style: TextStyle(fontSize: 11.5, color: Color(0xFF128C7E), fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            SwitchListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              activeTrackColor: const Color(0xFF25D366),
                              title: const Text(
                                'Include QR Scanner & Screenshot Instruction in Reminder',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text(
                                'Adds QR image link, UPI ID, and screenshot note to message',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              value: includeQr,
                              onChanged: canEdit
                                  ? (val) => setDialogState(() => includeQr = val)
                                  : null,
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                selectedLang == WhatsAppMessageLanguage.odia
                                    ? '⚠️ ସୂଚନା: ପେମେଣ୍ଟ କରିସାରିବା ପରେ Payment Screenshot ଏହି ନମ୍ବର କିମ୍ବା WhatsApp Group ରେ ନିଶ୍ଚୟ ପଠାନ୍ତୁ।'
                                    : '⚠️ Note: After payment, please send the payment screenshot on this number or committee WhatsApp group.',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Live Message Preview
                      const Text(
                        '3. Live Message Preview (ମେସେଜ୍ କିପରି ଯିବ):',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          previewMsg,
                          style: const TextStyle(fontSize: 11.5, height: 1.4, color: Colors.black87),
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
                      await ref.read(whatsAppSettingsProvider.notifier).updateConfig(
                            language: selectedLang,
                            includePaymentQr: includeQr,
                            updatedBy: userName,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'WhatsApp message & QR settings saved (${selectedLang.displayName}) ✅',
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
