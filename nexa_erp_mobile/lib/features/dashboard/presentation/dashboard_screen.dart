import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/application/auth_provider.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../application/dashboard_provider.dart';
import '../data/dashboard_models.dart';
import 'widgets/cash_hero_card.dart';
import 'widgets/budget_donut_card.dart';
import 'widgets/expense_progress_card.dart';
import 'widgets/recent_activity_list.dart';
import 'widgets/quick_actions_row.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final workflowAsync = ref.watch(dashboardWorkflowProvider);
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Load problem: $e')),
          data: (summary) {
            final pendingApprovals = workflowAsync.valueOrNull?.myPendingCount ?? 0;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardSummaryProvider);
                ref.invalidate(dashboardWorkflowProvider);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                        onPressed: () => context.push('/more'),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Greetings, ${user?.name ?? ''}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                const Text('👋', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            const Text('Hello! Welcome Back To System',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const NotificationBell(),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        offset: const Offset(0, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onSelected: (value) {
                          if (value == 'logout') {
                            ref.read(authProvider.notifier).logout();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            enabled: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(user?.email ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 18, color: AppColors.danger),
                                SizedBox(width: 10),
                                Text('Logout', style: TextStyle(color: AppColors.danger)),
                              ],
                            ),
                          ),
                        ],
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.chipBlue,
                          child: Text(
                            (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Workflow / pending approval banner (approval enabled থাকলেই দেখাবে)
                  _WorkflowCard(workflowAsync: workflowAsync),

                  // Cash hero card
                  CashHeroCard(
                    currencyCode: summary.business.currencyCode ?? 'BDT',
                    cashPosition: summary.business.cashPosition,
                    receivable: summary.business.accountsReceivable,
                    payable: summary.business.accountsPayable,
                    overdueInvoiceCount: summary.business.overdueInvoiceCount,
                    overdueBillCount: summary.business.overdueBillCount,
                  ),
                  const SizedBox(height: 16),

                  // Stat grid
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.78,
                    children: [
                      StatTile(
                        icon: Icons.groups,
                        iconColor: AppColors.iconBlue,
                        chipColor: AppColors.chipBlue,
                        value: '${summary.finance.totalAccounts}',
                        label: 'Accounts',
                        onTap: () => context.push('/accounts'),
                      ),
                      StatTile(
                        icon: Icons.description,
                        iconColor: AppColors.iconGreen,
                        chipColor: AppColors.chipGreen,
                        value: '${summary.finance.totalJournalEntries}',
                        label: 'Journal Entries',
                        onTap: () => context.push('/journals'),
                      ),
                      StatTile(
                        icon: Icons.pending_actions,
                        iconColor: AppColors.iconOrange,
                        chipColor: AppColors.chipOrange,
                        value: '$pendingApprovals',
                        label: 'Pending Approvals',
                        onTap: () => context.push('/approvals'),
                      ),
                      StatTile(
                        icon: Icons.person,
                        iconColor: AppColors.iconPurple,
                        chipColor: AppColors.chipPurple,
                        value: '${summary.users.active}',
                        label: 'Active Users',
                        onTap: () => context.push('/more'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Expense/Budget + Donut side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: ExpenseProgressCard(expense: summary.expense, budget: summary.budget)),
                      const SizedBox(width: 12),
                      Expanded(child: BudgetDonutCard(budget: summary.budget)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  RecentActivityList(activities: summary.recentActivities),
                  const SizedBox(height: 16),

                  QuickActionsRow(actions: [
                    QuickAction(
                      icon: Icons.add,
                      color: AppColors.iconBlue,
                      bgColor: AppColors.chipBlue,
                      label: 'Add Account',
                      onTap: () => context.push('/accounts'),
                    ),
                    QuickAction(
                      icon: Icons.receipt_long,
                      color: AppColors.iconGreen,
                      bgColor: AppColors.chipGreen,
                      label: 'New Invoice',
                      onTap: () => context.push('/invoices'),
                    ),
                    QuickAction(
                      icon: Icons.account_balance_wallet,
                      color: AppColors.iconOrange,
                      bgColor: AppColors.chipOrange,
                      label: 'Receive Payment',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment module works')),
                      ),
                    ),
                    QuickAction(
                      icon: Icons.swap_horiz,
                      color: AppColors.iconPurple,
                      bgColor: AppColors.chipPurple,
                      label: 'Make Payment',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment module works')),
                      ),

                    ),
                  ]),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WorkflowCard extends ConsumerWidget {
  final AsyncValue<DashboardWorkflowSummary> workflowAsync;
  const _WorkflowCard({required this.workflowAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return workflowAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (w) {
        if (!w.approvalEnabled) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => context.push('/approvals'),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.chipBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pending_actions, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Waiting for Approve: ${w.myPendingCount}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        if (w.myReturnedCount > 0)
                          Text('Returned: ${w.myReturnedCount}',
                              style: const TextStyle(color: AppColors.danger, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}