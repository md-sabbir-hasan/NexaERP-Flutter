import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/report_provider.dart';

class TrialBalanceScreen extends ConsumerWidget {
  const TrialBalanceScreen({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final current = ref.read(trialBalanceDateProvider);
    final picked = await showDatePicker(context: context, initialDate: current, firstDate: DateTime(2015), lastDate: DateTime(2100));
    if (picked != null) ref.read(trialBalanceDateProvider.notifier).state = picked;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(trialBalanceDateProvider);
    final reportAsync = ref.watch(trialBalanceProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Trial Balance'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: report.isBalanced ? AppColors.chipGreen : const Color(0xFFFFE1E1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(report.isBalanced ? Icons.check_circle : Icons.warning, color: report.isBalanced ? AppColors.success : AppColors.danger, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          report.isBalanced ? 'Balanced' : 'Not Balanced',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: report.isBalanced ? AppColors.success : AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                          child: const Row(
                            children: [
                              Expanded(flex: 3, child: Text('Account', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                              Expanded(flex: 2, child: Text('Debit', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                              Expanded(flex: 2, child: Text('Credit', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary))),
                            ],
                          ),
                        ),
                        ...report.rows.map((row) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(row.accountName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text(row.accountCode, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Expanded(flex: 2, child: Text(row.debitBalance > 0 ? row.debitBalance.toStringAsFixed(2) : '-', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                              Expanded(flex: 2, child: Text(row.creditBalance > 0 ? row.creditBalance.toStringAsFixed(2) : '-', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        )),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Expanded(flex: 3, child: Text('Total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text(report.totalDebit.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text(report.totalCredit.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
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
}