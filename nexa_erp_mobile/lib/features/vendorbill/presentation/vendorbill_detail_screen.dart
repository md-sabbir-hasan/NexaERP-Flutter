import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/vendorbill_provider.dart';
import '../data/vendorbill_models.dart';
import 'widgets/vendorbill_status_style.dart';

class VendorBillDetailScreen extends ConsumerWidget {
  final VendorBillModel bill;
  const VendorBillDetailScreen({super.key, required this.bill});

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Successful' : 'problem')));
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    VendorBillCancelledReason selectedReason = VendorBillCancelledReason.vendorRequested;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Cancel Vendor Bill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: VendorBillCancelledReason.values.map((r) => RadioListTile<VendorBillCancelledReason>(
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
              child: const Text('Cancel Bill'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final ok = await ref.read(vendorBillActionsProvider.notifier).cancel(bill.id, selectedReason);
    if (context.mounted) {
      if (ok) context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Cancel' : 'Problem')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(bill.billNumber), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
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
                      decoration: BoxDecoration(color: VendorBillStatusStyle.chipColor(bill.status), borderRadius: BorderRadius.circular(20)),
                      child: Text(bill.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VendorBillStatusStyle.color(bill.status))),
                    ),
                    Text(DateFormat('dd MMM yyyy').format(bill.billDate), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(bill.partyName ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${bill.currencyCode ?? ''} ${bill.netPayable.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                if (bill.dueAmount > 0) ...[
                  const SizedBox(height: 4),
                  Text('Due: ${bill.dueAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _row('Sub Total', bill.subTotal.toStringAsFixed(2)),
                _row('Discount', bill.discountAmount.toStringAsFixed(2)),
                _row('VAT', bill.vatAmount.toStringAsFixed(2)),
                _row('TDS', bill.tdsAmount.toStringAsFixed(2)),
                const Divider(),
                _row('Net Payable', bill.netPayable.toStringAsFixed(2), isBold: true),
                _row('Paid', bill.paidAmount.toStringAsFixed(2)),
                _row('Due', bill.dueAmount.toStringAsFixed(2)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (bill.status == VendorBillStatus.draft) ...[
            if (bill.approvalFeatureEnabled)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmAndRun(context, ref, 'Submit for Approval', 'Do You Want to Send it for Approval?', () => ref.read(vendorBillActionsProvider.notifier).submitApproval(bill.id)),
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
                  onPressed: () => _confirmAndRun(context, ref, 'Approve Bill', 'Do You want to Approve this Bill?', () => ref.read(vendorBillActionsProvider.notifier).approve(bill.id)),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.iconPurple),
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _cancel(context, ref),
                icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
                label: const Text('Cancel Bill', style: TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
          if (bill.status == VendorBillStatus.approved)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _confirmAndRun(context, ref, 'Post Bill', 'Posting this bill will update the accounts payable. Are you sure?', () => ref.read(vendorBillActionsProvider.notifier).post(bill.id)),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Post Bill'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              ),
            ),
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