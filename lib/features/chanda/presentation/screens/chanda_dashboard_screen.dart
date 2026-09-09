import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';
import 'package:durgapuja_manager/core/utils/money_formatter.dart';
import 'package:durgapuja_manager/core/utils/phone_launcher.dart';
import 'package:durgapuja_manager/core/utils/whatsapp_share_helper.dart';
import 'package:durgapuja_manager/core/widgets/status_chip.dart';
import 'package:durgapuja_manager/features/audit/domain/entities/audit_log.dart';
import 'package:durgapuja_manager/features/audit/presentation/providers/audit_provider.dart';
import 'package:durgapuja_manager/features/collection/presentation/screens/add_collection_screen.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/providers/puja_event_provider.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/widgets/event_selector.dart';
import 'package:durgapuja_manager/features/reports/domain/services/chanda_export_service.dart';
import 'package:durgapuja_manager/features/roles/domain/entities/permission.dart';
import 'package:durgapuja_manager/features/roles/domain/services/permission_service.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';
import '../../domain/entities/chanda_target_with_progress.dart';
import '../providers/chanda_provider.dart';
import 'add_edit_chanda_target_screen.dart';
import 'chanda_detail_screen.dart';

class ChandaDashboardScreen extends ConsumerStatefulWidget {
  const ChandaDashboardScreen({super.key});

  @override
  ConsumerState<ChandaDashboardScreen> createState() => _ChandaDashboardScreenState();
}

class _ChandaDashboardScreenState extends ConsumerState<ChandaDashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _logAuditAction({
    required String action,
    required String eventId,
    required String targetId,
    required String memberName,
    Map<String, dynamic>? metadata,
  }) {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final log = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: eventId,
      userId: user.uid,
      userName: user.name,
      action: action,
      entityType: 'CHANDA_TARGET',
      entityId: targetId,
      timestamp: DateTime.now(),
      metadata: {
        'memberName': memberName,
        ...?metadata,
      },
    );

    ref.read(auditRepositoryProvider).logAction(log).catchError((_) {});
  }

  Future<void> _exportPdf(BuildContext context) async {
    final activeEvent = ref.read(activePujaEventProvider);
    final targets = ref.read(filteredChandaListProvider);
    final user = ref.read(currentUserProvider).value;

    if (activeEvent == null) return;

    try {
      _logAuditAction(
        action: AuditLog.actionChandaPdfExport,
        eventId: activeEvent.id,
        targetId: 'ALL_TARGETS',
        memberName: 'Full Chanda List (${targets.length} members)',
      );

      if (context.mounted) {
        await ChandaExportService.printChandaList(
          organizationName: 'Durga Puja Committee',
          eventName: activeEvent.name,
          eventYear: activeEvent.year,
          targets: targets,
          generatedBy: user?.name ?? 'Super Admin',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    final activeEvent = ref.read(activePujaEventProvider);
    final targets = ref.read(filteredChandaListProvider);

    if (activeEvent == null) return;

    try {
      await ChandaExportService.exportAndShareCsv(
        organizationName: 'Durga Puja Committee',
        eventName: activeEvent.name,
        eventYear: activeEvent.year,
        targets: targets,
      );

      _logAuditAction(
        action: AuditLog.actionChandaCsvExport,
        eventId: activeEvent.id,
        targetId: 'ALL_TARGETS',
        memberName: 'Full Chanda List CSV (${targets.length} members)',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chanda CSV export generated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export CSV: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _printList(BuildContext context) async {
    final activeEvent = ref.read(activePujaEventProvider);
    final targets = ref.read(filteredChandaListProvider);
    final user = ref.read(currentUserProvider).value;

    if (activeEvent == null) return;

    try {
      await ChandaExportService.printChandaList(
        organizationName: 'Durga Puja Committee',
        eventName: activeEvent.name,
        eventYear: activeEvent.year,
        targets: targets,
        generatedBy: user?.name ?? 'Admin',
      );

      _logAuditAction(
        action: AuditLog.actionChandaPrint,
        eventId: activeEvent.id,
        targetId: 'ALL_TARGETS',
        memberName: 'Chanda List Print (${targets.length} members)',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to print: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeEvent = ref.watch(activePujaEventProvider);
    final summary = ref.watch(chandaSummaryProvider);
    final filteredList = ref.watch(filteredChandaListProvider);
    final selectedFilter = ref.watch(chandaFilterProvider);
    final selectedSort = ref.watch(chandaSortOptionProvider);
    final searchQuery = ref.watch(chandaSearchQueryProvider);
    final effectiveRole = ref.watch(effectiveRoleProvider);
    final membersAsync = ref.watch(activeEventMembersProvider);
    final allActiveMembers = membersAsync.value ?? [];
    final permissionService = PermissionService();

    final canManageTargets = permissionService.hasAnyPermission(
      effectiveRole,
      [Permission.managePujaEvents, Permission.approveCollection, Permission.addCollection],
    );
    final canAddCollection = permissionService.hasPermission(effectiveRole, Permission.addCollection);
    final canExport = permissionService.hasPermission(effectiveRole, Permission.viewReports) ||
        permissionService.hasPermission(effectiveRole, Permission.viewCollection);

    // Find active members who don't have an assigned target in this event
    final unassignedMembers = allActiveMembers.where((u) {
      return !filteredList.any((item) => item.target.userId == u.uid);
    }).toList();

    final hasActiveFilterOrSearch = searchQuery.isNotEmpty || selectedFilter != ChandaFilterType.all;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chanda Target / Pledge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Chanda',
            onPressed: () {
              ref.invalidate(chandaTargetsProvider);
              ref.invalidate(activeEventMembersProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chanda list refreshed!'), duration: Duration(seconds: 1)),
              );
            },
          ),
          if (canExport)
            PopupMenuButton<String>(
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              tooltip: 'Export / Print List',
              onSelected: (value) {
                if (value == 'pdf') _exportPdf(context);
                if (value == 'csv') _exportCsv(context);
                if (value == 'print') _printList(context);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 20),
                      SizedBox(width: 10),
                      Text('Export PDF Sheet'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'csv',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart, color: AppColors.success, size: 20),
                      SizedBox(width: 10),
                      Text('Export CSV (Excel)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      Icon(Icons.print, color: AppColors.textPrimaryLight, size: 20),
                      SizedBox(width: 10),
                      Text('Print Member List'),
                    ],
                  ),
                ),
              ],
            ),
          const EventSelector(),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: canManageTargets
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditChandaTargetScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Assign Target'),
            )
          : null,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(chandaTargetsProvider);
          ref.invalidate(activeEventMembersProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Event Context Banner
                    if (activeEvent != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.volunteer_activism, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Pledges for ${activeEvent.name} (${activeEvent.year})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Summary & Visual Progress Card
                    _buildSummaryHeader(summary),

                    const SizedBox(height: 12),

                    // Quick Stat Counter Row (All, Paid, Partial, Pending, Missing Phone)
                    _buildStatCounterRow(summary, selectedFilter),

                    const SizedBox(height: 12),

                    // Search Bar & Sort Dropdown
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search member name or mobile...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref.read(chandaSearchQueryProvider.notifier).state = '';
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onChanged: (val) {
                              ref.read(chandaSearchQueryProvider.notifier).state = val;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<ChandaSortOption>(
                          initialValue: selectedSort,
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(Icons.sort_rounded, color: AppColors.primary, size: 20),
                          ),
                          tooltip: 'Sort Options',
                          onSelected: (option) {
                            ref.read(chandaSortOptionProvider.notifier).state = option;
                          },
                          itemBuilder: (context) => ChandaSortOption.values.map((opt) {
                            return PopupMenuItem(
                              value: opt,
                              child: Row(
                                children: [
                                  Icon(
                                    selectedSort == opt ? Icons.radio_button_checked : Icons.radio_button_off,
                                    size: 16,
                                    color: selectedSort == opt ? AppColors.primary : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(opt.displayName, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All (${summary.totalMembers})', ChandaFilterType.all, selectedFilter),
                          const SizedBox(width: 6),
                          _buildFilterChip('Pending (${summary.pendingCount})', ChandaFilterType.pending, selectedFilter),
                          const SizedBox(width: 6),
                          _buildFilterChip('Partial (${summary.partialPaidCount})', ChandaFilterType.partial, selectedFilter),
                          const SizedBox(width: 6),
                          _buildFilterChip('Paid (${summary.fullyPaidCount})', ChandaFilterType.fullyPaid, selectedFilter),
                          if (summary.totalExcess > 0) ...[
                            const SizedBox(width: 6),
                            _buildFilterChip('Excess', ChandaFilterType.excess, selectedFilter),
                          ],
                          if (summary.missingPhoneCount > 0) ...[
                            const SizedBox(width: 6),
                            _buildFilterChip('⚠ Missing Phone (${summary.missingPhoneCount})', ChandaFilterType.missingPhone, selectedFilter, isWarning: true),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Section Header & Reset Filter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MEMBERS LIST (${filteredList.length})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        if (hasActiveFilterOrSearch)
                          InkWell(
                            onTap: () {
                              _searchController.clear();
                              ref.read(chandaSearchQueryProvider.notifier).state = '';
                              ref.read(chandaFilterProvider.notifier).state = ChandaFilterType.all;
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                children: [
                                  Icon(Icons.clear_all, size: 14, color: AppColors.primary),
                                  SizedBox(width: 2),
                                  Text(
                                    'Reset Filters',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Text(
                            'Showing ${filteredList.length} of ${summary.totalMembers}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Virtualized Members List
            if (filteredList.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(36),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No matching members found',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try adjusting your search query or filter chip selection.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildMemberCard(context, item, canAddCollection, canManageTargets, activeEvent?.name ?? 'Opera / Jatra', activeEvent?.year ?? 2026),
                      );
                    },
                    childCount: filteredList.length,
                  ),
                ),
              ),

            // Unassigned Committee Members Section
            if (unassignedMembers.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Icon(Icons.group_outlined, size: 18, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 6),
                      Text(
                        'UNASSIGNED COMMITTEE MEMBERS (${unassignedMembers.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final member = unassignedMembers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildUnassignedMemberTile(context, member, canManageTargets),
                      );
                    },
                    childCount: unassignedMembers.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(ChandaSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
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
              const Text(
                'CHANDA TARGET PROGRESS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${summary.achievementPercentage.toStringAsFixed(1)}% Achieved',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderMetric('Total Target', MoneyFormatter.format(summary.totalTarget), Colors.white),
              _buildHeaderMetric('Approved Paid', MoneyFormatter.format(summary.totalCollected), AppColors.accent),
              _buildHeaderMetric('Remaining Due', MoneyFormatter.format(summary.totalRemaining), Colors.white70),
              if (summary.totalExcess > 0)
                _buildHeaderMetric('Total Excess', MoneyFormatter.format(summary.totalExcess), Colors.tealAccent),
            ],
          ),
          const SizedBox(height: 12),

          // Visual Progress Multi-segment Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: summary.overallProgress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCounterRow(ChandaSummary summary, ChandaFilterType currentFilter) {
    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard(
            'Total',
            summary.totalMembers.toString(),
            currentFilter == ChandaFilterType.all ? AppColors.primary : AppColors.primarySurface,
            currentFilter == ChandaFilterType.all ? Colors.white : AppColors.primary,
            () => ref.read(chandaFilterProvider.notifier).state = ChandaFilterType.all,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildBadgeCard(
            'Paid',
            summary.fullyPaidCount.toString(),
            currentFilter == ChandaFilterType.fullyPaid ? AppColors.success : AppColors.successLight,
            currentFilter == ChandaFilterType.fullyPaid ? Colors.white : AppColors.success,
            () => ref.read(chandaFilterProvider.notifier).state = ChandaFilterType.fullyPaid,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildBadgeCard(
            'Partial',
            summary.partialPaidCount.toString(),
            currentFilter == ChandaFilterType.partial ? Colors.orange.shade800 : Colors.orange.shade50,
            currentFilter == ChandaFilterType.partial ? Colors.white : Colors.orange.shade800,
            () => ref.read(chandaFilterProvider.notifier).state = ChandaFilterType.partial,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildBadgeCard(
            'Pending',
            summary.pendingCount.toString(),
            currentFilter == ChandaFilterType.pending ? Colors.grey.shade800 : Colors.grey.shade100,
            currentFilter == ChandaFilterType.pending ? Colors.white : Colors.grey.shade700,
            () => ref.read(chandaFilterProvider.notifier).state = ChandaFilterType.pending,
          ),
        ),
        if (summary.missingPhoneCount > 0) ...[
          const SizedBox(width: 6),
          Expanded(
            child: _buildBadgeCard(
              'No Phone',
              summary.missingPhoneCount.toString(),
              currentFilter == ChandaFilterType.missingPhone ? Colors.amber.shade900 : Colors.amber.shade50,
              currentFilter == ChandaFilterType.missingPhone ? Colors.white : Colors.amber.shade900,
              () => ref.read(chandaFilterProvider.notifier).state = ChandaFilterType.missingPhone,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBadgeCard(String label, String count, Color bgColor, Color textColor, VoidCallback onTap) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Column(
            children: [
              Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ChandaFilterType type, ChandaFilterType current, {bool isWarning = false}) {
    final isSelected = type == current;
    final activeColor = isWarning ? Colors.amber.shade900 : AppColors.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(chandaFilterProvider.notifier).state = type;
      },
      selectedColor: activeColor,
      backgroundColor: isWarning ? Colors.amber.shade50 : null,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isWarning ? Colors.amber.shade900 : AppColors.textPrimaryLight),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    ChandaTargetWithProgress item,
    bool canAddCollection,
    bool canManageTargets,
    String eventName,
    int eventYear,
  ) {
    final hasPhone = item.target.mobileNumber != null && item.target.mobileNumber!.trim().isNotEmpty;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChandaDetailScreen(targetId: item.target.id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.target.personName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                        ),
                        const SizedBox(height: 3),
                        if (hasPhone)
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () => PhoneLauncher.makePhoneCall(context, item.target.mobileNumber!),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.target.mobileNumber!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          InkWell(
                            onTap: () {
                              if (canManageTargets) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditChandaTargetScreen(target: item.target),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 12, color: Colors.amber.shade900),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Missing Phone • Add Mobile',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  StatusChip(status: item.computedStatus),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCardMetric('Target', item.targetAmount, AppColors.textPrimaryLight),
                  _buildCardMetric('Approved Paid', item.paidAmount, AppColors.success),
                  if (item.hasExcess)
                    _buildCardMetric('Excess', item.excessAmount, Colors.teal)
                  else
                    _buildCardMetric('Remaining', item.remainingAmount, item.remainingAmount > 0 ? AppColors.expense : AppColors.success),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progressPercentage,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    item.isFullyPaid ? AppColors.success : item.isPartial ? Colors.orange : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // 1-Tap Free WhatsApp Reminder Button
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                      foregroundColor: const Color(0xFF128C7E),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(6),
                    ),
                    tooltip: 'WhatsApp Reminder to ${item.target.personName}',
                    onPressed: () {
                      final msg = WhatsAppShareHelper.formatChandaDueReminder(
                        orgName: 'Durga Puja Committee',
                        eventName: eventName,
                        eventYear: eventYear,
                        memberName: item.target.personName,
                        targetAmount: item.targetAmount,
                        paidAmount: item.paidAmount,
                        remainingAmount: item.remainingAmount,
                      );

                      WhatsAppShareHelper.shareToWhatsApp(
                        context: context,
                        phoneNumber: item.target.mobileNumber,
                        message: msg,
                        onShareSuccess: () {
                          _logAuditAction(
                            action: AuditLog.actionWhatsappShare,
                            eventId: item.target.eventId,
                            targetId: item.target.id,
                            memberName: item.target.personName,
                            metadata: {'type': 'CHANDA_REMINDER'},
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  ),

                  if (hasPhone) ...[
                    const SizedBox(width: 4),
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.success.withValues(alpha: 0.12),
                        foregroundColor: AppColors.success,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(6),
                      ),
                      tooltip: 'Call ${item.target.personName}',
                      onPressed: () => PhoneLauncher.makePhoneCall(context, item.target.mobileNumber!),
                      icon: const Icon(Icons.phone_in_talk, size: 16),
                    ),
                  ],

                  const Spacer(),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                      minimumSize: const Size(0, 32),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChandaDetailScreen(targetId: item.target.id)),
                      );
                    },
                    icon: const Icon(Icons.history, size: 14),
                    label: const Text('History', style: TextStyle(fontSize: 11)),
                  ),

                  if (canAddCollection && !item.isFullyPaid && !item.isCancelled) ...[
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddCollectionScreen(
                              initialUserId: item.target.userId,
                              initialChandaTargetId: item.target.id,
                              initialDonorName: item.target.personName,
                              initialMobileNumber: item.target.mobileNumber,
                              initialAmount: item.remainingAmount,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add Payment', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnassignedMemberTile(BuildContext context, AppUser member, bool canManageTargets) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimaryLight),
                ),
                Text(
                  '${member.role.displayName} • Target Not Assigned',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (canManageTargets) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(0, 32),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditChandaTargetScreen(preselectedUserId: member.uid),
                  ),
                );
              },
              child: const Text('Assign Target', style: TextStyle(fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardMetric(String label, int amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
        const SizedBox(height: 2),
        Text(
          MoneyFormatter.format(amount),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
