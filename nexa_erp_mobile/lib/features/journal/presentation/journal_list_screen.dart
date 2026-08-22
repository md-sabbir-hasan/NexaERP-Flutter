import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/journal_provider.dart';
import '../data/journal_models.dart';
import 'create_journal_screen.dart';
import 'journal_detail_screen.dart';
import 'widgets/journal_status_style.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(filteredJournalListProvider);
    final statusFilter = ref.watch(journalStatusFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Journal Entries'),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateJournalScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('All', statusFilter == null, () => ref.read(journalStatusFilterProvider.notifier).state = null),
                const SizedBox(width: 8),
                ...JournalStatus.values.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip(s.label, statusFilter == s, () => ref.read(journalStatusFilterProvider.notifier).state = s),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('কোনো journal entry পাওয়া যায়নি', style: TextStyle(color: AppColors.textSecondary)));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(journalListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final entry = list[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => JournalDetailScreen(entry: entry)),
                          ),
                          title: Row(
                            children: [
                              Text(entry.entryNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: JournalStatusStyle.chipColor(entry.status), borderRadius: BorderRadius.circular(20)),
                                child: Text(entry.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: JournalStatusStyle.color(entry.status))),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${DateFormat('dd MMM yyyy').format(entry.date)} · ${entry.description ?? entry.type.label}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(entry.totalAmount.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary)),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => onTap(),
    );
  }
}