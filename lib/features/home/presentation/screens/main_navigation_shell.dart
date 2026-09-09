import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/features/approval/presentation/screens/approval_dashboard_screen.dart';
import 'package:durgapuja_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:durgapuja_manager/features/auth/presentation/screens/login_screen.dart';
import 'package:durgapuja_manager/features/chanda/presentation/screens/chanda_dashboard_screen.dart';
import 'package:durgapuja_manager/features/custody/presentation/screens/custody_dashboard_screen.dart';
import 'package:durgapuja_manager/features/dashboard/presentation/screens/financial_dashboard_screen.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/screens/puja_event_list_screen.dart';
import 'package:durgapuja_manager/features/reports/presentation/screens/reports_hub_screen.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';

import 'package:durgapuja_manager/features/auth/presentation/providers/session_manager_provider.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        if (user.isActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final sessionMgr = ref.read(sessionManagerProvider);
            if (sessionMgr.activeLocalSessionId == null || sessionMgr.activeLocalSessionId!.isEmpty) {
              sessionMgr.startSessionMonitoring(
                uid: user.uid,
                initialSessionId: user.activeSessionId ?? '',
              );
            }
          });
        }

        if (!user.isActive) {
          return Scaffold(
            appBar: AppBar(title: const Text('Account Inactive')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.expenseLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.block, size: 48, color: AppColors.expense),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Account Inactive',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your account has been deactivated by the administrator. Please contact your committee Super Admin for assistance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expense,
                        minimumSize: const Size(200, 46),
                      ),
                      onPressed: () {
                        ref.read(authControllerProvider).signOut();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final permissionService = PermissionService();
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktopOrTablet = screenWidth >= 700;
        final List<NavigationTabItem> tabs = [];

        // 1. Dashboard (Always included)
        if (permissionService.hasPermission(user.role, Permission.viewDashboard)) {
          tabs.add(
            const NavigationTabItem(
              label: 'Dashboard',
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard,
              screen: FinancialDashboardScreen(),
            ),
          );
        }

        // 2. Chanda Target / Pledge Management (Always included for collection viewers)
        if (permissionService.hasPermission(user.role, Permission.viewCollection)) {
          tabs.add(
            const NavigationTabItem(
              label: 'Chanda',
              icon: Icons.volunteer_activism_outlined,
              selectedIcon: Icons.volunteer_activism,
              screen: ChandaDashboardScreen(),
            ),
          );
        }

        // 3. Collection Custody / Handover Tracking (Core financial tab)
        if (permissionService.hasPermission(user.role, Permission.viewCollection)) {
          tabs.add(
            const NavigationTabItem(
              label: 'Custody',
              icon: Icons.account_balance_wallet_outlined,
              selectedIcon: Icons.account_balance_wallet,
              screen: CustodyDashboardScreen(),
            ),
          );
        }

        // 4. Approvals / Reports
        final hasApprovalPermission = permissionService.hasAnyPermission(
            user.role, [Permission.approveCollection, Permission.approveExpense]);

        if (hasApprovalPermission) {
          tabs.add(
            const NavigationTabItem(
              label: 'Approvals',
              icon: Icons.rate_review_outlined,
              selectedIcon: Icons.rate_review,
              screen: ApprovalDashboardScreen(),
            ),
          );
        } else if (permissionService.hasPermission(user.role, Permission.viewReports)) {
          tabs.add(
            const NavigationTabItem(
              label: 'Reports',
              icon: Icons.analytics_outlined,
              selectedIcon: Icons.analytics,
              screen: ReportsHubScreen(),
            ),
          );
        }

        // On Desktop/Tablet only, add separate Reports and Events tabs to the side rail
        if (isDesktopOrTablet) {
          if (hasApprovalPermission && permissionService.hasPermission(user.role, Permission.viewReports)) {
            tabs.add(
              const NavigationTabItem(
                label: 'Reports',
                icon: Icons.analytics_outlined,
                selectedIcon: Icons.analytics,
                screen: ReportsHubScreen(),
              ),
            );
          }

          tabs.add(
            const NavigationTabItem(
              label: 'Events',
              icon: Icons.event_outlined,
              selectedIcon: Icons.event,
              screen: PujaEventListScreen(),
            ),
          );
        }

        // 5. Settings / More (Includes Events, Profile, Reports, Users, Audit, Notifications, Logout)
        tabs.add(
          const NavigationTabItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            screen: SettingsScreen(),
          ),
        );

        final safeIndex = _selectedIndex < tabs.length ? _selectedIndex : 0;

        if (isDesktopOrTablet) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: safeIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  extended: screenWidth >= 1000,
                  minExtendedWidth: 200,
                  backgroundColor: Colors.white,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (screenWidth >= 1000) ...[
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Puja Manager',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: CircleAvatar(
                          backgroundColor: AppColors.primarySurface,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  destinations: tabs.map((tab) {
                    return NavigationRailDestination(
                      icon: Icon(tab.icon),
                      selectedIcon: Icon(tab.selectedIcon, color: AppColors.primary),
                      label: Text(tab.label),
                    );
                  }).toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: safeIndex,
                    children: tabs.map((t) => t.screen).toList(),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: safeIndex,
            children: tabs.map((t) => t.screen).toList(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: safeIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: tabs.map((tab) {
              return NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Scaffold(
        body: LoadingView(message: 'Authenticating...'),
      ),
      error: (err, stackTrace) => const LoginScreen(),
    );
  }
}

class NavigationTabItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;

  const NavigationTabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });
}
