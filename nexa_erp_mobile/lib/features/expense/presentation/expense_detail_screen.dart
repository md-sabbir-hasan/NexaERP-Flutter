import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/expense_provider.dart';
import '../data/expense_models.dart';
import 'widgets/expense_status_style.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final ExpenseModel expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  Future<void> _post(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Post Expense'),
        content: const Text('Are you sure you want to post this expense? Your account balance will be updated.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Post')),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await ref.read(expenseActionsProvider.notifier).post(expense.id);
    if (context.mounted) {
      if (ok) context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Posted successfully' : 'Something went wrong')));
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Expense'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonCtrl,
            maxLines: 3,
            decoration: InputDecoration(hintText: 'Enter Reason for Cancel', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter Reason' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Back')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context, true);
            },
            child: const Text('Cancel Expense'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await ref.read(expenseActionsProvider.notifier).cancel(expense.id, reasonCtrl.text.trim());
    if (context.mounted) {
      if (ok) context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Cancel' : 'Made Problem')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(expense.expenseNumber), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: ExpenseStatusStyle.chipColor(expense.status), borderRadius: BorderRadius.circular(20)),
                      child: Text(expense.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ExpenseStatusStyle.color(expense.status))),
                    ),
                    Text(DateFormat('dd MMM yyyy').format(expense.expenseDate), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 14),
                Text('${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 4),
                Text(expense.expenseAccountName ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _row('Payment Method', expense.paidImmediately ? 'Paid Immediately' : 'Pay Later'),
                if (expense.paymentAccountName != null) _row('Payment Account', expense.paymentAccountName!),
                if (expense.partyName != null) _row('Vendor', expense.partyName!),
                _row('Payment Status', expense.paymentStatus.label),
                _row('Paid Amount', expense.paidAmount.toStringAsFixed(2)),
                _row('Due Amount', expense.dueAmount.toStringAsFixed(2)),
                if (expense.referenceNumber != null && expense.referenceNumber!.isNotEmpty) _row('Reference', expense.referenceNumber!),
                if (expense.notes != null && expense.notes!.isNotEmpty) _row('Notes', expense.notes!),
                if (expense.status == ExpenseStatus.cancelled && expense.cancelReason != null)
                  _row('Cancel Reason', expense.cancelReason!),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (expense.status == ExpenseStatus.draft) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _post(context, ref),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Post Expense'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _cancel(context, ref),
                icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
                label: const Text('Cancel Expense', style: TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}