import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/report_provider.dart';
import '../data/report_models.dart';

class BalanceSheetScreen extends ConsumerWidget {
  const BalanceSheetScreen({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final current = ref.read(balanceSheetDateProvider);
    final picked = await showDatePicker(context: context, initialDate: current, firstDate: DateTime(2015), lastDate: DateTime(2100));
    if (picked != null) ref.read(balanceSheetDateProvider.notifier).state = picked;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(balanceSheetDateProvider);
    final reportAsync = ref.watch(balanceSheetProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Balance Sheet'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () => _pickDate(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text('As of ${DateFormat('dd MMM yyyy').format(date)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: report.isBalanced ? AppColors.chipGreen : const Color(0xFFFFE1E1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(report.isBalanced ? Icons.check_circle : Icons.warning, color: report.isBalanced ? AppColors.success : AppColors.danger, size: 18),
                        const SizedBox(width: 10),
                        Text(report.isBalanced ? 'Balanced' : 'Not Balanced', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: report.isBalanced ? AppColors.success : AppColors.danger)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _section('Assets', report.assets, report.totalAssets, AppColors.iconBlue),
                  const SizedBox(height: 16),
                  _section('Liabilities', report.liabilities, report.totalLiabilities, AppColors.danger),
                  const SizedBox(height: 16),
                  _section('Equity', report.equity, report.totalEquityExcludingProfit, AppColors.iconPurple, extraRow: MapEntry('Net Profit (current period)', report.netProfit)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _totalRow('Total Assets', report.totalAssets),
                        _totalRow('Total Liabilities + Equity', report.totalLiabilitiesAndEquity),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<BalanceSheetRow> rows, double total, Color color, {MapEntry<String, double>? extraRow}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                Text(total.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
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
          if (extraRow != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(extraRow.key, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic))),
                  Text(extraRow.value.toStringAsFixed(2), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}