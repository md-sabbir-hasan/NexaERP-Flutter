import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/expense_provider.dart';
import '../data/expense_models.dart';
import 'create_expense_screen.dart';
import 'expense_detail_screen.dart';
import 'widgets/expense_status_style.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(filteredExpenseListProvider);
    final statusFilter = ref.watch(expenseStatusFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Expenses'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateExpenseScreen())),
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
                _chip(context, ref, 'All', statusFilter == null, null),
                const SizedBox(width: 8),
                ...ExpenseStatus.values.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip(context, ref, s.label, statusFilter == s, s),
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
                  return const Center(child: Text('কোনো expense পাওয়া যায়নি', style: TextStyle(color: AppColors.textSecondary)));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(expenseListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final e = list[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExpenseDetailScreen(expense: e))),
                          title: Row(
                            children: [
                              Text(e.expenseNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: ExpenseStatusStyle.chipColor(e.status), borderRadius: BorderRadius.circular(20)),
                                child: Text(e.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ExpenseStatusStyle.color(e.status))),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${DateFormat('dd MMM yyyy').format(e.expenseDate)} · ${e.expenseAccountName ?? ''}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(e.amount.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _chip(BuildContext context, WidgetRef ref, String label, bool selected, ExpenseStatus? status) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary)),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => ref.read(expenseStatusFilterProvider.notifier).state = status,
    );
  }
}