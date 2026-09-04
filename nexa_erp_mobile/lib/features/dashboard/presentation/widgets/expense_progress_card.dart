import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/dashboard_models.dart';

class ExpenseProgressCard extends StatelessWidget {
  final ExpenseDashboard expense;
  final BudgetDashboard budget;

  const ExpenseProgressCard({super.key, required this.expense, required this.budget});

  @override
  Widget build(BuildContext context) {
    final usedPct = budget.hasActiveBudget ? budget.expenseUtilizationPercent.clamp(0, 100) / 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Expense & Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          _row('This Month Posted', expense.postedThisMonthTotal),
          const SizedBox(height: 8),
          _row('Budget', budget.totalExpenseBudget),
          const SizedBox(height: 8),
          _row('Used', null, percentText: '${(usedPct * 100).toStringAsFixed(1)}%'),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usedPct,
              minHeight: 8,
              backgroundColor: AppColors.chipBlue,
              color: usedPct > 0.9 ? AppColors.danger : AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bar_chart, size: 18),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.chipBlue),
                backgroundColor: AppColors.chipBlue.withOpacity(0.4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double? value, {String? percentText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Flexible(
          child: Text(
            percentText ?? '৳ ${value?.toStringAsFixed(2) ?? '0.00'}',
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}