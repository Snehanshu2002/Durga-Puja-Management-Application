import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/features/approval/presentation/screens/approval_dashboard_screen.dart';
import 'package:durgapuja_manager/features/collection/presentation/screens/add_collection_screen.dart';
import 'package:durgapuja_manager/features/chanda/presentation/screens/chanda_dashboard_screen.dart';
import 'package:durgapuja_manager/features/custody/presentation/screens/custody_dashboard_screen.dart';
import 'package:durgapuja_manager/features/expense/presentation/screens/add_expense_screen.dart';
import 'package:durgapuja_manager/features/reports/presentation/screens/category_expense_report_screen.dart';
import 'package:durgapuja_manager/features/reports/presentation/screens/person_wise_collection_screen.dart';

class QuickActionHub extends StatelessWidget {
  final bool canAddCollection;
  final bool canAddExpense;
  final bool canApprove;

  const QuickActionHub({
    super.key,
    required this.canAddCollection,
    required this.canAddExpense,
    required this.canApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'QUICK ACTIONS',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              if (canAddCollection)
                _buildActionChip(
                  context,
                  label: 'Add Chanda',
                  icon: Icons.add_circle_outline_rounded,
                  color: AppColors.success,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddCollectionScreen()),
                    );
                  },
                ),
              if (canAddExpense)
                _buildActionChip(
                  context,
                  label: 'Add Expense',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.expense,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                    );
                  },
                ),
              if (canApprove)
                _buildActionChip(
                  context,
                  label: 'Approvals',
                  icon: Icons.verified_user_outlined,
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ApprovalDashboardScreen()),
                    );
                  },
                ),
              _buildActionChip(
                context,
                label: 'Chanda Pledges',
                icon: Icons.volunteer_activism_outlined,
                color: AppColors.primaryDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChandaDashboardScreen()),
                  );
                },
              ),
              _buildActionChip(
                context,
                label: 'Cash Custody',
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.teal.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustodyDashboardScreen()),
                  );
                },
              ),
              _buildActionChip(
                context,
                label: 'Collector Summary',
                icon: Icons.people_alt_outlined,
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PersonWiseCollectionScreen()),
                  );
                },
              ),
              _buildActionChip(
                context,
                label: 'Expense Breakdown',
                icon: Icons.pie_chart_outline_rounded,
                color: AppColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoryExpenseReportScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
