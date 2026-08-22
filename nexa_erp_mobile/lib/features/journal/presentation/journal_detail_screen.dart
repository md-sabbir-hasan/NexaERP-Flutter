import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/journal_provider.dart';
import '../data/journal_models.dart';
import 'widgets/journal_status_style.dart';

class JournalDetailScreen extends ConsumerWidget {
  final JournalEntry entry;
  const JournalDetailScreen({super.key, required this.entry});

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'সফল হয়েছে' : 'সমস্যা হয়েছে')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(entry.entryNumber),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
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
                      decoration: BoxDecoration(color: JournalStatusStyle.chipColor(entry.status), borderRadius: BorderRadius.circular(20)),
                      child: Text(entry.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: JournalStatusStyle.color(entry.status))),
                    ),
                    Text(DateFormat('dd MMM yyyy').format(entry.date), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                if (entry.description != null && entry.description!.isNotEmpty)
                  Text(entry.description!, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Text('Total: ${entry.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Lines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: entry.lines.map((l) {
                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${l.accountCode} - ${l.accountName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            if (l.description != null && l.description!.isNotEmpty)
                              Text(l.description!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (l.debit > 0) Text('Dr ${l.debit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.iconBlue, fontWeight: FontWeight.w600)),
                          if (l.credit > 0) Text('Cr ${l.credit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.iconOrange, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          if (entry.status == JournalStatus.draft) ...[
            if (entry.approvalEnabled)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmAndRun(
                    context, ref, 'Submit for Approval', 'এই entry approval এর জন্য পাঠাতে চাও?',
                        () => ref.read(journalActionsProvider.notifier).submitApproval(entry.id),
                  ),
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
                  onPressed: () => _confirmAndRun(
                    context, ref, 'Post Journal Entry', 'এই entry post করলে আর edit করা যাবে না। নিশ্চিত?',
                        () => ref.read(journalActionsProvider.notifier).post(entry.id),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Post Entry'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _confirmAndRun(
                  context, ref, 'Delete Draft', 'এই draft entry ডিলিট করতে চাও?',
                      () => ref.read(journalActionsProvider.notifier).delete(entry.id),
                ),
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                label: const Text('Delete Draft', style: TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
          if (entry.status == JournalStatus.posted)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _confirmAndRun(
                  context, ref, 'Reverse Entry', 'এই posted entry reverse করলে নতুন একটা reversing entry তৈরি হবে। নিশ্চিত?',
                      () => ref.read(journalActionsProvider.notifier).reverse(entry.id),
                ),
                icon: const Icon(Icons.undo, size: 18, color: AppColors.danger),
                label: const Text('Reverse Entry', style: TextStyle(color: AppColors.danger)),
              ),
            ),
        ],
      ),
    );
  }
}