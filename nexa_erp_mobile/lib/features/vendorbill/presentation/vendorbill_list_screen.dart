import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/vendorbill_provider.dart';
import '../data/vendorbill_models.dart';
import 'create_vendorbill_screen.dart';
import 'vendorbill_detail_screen.dart';
import 'widgets/vendorbill_status_style.dart';

class VendorBillListScreen extends ConsumerWidget {
  const VendorBillListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(filteredVendorBillListProvider);
    final statusFilter = ref.watch(vendorBillStatusFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Vendor Bills'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateVendorBillScreen())),
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
                _chip(ref, 'All', statusFilter == null, null),
                const SizedBox(width: 8),
                ...VendorBillStatus.values.map((s) => Padding(padding: const EdgeInsets.only(right: 8), child: _chip(ref, s.label, statusFilter == s, s))),
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
                  return const Center(child: Text('vendor bill Not Found', style: TextStyle(color: AppColors.textSecondary)));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(vendorBillListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final b = list[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VendorBillDetailScreen(bill: b))),
                          title: Row(
                            children: [
                              Text(b.billNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: VendorBillStatusStyle.chipColor(b.status), borderRadius: BorderRadius.circular(20)),
                                child: Text(b.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: VendorBillStatusStyle.color(b.status))),
                              ),
                            ],
                          ),
                          subtitle: Text('${b.partyName ?? ''} · ${DateFormat('dd MMM yyyy').format(b.billDate)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Text(b.netPayable.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _chip(WidgetRef ref, String label, bool selected, VendorBillStatus? status) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary)),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => ref.read(vendorBillStatusFilterProvider.notifier).state = status,
    );
  }
}