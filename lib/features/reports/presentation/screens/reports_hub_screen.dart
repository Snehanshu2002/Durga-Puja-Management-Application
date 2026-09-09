import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:printing/printing.dart';
import 'package:durgapuja_manager/core/utils/file_download_helper.dart';

import 'package:durgapuja_manager/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:durgapuja_manager/features/collection/presentation/providers/collection_provider.dart';
import 'package:durgapuja_manager/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:durgapuja_manager/features/expense/presentation/providers/expense_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/reports/domain/services/report_csv_export_service.dart';
import 'package:durgapuja_manager/features/reports/domain/services/report_excel_export_service.dart';
import 'package:durgapuja_manager/features/reports/domain/services/report_pdf_export_service.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';

import 'category_expense_report_screen.dart';
import 'collector_wise_collection_screen.dart';
import 'financial_summary_report_screen.dart';
import 'person_wise_collection_screen.dart';
import 'chanda_report_screen.dart';
import 'custody_report_screen.dart';
import 'cash_movement_report_screen.dart';

class ReportsHubScreen extends ConsumerWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final permissionService = PermissionService();

    final canViewReports = user != null &&
        permissionService.hasPermission(user.role, Permission.viewReports);

    if (!canViewReports) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reports')),
        body: const Center(
          child: Text('You do not have permission to view reports.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Reports Data',
            onPressed: () {
              ref.invalidate(dashboardProvider);
              ref.invalidate(activePujaEventProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reports data refreshed!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportTile(
            context,
            title: 'Financial Summary Report',
            subtitle: 'Overview of totals, balance, pending, and rejected entries',
            icon: Icons.assessment,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FinancialSummaryReportScreen(),
                ),
              );
            },
          ),
          _buildReportTile(
            context,
            title: 'Category-wise Expense Details',
            subtitle: 'Detailed vendor payment records by expense category',
            icon: Icons.receipt_long,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryExpenseReportScreen(),
                ),
              );
            },
          ),
          _buildReportTile(
            context,
            title: 'Person-wise Collection Report',
            subtitle: 'Donor-wise collection history and total contributions',
            icon: Icons.person_search,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonWiseCollectionScreen(),
                ),
              );
            },
          ),
          _buildReportTile(
            context,
            title: 'Collector-wise Collection Report',
            subtitle: 'Collection totals aggregated by committee member',
            icon: Icons.group,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CollectorWiseCollectionScreen(),
                ),
              );
            },
          ),
          _buildReportTile(
            context,
            title: 'Chanda Pledges Report',
            subtitle: 'Member pledges, target vs paid progress, and dues',
            icon: Icons.assignment_turned_in,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChandaReportScreen(),
                ),
              );
            },
          ),
          _buildReportTile(
            context,
            title: 'Collector Custody Report',
            subtitle: 'Cash in-hand balances held across collectors and treasurer',
            icon: Icons.account_balance_wallet,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustodyReportScreen(),
                ),
              );
            },
          ),
          _buildReportTile(
            context,
            title: 'Cash Movement & Handover History',
            subtitle: 'Audit trail of cash handovers and bank deposits',
            icon: Icons.history,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CashMovementReportScreen(),
                ),
              );
            },
          ),
          _buildReportTile(
            context,
            title: 'Analytics & Category Breakdowns',
            subtitle: 'Expense categories, payment modes, and daily trends',
            icon: Icons.pie_chart,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AnalyticsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 32),
          Text(
            'Export Reports & Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (permissionService.hasPermission(user.role, Permission.exportReports)) ...[
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export Itemized Financial PDF Report'),
              subtitle: const Text('Download printable PDF with donor-wise & expense list tables'),
              onTap: () async {
                final activeEvent = ref.read(activePujaEventProvider);
                final summary = ref.read(dashboardProvider).value;
                final messenger = ScaffoldMessenger.of(context);

                if (summary == null || activeEvent == null) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('No active financial data available for PDF generation.')),
                  );
                  return;
                }

                messenger.showSnackBar(
                  const SnackBar(content: Text('Generating Itemized PDF Report...')),
                );

                final collectionRepo = ref.read(collectionRepositoryProvider);
                final expenseRepo = ref.read(expenseRepositoryProvider);

                final collections = await collectionRepo.getCollectionsByEventId(activeEvent.id);
                final expenses = await expenseRepo.getExpensesByEventId(activeEvent.id);

                final pdfBytes = await ReportPdfExportService.generateFinancialSummaryPdf(
                  summary: summary,
                  collections: collections,
                  expenses: expenses,
                  committeeName: 'Durga Puja Managing Committee',
                  generatedBy: user.name,
                );

                await Printing.layoutPdf(
                  onLayout: (format) async => pdfBytes,
                  name: '${activeEvent.name}_Itemized_Financial_Report.pdf',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export Collection & Expense Data (Excel .xlsx)'),
              subtitle: const Text('Export full dataset to Microsoft Excel spreadsheet'),
              onTap: () async {
                final activeEvent = ref.read(activePujaEventProvider);
                final messenger = ScaffoldMessenger.of(context);

                if (activeEvent == null) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('No active Puja event selected.')),
                  );
                  return;
                }

                messenger.showSnackBar(
                  const SnackBar(content: Text('Generating Excel dataset...')),
                );

                final collectionRepo = ref.read(collectionRepositoryProvider);
                final collections = await collectionRepo.getCollectionsByEventId(activeEvent.id);

                final excelBytes = ReportExcelExportService.exportCollectionsToExcel(
                  collections: collections,
                  eventName: activeEvent.name,
                );

                if (excelBytes != null) {
                  final fileName = '${activeEvent.name.replaceAll(' ', '_')}_Collections.xlsx';
                  await FileDownloadHelper.downloadFile(
                    bytes: excelBytes,
                    fileName: fileName,
                    shareText: '${activeEvent.name} Collections Excel Report',
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: const Text('Export Raw Data (CSV)'),
              subtitle: const Text('Export UTF-8 compatible CSV files for accounting software'),
              onTap: () async {
                final activeEvent = ref.read(activePujaEventProvider);
                final messenger = ScaffoldMessenger.of(context);

                if (activeEvent == null) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('No active Puja event selected.')),
                  );
                  return;
                }

                messenger.showSnackBar(
                  const SnackBar(content: Text('Generating CSV export...')),
                );

                final collectionRepo = ref.read(collectionRepositoryProvider);
                final collections = await collectionRepo.getCollectionsByEventId(activeEvent.id);

                final csvContent = ReportCsvExportService.exportCollectionsToCsv(collections);
                final fileName = '${activeEvent.name.replaceAll(' ', '_')}_Collections.csv';
                await FileDownloadHelper.downloadFile(
                  bytes: utf8.encode(csvContent),
                  fileName: fileName,
                  shareText: '${activeEvent.name} Collections CSV File',
                );
              },
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Note: Your account role does not have permission to export raw reports.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondaryLight),
        onTap: onTap,
      ),
    );
  }
}
