import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/report_provider.dart';
import '../data/report_models.dart';

class ProfitLossScreen extends ConsumerWidget {
  const ProfitLossScreen({super.key});

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final current = ref.read(profitLossRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: current.from, end: current.to),
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ref.read(profitLossRangeProvider.notifier).state = DateRange(from: picked.start, to: picked.end);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(profitLossRangeProvider);
    final reportAsync = ref.watch(profitLossProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Profit & Loss'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () => _pickRange(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text('${DateFormat('dd MMM').format(range.from)} - ${DateFormat('dd MMM yyyy').format(range.to)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Icon(Icons.edit, size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: reportAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (report) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: report.netProfit >= 0 ? [AppColors.gradientStart, AppColors.gradientEnd] : [AppColors.danger, const Color(0xFFFF8A80)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report.netProfit >= 0 ? 'Net Profit' : 'Net Loss', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(report.netProfit.abs().toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionCard('Revenue', report.revenues, report.totalRevenue, AppColors.iconGreen),
                  const SizedBox(height: 16),
                  _sectionCard('Expenses', report.expenses, report.totalExpense, AppColors.iconOrange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, List<ProfitLossRow> rows, double total, Color accentColor) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: accentColor)),
                Text(total.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: accentColor)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (rows.isEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('No entries', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)))
          else
            ...rows.map((r) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text('${r.accountCode}  ${r.accountName}', style: const TextStyle(fontSize: 12))),
                  Text(r.amount.toStringAsFixed(2), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}