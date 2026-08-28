import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/creditnote_provider.dart';
import '../data/creditnote_models.dart';
import 'widgets/creditnote_status_style.dart';

class CreditNoteDetailScreen extends ConsumerWidget {
  final CreditNoteModel note;
  const CreditNoteDetailScreen({super.key, required this.note});

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Success' : 'Error')));
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    CreditNoteCancelledReason selectedReason = CreditNoteCancelledReason.duplicate;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Cancel Credit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: CreditNoteCancelledReason.values.map((r) => RadioListTile<CreditNoteCancelledReason>(
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
              child: const Text('Cancel Note'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final ok = await ref.read(creditNoteActionsProvider.notifier).cancel(note.id, selectedReason);
    if (context.mounted) {
      if (ok) context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Cancel' : 'Error')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(note.creditNoteNumber), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
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
                      decoration: BoxDecoration(color: CreditNoteStatusStyle.chipColor(note.status), borderRadius: BorderRadius.circular(20)),
                      child: Text(note.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CreditNoteStatusStyle.color(note.status))),
                    ),
                    Text(DateFormat('dd MMM yyyy').format(note.creditNoteDate), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(note.partyName ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Against: ${note.invoiceNumber ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text(note.grandTotal.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 4),
                Text(note.reason.label, style: const TextStyle(fontSize: 12, color: AppColors.iconPurple, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: note.items.map((item) => Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.description ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('${item.quantity} × ${item.unitPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(item.lineTotal.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),
          if (note.status == CreditNoteStatus.draft) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _confirmAndRun(context, ref, 'Approve Note', 'Are you sure you want to approve this credit note?', () => ref.read(creditNoteActionsProvider.notifier).approve(note.id)),
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
                label: const Text('Cancel Note', style: TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
          if (note.status == CreditNoteStatus.approved)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _confirmAndRun(context, ref, 'Post Note', 'Posting this credit note will decrease the receivable amount. Are you sure?', () => ref.read(creditNoteActionsProvider.notifier).post(note.id)),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Post Note'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              ),
            ),
        ],
      ),
    );
  }
}