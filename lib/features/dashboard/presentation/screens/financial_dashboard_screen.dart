import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/config/app_environment.dart';
import 'package:durgapuja_manager/core/enums/payment_mode.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/dev_seeder.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/widgets/error_view.dart';
import 'package:durgapuja_manager/core/widgets/loading_view.dart';
import 'package:durgapuja_manager/features/approval/presentation/screens/approval_dashboard_screen.dart';
import 'package:durgapuja_manager/features/auth/presentation/providers/auth_provider.dart';
import 'package:durgapuja_manager/features/collection/domain/entities/collection_entity.dart';
import 'package:durgapuja_manager/features/collection/presentation/providers/collection_provider.dart';
import 'package:durgapuja_manager/features/collection/presentation/screens/add_collection_screen.dart';
import 'package:durgapuja_manager/features/chanda/presentation/providers/chanda_provider.dart';
import 'package:durgapuja_manager/features/chanda/presentation/screens/chanda_dashboard_screen.dart';
import 'package:durgapuja_manager/features/custody/presentation/providers/custody_provider.dart';
import 'package:durgapuja_manager/features/custody/presentation/screens/custody_dashboard_screen.dart';
import 'package:durgapuja_manager/features/dashboard/domain/entities/financial_summary.dart';
import 'package:durgapuja_manager/features/expense/presentation/screens/add_expense_screen.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/widgets/event_selector.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/reports/presentation/screens/category_expense_report_screen.dart';
import 'package:durgapuja_manager/features/reports/presentation/screens/person_wise_collection_screen.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/festive_countdown_banner.dart';
import '../widgets/quick_action_hub.dart';
import '../widgets/budget_progress_card.dart';

class FinancialDashboardScreen extends ConsumerWidget {
  const FinancialDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final user = ref.watch(currentUserProvider).value;
    final activeEvent = ref.watch(activePujaEventProvider);
    final effectiveRole = ref.watch(effectiveRoleProvider);
    final chandaSummary = ref.watch(chandaSummaryProvider);
    final custodySummary = ref.watch(custodySummaryProvider);
    final collectionsAsync = ref.watch(collectionsProvider);
    final permissionService = PermissionService();

    final canApprove = user != null &&
        permissionService.hasAnyPermission(
          effectiveRole,
          [Permission.approveCollection, Permission.approveExpense],
        );

    final canAddCollection = user != null &&
        permissionService.hasPermission(effectiveRole, Permission.addCollection);
    final canAddExpense = user != null &&
        permissionService.hasPermission(effectiveRole, Permission.addExpense);
    final canAddEntry = canAddCollection || canAddExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () async {
              if (AppEnvironment.isDev) {
                await DevBootstrapSeeder.seedDevEnvironment();
              }
              ref.invalidate(dashboardProvider);
              ref.invalidate(pujaEventsProvider);
              ref.invalidate(currentUserProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data refreshed & synced!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          const EventSelector(),
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.expense.withValues(alpha: 0.85)),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FestiveCountdownBanner(),
              if (user != null) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                            children: [
                              const TextSpan(text: 'Logged in as: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: user.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              TextSpan(
                                text: ' (${effectiveRole.displayName})',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                              ),
                              TextSpan(
                                text: ' • ${user.email}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                QuickActionHub(
                  canAddCollection: canAddCollection,
                  canAddExpense: canAddExpense,
                  canApprove: canApprove,
                ),
              ],
              dashboardAsync.when(
                data: (summary) {
                  if (summary == null) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text('No active Puja event selected.'),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Action Required Section (for Approval Roles)
                        if (canApprove)
                          _buildActionRequiredSection(context, summary, custodySummary),

                        // Main Balance Card — Deep Maroon with subtle gold accent
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: summary.isDeficit
                                  ? [
                                      AppColors.expense,
                                      AppColors.expense.withValues(alpha: 0.85),
                                    ]
                                  : [
                                      AppColors.primary,
                                      AppColors.primaryDark,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                top: -20,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accent.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          summary.isDeficit
                                              ? 'DEFICIT BALANCE'
                                              : 'CURRENT BALANCE',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.account_balance_wallet,
                                            color: AppColors.accentLight,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      MoneyFormatter.format(summary.currentBalance),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: summary.isDeficit
                                            ? Colors.black.withValues(alpha: 0.2)
                                            : AppColors.accent.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        summary.isDeficit ? 'Current Deficit' : 'Current Surplus',
                                        style: TextStyle(
                                          color: summary.isDeficit
                                              ? Colors.white
                                              : AppColors.accentLight,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      activeEvent != null
                                          ? '${activeEvent.organizationName}\n${activeEvent.name} (${activeEvent.year})'
                                          : 'Event: ${summary.eventName}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Grid for Collection & Expense
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.15,
                          children: [
                            SummaryCard(
                              title: 'TOTAL COLLECTION',
                              value: MoneyFormatter.format(
                                summary.totalApprovedCollection,
                              ),
                              subtitle:
                                  '${summary.approvedCollectionCount} approved entries',
                              icon: Icons.arrow_downward_rounded,
                              color: AppColors.success,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PersonWiseCollectionScreen(),
                                  ),
                                );
                              },
                            ),
                            SummaryCard(
                              title: 'TOTAL EXPENSE',
                              value: MoneyFormatter.format(
                                summary.totalApprovedExpense,
                              ),
                              subtitle:
                                  '${summary.approvedExpenseCount} approved entries',
                              icon: Icons.arrow_upward_rounded,
                              color: AppColors.expense,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CategoryExpenseReportScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        BudgetProgressCard(summary: summary),

                        _buildChandaAndCustodyInsights(context, chandaSummary, custodySummary),

                        const SizedBox(height: 16),

                        // Financial Collection Trends Section (APPROVED Only)
                        _buildFinancialTrendsSection(summary, collectionsAsync.value ?? []),

                        const SizedBox(height: 16),

                        // Donors & Stats Card
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primarySurface,
                              child: Icon(Icons.people_outline, color: AppColors.primary, size: 20),
                            ),
                            title: Text('Unique Donors: ${summary.totalDonorCount}'),
                            subtitle: Text(
                              'Average Donation: ${MoneyFormatter.format(summary.averageDonation.round())}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const LoadingView(message: 'Calculating totals...'),
                error: (err, _) => ErrorView(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(dashboardProvider),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: canAddEntry
          ? FloatingActionButton.extended(
              heroTag: 'dashboard_fab',
              onPressed: () => _showAddTransactionModal(
                context,
                canAddCollection: canAddCollection,
                canAddExpense: canAddExpense,
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Entry',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildActionRequiredSection(
    BuildContext context,
    FinancialSummary summary,
    CustodySummary custodySummary,
  ) {
    final pendingColl = summary.pendingCollectionCount;
    final pendingExp = summary.pendingExpenseCount;
    final pendingHandovers = custodySummary.pendingHandoversCount;
    final totalPendingActions = pendingColl + pendingExp + pendingHandovers;

    if (totalPendingActions == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 22),
              const SizedBox(width: 8),
              Text(
                'ACTION REQUIRED ($totalPendingActions Pending)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.amber.shade900,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pendingColl > 0)
            _buildActionItem(
              icon: Icons.volunteer_activism,
              color: AppColors.success,
              title: 'Pending Collections ($pendingColl)',
              subtitle: 'Total: ${MoneyFormatter.format(summary.pendingCollectionAmount)}',
              buttonText: 'Review Collections',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApprovalDashboardScreen(initialTabIndex: 0)),
                );
              },
            ),
          if (pendingExp > 0) ...[
            if (pendingColl > 0) const SizedBox(height: 8),
            _buildActionItem(
              icon: Icons.receipt_long,
              color: AppColors.expense,
              title: 'Pending Expenses ($pendingExp)',
              subtitle: 'Total: ${MoneyFormatter.format(summary.pendingExpenseAmount)}',
              buttonText: 'Review Expenses',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApprovalDashboardScreen(initialTabIndex: 1)),
                );
              },
            ),
          ],
          if (pendingHandovers > 0) ...[
            if (pendingColl > 0 || pendingExp > 0) const SizedBox(height: 8),
            _buildActionItem(
              icon: Icons.account_balance_wallet,
              color: Colors.blue.shade800,
              title: 'Pending Cash Handovers ($pendingHandovers)',
              subtitle: 'Collector to Treasurer / Bank transfers',
              buttonText: 'Verify Handovers',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustodyDashboardScreen()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(0, 32),
            ),
            onPressed: onTap,
            child: Text(buttonText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTrendsSection(FinancialSummary summary, List<dynamic> collections) {
    final approvedList = collections.where((c) => c is CollectionEntity && c.isApproved).cast<CollectionEntity>().toList();
    final cashAmount = approvedList.where((c) => c.paymentMode == PaymentMode.cash).fold<int>(0, (sum, c) => sum + c.amount);
    final upiAmount = approvedList.where((c) => c.paymentMode != PaymentMode.cash).fold<int>(0, (sum, c) => sum + c.amount);
    final totalApproved = summary.totalApprovedCollection > 0 ? summary.totalApprovedCollection : (cashAmount + upiAmount);

    final cashPercent = totalApproved > 0 ? (cashAmount / totalApproved * 100).round() : 0;
    final upiPercent = totalApproved > 0 ? (upiAmount / totalApproved * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'COLLECTION BREAKDOWN (APPROVED ONLY)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTrendMetric('💵 Physical Cash', MoneyFormatter.format(cashAmount), '$cashPercent% of total', AppColors.success),
              _buildTrendMetric('📱 UPI / Online / Bank', MoneyFormatter.format(upiAmount), '$upiPercent% of total', Colors.blue.shade700),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                if (cashPercent > 0)
                  Expanded(
                    flex: cashPercent,
                    child: Container(height: 8, color: AppColors.success),
                  ),
                if (upiPercent > 0)
                  Expanded(
                    flex: upiPercent,
                    child: Container(height: 8, color: Colors.blue.shade700),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendMetric(String label, String value, String sub, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out?'),
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

  void _showAddTransactionModal(
    BuildContext context, {
    required bool canAddCollection,
    required bool canAddExpense,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (canAddCollection) ...[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.successLight,
                      child: Icon(Icons.volunteer_activism, color: AppColors.success, size: 20),
                    ),
                    title: const Text('Add Public Collection', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Record donor chanda, sponsorship, or public donation'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddCollectionScreen()),
                      );
                    },
                  ),
                ],
                if (canAddCollection && canAddExpense) Divider(color: AppColors.divider),
                if (canAddExpense) ...[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.expenseLight,
                      child: Icon(Icons.receipt_long, color: AppColors.expense, size: 20),
                    ),
                    title: const Text('Add Puja Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Record pandal, sound, food, or vendor expenses'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChandaAndCustodyInsights(
    BuildContext context,
    ChandaSummary chandaSummary,
    CustodySummary custodySummary,
  ) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChandaDashboardScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.assignment_turned_in_outlined, size: 16, color: Colors.amber.shade900),
                              const SizedBox(width: 4),
                              Text(
                                'Chanda Pledges',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${MoneyFormatter.format(chandaSummary.totalCollected)} / ${MoneyFormatter.format(chandaSummary.totalTarget)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Remaining: ${MoneyFormatter.format(chandaSummary.totalRemaining)}',
                          style: TextStyle(fontSize: 11, color: chandaSummary.totalRemaining > 0 ? AppColors.expense : AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustodyDashboardScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.blue.shade900),
                              const SizedBox(width: 4),
                              Text(
                                'Cash Custody',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'In Hand: ${MoneyFormatter.format(custodySummary.totalInCustody)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          custodySummary.pendingHandoversCount > 0
                              ? '${custodySummary.pendingHandoversCount} Pending Transfer'
                              : 'Bank: ${MoneyFormatter.format(custodySummary.totalDeposited)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: custodySummary.pendingHandoversCount > 0 ? Colors.amber.shade900 : Colors.blue.shade700,
                            fontWeight: custodySummary.pendingHandoversCount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
