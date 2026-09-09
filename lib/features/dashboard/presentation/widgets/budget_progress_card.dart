import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/features/dashboard/domain/entities/financial_summary.dart';

class BudgetProgressCard extends StatelessWidget {
  final FinancialSummary summary;

  const BudgetProgressCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final totalInflow = summary.totalApprovedCollection;
    final totalOutflow = summary.totalApprovedExpense;
    final totalVolume = totalInflow + totalOutflow;

    final collectionPercentage = totalVolume > 0
        ? (totalInflow / totalVolume).clamp(0.0, 1.0)
        : 0.5;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'FINANCIAL RATIO & STATUS',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: summary.isDeficit
                      ? AppColors.expenseLight
                      : AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  summary.isDeficit ? 'Deficit' : 'Surplus',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: summary.isDeficit
                        ? AppColors.expense
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visual Dual-Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: (collectionPercentage * 100).toInt(),
                    child: Container(color: AppColors.success),
                  ),
                  Expanded(
                    flex: ((1 - collectionPercentage) * 100).toInt(),
                    child: Container(color: AppColors.expense),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Legend & Counts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Collection: ${MoneyFormatter.format(summary.totalApprovedCollection)}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.expense,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Expense: ${MoneyFormatter.format(summary.totalApprovedExpense)}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.expense,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
