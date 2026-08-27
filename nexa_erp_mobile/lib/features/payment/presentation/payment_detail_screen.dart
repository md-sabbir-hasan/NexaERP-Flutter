import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/payment_provider.dart';
import '../data/payment_models.dart';
import 'widgets/payment_status_style.dart';

class PaymentDetailScreen extends ConsumerWidget {
  final PaymentModel payment;
  const PaymentDetailScreen({super.key, required this.payment});

  Future<void> _confirmAndRun(BuildContext context, WidgetRef ref, String title, String msg, Future<bool> Function() action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await action();
    if (context.mounted) {
      if (ok) context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Success' : 'Problem')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(payment.paymentNumber), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
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
                    Row(
                      children: [
                        Icon(PaymentStatusStyle.typeIcon(payment.paymentType), size: 16, color: PaymentStatusStyle.typeColor(payment.paymentType)),
                        const SizedBox(width: 6),
                        Text(payment.paymentType.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PaymentStatusStyle.typeColor(payment.paymentType))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: PaymentStatusStyle.chipColor(payment.status), borderRadius: BorderRadius.circular(20)),
                      child: Text(payment.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PaymentStatusStyle.color(payment.status))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(payment.partyName ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${payment.currencyCode ?? ''} ${payment.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 4),
                Text(DateFormat('dd MMM yyyy').format(payment.paymentDate), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _row('Account', payment.accountName ?? ''),
                _row('Method', payment.paymentMethod.label),
                if (payment.transactionRef != null && payment.transactionRef!.isNotEmpty) _row('Reference', payment.transactionRef!),
                _row('Allocated', payment.allocatedAmount.toStringAsFixed(2)),
                _row('Unallocated', payment.unallocatedAmount.toStringAsFixed(2)),
              ],
            ),
          ),
          if (payment.allocations.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Allocations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: payment.allocations.map((a) => ListTile(
                  dense: true,
                  title: Text('${a.referenceType} #${a.referenceId}', style: const TextStyle(fontSize: 12)),
                  trailing: Text(a.allocatedAmount.toStringAsFixed(2), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )).toList(),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (payment.status == PaymentStatus.draft) ...[
            if (payment.approvalFeatureEnabled)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmAndRun(context, ref, 'Submit for Approval', 'Send this payment for approval?', () => ref.read(paymentActionsProvider.notifier).submitApproval(payment.id)),
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Submit for Approval'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.iconPurple),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmAndRun(context, ref, 'Post Payment', 'Posting this payment will update the account balance. Are you sure?', () => ref.read(paymentActionsProvider.notifier).post(payment.id)),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Post Payment'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _confirmAndRun(context, ref, 'Cancel Payment', 'Do You Want to cancel payment?', () => ref.read(paymentActionsProvider.notifier).cancel(payment.id)),
                icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
                label: const Text('Cancel Payment', style: TextStyle(color: AppColors.danger)),
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