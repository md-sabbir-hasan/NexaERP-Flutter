import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/debitnote_provider.dart';
import 'create_debitnote_screen.dart';
import 'debitnote_detail_screen.dart';
import 'widgets/debitnote_status_style.dart';

class DebitNoteListScreen extends ConsumerWidget {
  const DebitNoteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(debitNoteListProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Debit Notes'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateDebitNoteScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No debit note found', style: TextStyle(color: AppColors.textSecondary)));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(debitNoteListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final n = list[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DebitNoteDetailScreen(note: n))),
                    title: Row(
                      children: [
                        Text(n.debitNoteNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: DebitNoteStatusStyle.chipColor(n.status), borderRadius: BorderRadius.circular(20)),
                          child: Text(n.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: DebitNoteStatusStyle.color(n.status))),
                        ),
                      ],
                    ),
                    subtitle: Text('${n.partyName ?? ''} · Against ${n.vendorBillNumber ?? ''}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(n.netAdjustment.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}