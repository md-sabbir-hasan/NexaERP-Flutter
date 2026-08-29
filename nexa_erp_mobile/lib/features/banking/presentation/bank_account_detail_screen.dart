import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/bank_provider.dart';
import '../data/bank_models.dart';
import 'widgets/bank_account_form_sheet.dart';
import 'widgets/bank_account_style.dart';
import 'widgets/bank_transaction_form_sheet.dart';
import 'widgets/bank_transfer_form_sheet.dart';

class BankAccountDetailScreen extends ConsumerWidget {
  final BankAccountModel account;
  const BankAccountDetailScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(bankTransactionsProvider(account.id));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(account.accountName),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => showBankAccountFormSheet(context, existing: account),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => showBankTransactionFormSheet(context, account.id),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(bankTransactionsProvider(account.id)),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: BankAccountStyle.chipColor(account.accountType), borderRadius: BorderRadius.circular(10)),
                        child: Icon(BankAccountStyle.icon(account.accountType), color: BankAccountStyle.color(account.accountType), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(account.accountType.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            if (account.accountNumber != null && account.accountNumber!.isNotEmpty)
                              Text(account.accountNumber!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Current Balance', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text(account.currentBalance.toStringAsFixed(2), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showBankTransferFormSheet(context),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Transfer to another account'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('No transactions yet', style: TextStyle(color: AppColors.textSecondary))),
                  );
                }
                return Column(
                  children: list.map((t) => _TransactionTile(transaction: t, accountId: account.id)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  final BankTransactionModel transaction;
  final int accountId;
  const _TransactionTile({required this.transaction, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCredit = transaction.transactionType == TransactionType.credit;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: () => _showActionSheet(context, ref),
        leading: CircleAvatar(
          backgroundColor: (isCredit ? AppColors.success : AppColors.danger).withOpacity(0.15),
          child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, size: 16, color: isCredit ? AppColors.success : AppColors.danger),
        ),
        title: Text(transaction.description?.isNotEmpty == true ? transaction.description! : transaction.transactionNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Text(DateFormat('dd MMM yyyy').format(transaction.transactionDate), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            if (transaction.reconciled) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle, size: 12, color: AppColors.success),
            ],
            if (transaction.voided) ...[
              const SizedBox(width: 6),
              const Text('VOIDED', style: TextStyle(fontSize: 9, color: AppColors.danger, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isCredit ? AppColors.success : AppColors.danger),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context, WidgetRef ref) {
    if (transaction.voided) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(transaction.reconciled ? Icons.link_off : Icons.link, color: AppColors.primary),
              title: Text(transaction.reconciled ? 'Mark as Unreconciled' : 'Mark as Reconciled'),
              onTap: () async {
                Navigator.pop(context);
                final notifier = ref.read(bankTransactionActionsProvider.notifier);
                final ok = transaction.reconciled
                    ? await notifier.unreconcile(transaction.id, accountId)
                    : await notifier.reconcile(transaction.id, accountId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Updated successfully' : 'Something went wrong')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.danger),
              title: const Text('Void Transaction', style: TextStyle(color: AppColors.danger)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Void Transaction'),
                    content: const Text('This will reverse the transaction. Are you sure?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.danger), onPressed: () => Navigator.pop(context, true), child: const Text('Void')),
                    ],
                  ),
                );
                if (confirmed == true) {
                  final ok = await ref.read(bankTransactionActionsProvider.notifier).voidTransaction(transaction.id, accountId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Transaction voided' : 'Something went wrong')));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}