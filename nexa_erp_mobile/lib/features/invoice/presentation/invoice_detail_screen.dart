import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/invoice_provider.dart';
import '../data/invoice_models.dart';
import 'widgets/invoice_status_style.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final InvoiceModel invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  Future<void> _post(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Post Invoice'),
        content: const Text('Posting this invoice will update the accounts receivable ledger. Yes, that is correct.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Post')),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ref.read(invoiceActionsProvider.notifier).post(invoice.id);
    if (context.mounted) {
      if (ok) context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Posted Done' : 'Something Went Wrong')));
    }
  }

  Future<void> _submitApproval(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit for Approval'),
        content: const Text('Would you like to send this invoice for approval?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ref.read(invoiceActionsProvider.notifier).submitApproval(invoice.id);
    if (context.mounted) {
      if (ok) context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Submitted' : 'Failed')));
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    CancelledReason selectedReason = CancelledReason.customerRequested;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Cancel Invoice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: CancelledReason.values.map((r) => RadioListTile<CancelledReason>(
              value: r,
              groupValue: selectedReason,
              title: Text(r.label, style: const TextStyle(fontSize: 13)),
              onChanged: (v) => setState(() => selectedReason = v!),
            )).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Back')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cancel Invoice'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final ok = await ref.read(invoiceActionsProvider.notifier).cancel(invoice.id, selectedReason);
    if (context.mounted) {
      if (ok) context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Cancel হয়েছে' : 'সমস্যা হয়েছে')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(invoice.invoiceNumber), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
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
                      decoration: BoxDecoration(color: InvoiceStatusStyle.chipColor(invoice.status), borderRadius: BorderRadius.circular(20)),
                      child: Text(invoice.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: InvoiceStatusStyle.color(invoice.status))),
                    ),
                    Text(DateFormat('dd MMM yyyy').format(invoice.invoiceDate), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(invoice.partyName ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${invoice.currencyCode ?? ''} ${invoice.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                if (invoice.dueAmount > 0) ...[
                  const SizedBox(height: 4),
                  Text('Due: ${invoice.dueAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: invoice.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} · Disc ${item.discountPercent}% · VAT ${item.vatRate}%', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Align(alignment: Alignment.centerRight, child: Text('${item.lineTotal?.toStringAsFixed(2) ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _row('Sub Total', invoice.subTotal.toStringAsFixed(2)),
                _row('Discount', invoice.discountAmount.toStringAsFixed(2)),
                _row('VAT', invoice.vatAmount.toStringAsFixed(2)),
                const Divider(),
                _row('Grand Total', invoice.grandTotal.toStringAsFixed(2), isBold: true),
                _row('Paid', invoice.paidAmount.toStringAsFixed(2)),
                _row('Due', invoice.dueAmount.toStringAsFixed(2)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (invoice.status == InvoiceStatus.draft) ...[
            if (invoice.approvalFeatureEnabled)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _submitApproval(context, ref),
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
                  onPressed: () => _post(context, ref),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Post Invoice'),
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
                label: const Text('Cancel Invoice', style: TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 13 : 12, color: isBold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isBold ? 14 : 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}