import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../accounts/data/account_models.dart';
import '../../journal/presentation/widgets/account_picker_sheet.dart';
import '../application/report_provider.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  Future<void> _pickAccount() async {
    final account = await showAccountPickerSheet(context, title: 'Select Account for Ledger');
    if (account == null) return;

    final params = ref.read(ledgerParamsProvider);
    final now = DateTime.now();
    ref.read(ledgerParamsProvider.notifier).state = LedgerParams(
      account: account,
      from: params?.from ?? DateTime(now.year, now.month, 1),
      to: params?.to ?? now,
    );
  }

  Future<void> _pickRange() async {
    final params = ref.read(ledgerParamsProvider);
    if (params == null) return;
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: params.from, end: params.to),
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ref.read(ledgerParamsProvider.notifier).state = LedgerParams(account: params.account, from: picked.start, to: picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(ledgerParamsProvider);
    final reportAsync = ref.watch(ledgerReportProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Ledger'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                InkWell(
                  onTap: _pickAccount,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            params != null ? '${params.account.code} - ${params.account.name}' : 'Select an account',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: params != null ? AppColors.textPrimary : AppColors.textSecondary),
                          ),
                        ),
                        const Icon(Icons.edit, size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                if (params != null) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range, size: 16, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text('${DateFormat('dd MMM').format(params.from)} - ${DateFormat('dd MMM yyyy').format(params.to)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          const Icon(Icons.edit, size: 14, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (params == null)
            const Expanded(child: Center(child: Text('Select an account to view its ledger', style: TextStyle(color: AppColors.textSecondary))))
          else
            Expanded(
              child: reportAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (report) {
                  if (report == null) return const SizedBox.shrink();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Opening Balance', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  Text(report.openingBalance.toStringAsFixed(2), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Closing Balance', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  Text(report.closingBalance.toStringAsFixed(2), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (report.entries.isEmpty)
                        const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No transactions in this period', style: TextStyle(color: AppColors.textSecondary))))
                      else
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: report.entries.map((e) => Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e.journalEntryNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      Text(DateFormat('dd MMM yyyy').format(e.date), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  if (e.description != null && e.description!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(e.description!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (e.debit > 0) Text('Dr ${e.debit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.iconBlue, fontWeight: FontWeight.w600)),
                                      if (e.credit > 0) Text('Cr ${e.credit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.iconOrange, fontWeight: FontWeight.w600)),
                                      Text('Bal: ${e.runningBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}