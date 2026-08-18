import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_provider.dart';
import '../application/dashboard_provider.dart';
import '../data/dashboard_models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final workflowAsync = ref.watch(dashboardWorkflowProvider);
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text('হ্যালো, ${user?.name ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(dashboardWorkflowProvider);
        },
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 100),
              Center(child: Text('Load করতে সমস্যা হয়েছে: $e')),
            ],
          ),
          data: (summary) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _WorkflowCard(workflowAsync: workflowAsync),
              const SizedBox(height: 16),
              _CashCard(business: summary.business),
              const SizedBox(height: 16),
              _StatRow(finance: summary.finance, users: summary.users),
              const SizedBox(height: 16),
              _ExpenseBudgetCard(expense: summary.expense, budget: summary.budget),
              const SizedBox(height: 16),
              _RecentActivitiesCard(activities: summary.recentActivities),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  final AsyncValue<DashboardWorkflowSummary> workflowAsync;
  const _WorkflowCard({required this.workflowAsync});

  @override
  Widget build(BuildContext context) {
    return workflowAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (w) {
        if (!w.approvalEnabled) return const SizedBox.shrink();
        return Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.pending_actions),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('আপনার approve করার জন্য অপেক্ষমাণ: ${w.myPendingCount}'),
                      if (w.myReturnedCount > 0)
                        Text('Returned: ${w.myReturnedCount}', style: const TextStyle(color: Colors.orange)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CashCard extends StatelessWidget {
  final BusinessSummary business;
  const _CashCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cash Position', style: Theme.of(context).textTheme.labelLarge),
            Text(
              '${business.currencyCode ?? ''} ${business.cashPosition.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Receivable',
                    value: business.accountsReceivable,
                    overdue: business.overdueInvoiceCount,
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: 'Payable',
                    value: business.accountsPayable,
                    overdue: business.overdueBillCount,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final int overdue;
  const _MiniStat({required this.label, required this.value, required this.overdue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value.toStringAsFixed(2), style: Theme.of(context).textTheme.titleMedium),
        if (overdue > 0)
          Text('$overdue overdue', style: const TextStyle(color: Colors.red, fontSize: 12)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final FinanceSummary finance;
  final UserSummary users;
  const _StatRow({required this.finance, required this.users});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatTile(label: 'Accounts', value: '${finance.totalAccounts}', icon: Icons.account_balance)),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(label: 'Journal Entries', value: '${finance.totalJournalEntries}', icon: Icons.book)),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(label: 'Active Users', value: '${users.active}', icon: Icons.people)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ExpenseBudgetCard extends StatelessWidget {
  final ExpenseDashboard expense;
  final BudgetDashboard budget;
  const _ExpenseBudgetCard({required this.expense, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expense & Budget', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text('Draft expense: ${expense.draftCount} (${expense.draftTotalAmount.toStringAsFixed(2)})'),
            Text('This month posted: ${expense.postedThisMonthTotal.toStringAsFixed(2)}'),
            if (budget.hasActiveBudget) ...[
              const SizedBox(height: 8),
              Text('Budget: ${budget.activeBudgetName}'),
              LinearProgressIndicator(
                value: (budget.expenseUtilizationPercent / 100).clamp(0, 1),
                color: budget.expenseUtilizationPercent > 90 ? Colors.red : null,
              ),
              Text('${budget.expenseUtilizationPercent.toStringAsFixed(1)}% utilized'),
            ] else if (budget.unavailableReason != null)
              Text(budget.unavailableReason!, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitiesCard extends StatelessWidget {
  final List<RecentActivity> activities;
  const _RecentActivitiesCard({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activities', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ...activities.take(5).map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${a.action ?? ''} · ${a.entityName ?? ''} — ${a.userName ?? ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}