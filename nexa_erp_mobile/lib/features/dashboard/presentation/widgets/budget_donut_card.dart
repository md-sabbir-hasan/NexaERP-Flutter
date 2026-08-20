import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nexa_erp_mobile/features/dashboard/data/dashboard_models.dart';

import '../../../../app/theme/app_colors.dart';

class BudgetDonutCard extends StatelessWidget {
  final BudgetDashboard budget;
  const BudgetDonutCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    if (!budget.hasActiveBudget) {
      return _emptyState(budget.unavailableReason ?? 'কোনো active budget নেই');
    }

    final expensePct = budget.expenseUtilizationPercent.clamp(0, 100).toDouble();
    final remainingPct = (100 - expensePct).clamp(0, 100).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budget Utilization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Icon(Icons.more_horiz, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 4),
          Text(budget.activeBudgetName ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 46,
                    sections: [
                      PieChartSectionData(
                        value: expensePct,
                        color: AppColors.iconBlue,
                        showTitle: false,
                        radius: 22,
                      ),
                      PieChartSectionData(
                        value: remainingPct,
                        color: AppColors.chipBlue,
                        showTitle: false,
                        radius: 22,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${expensePct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Used', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _legendRow('Expense Budget', budget.totalExpenseBudget, AppColors.iconBlue),
          const SizedBox(height: 8),
          _legendRow('Actual Spent', budget.totalExpenseActualYtd, AppColors.iconOrange),
        ],
      ),
    );
  }

  Widget _legendRow(String label, double value, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Text('৳ ${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _emptyState(String reason) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          const Icon(Icons.pie_chart_outline, color: AppColors.textSecondary, size: 32),
          const SizedBox(height: 8),
          Text(reason, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}