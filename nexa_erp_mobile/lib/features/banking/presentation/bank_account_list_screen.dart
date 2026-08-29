import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../application/bank_provider.dart';
import '../data/bank_models.dart';
import 'bank_account_detail_screen.dart';
import 'widgets/bank_account_form_sheet.dart';
import 'widgets/bank_account_style.dart';

class BankAccountListScreen extends ConsumerWidget {
  const BankAccountListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(bankAccountListProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Bank Accounts'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => showBankAccountFormSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No bank accounts found', style: TextStyle(color: AppColors.textSecondary)));
          }
          final totalBalance = accounts.where((a) => a.isActive).fold(0.0, (s, a) => s + a.currentBalance);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(bankAccountListProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [AppColors.gradientStart, AppColors.gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(totalBalance.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...accounts.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BankAccountDetailScreen(account: a))),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: BankAccountStyle.chipColor(a.accountType), borderRadius: BorderRadius.circular(10)),
                      child: Icon(BankAccountStyle.icon(a.accountType), color: BankAccountStyle.color(a.accountType), size: 18),
                    ),
                    title: Text(a.accountName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: a.isActive ? AppColors.textPrimary : AppColors.textSecondary)),
                    subtitle: Text(a.accountType.label + (a.bankName != null ? ' · ${a.bankName}' : ''), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    trailing: Text(a.currentBalance.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}