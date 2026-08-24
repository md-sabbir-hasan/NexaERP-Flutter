import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/invoice_provider.dart';
import '../data/invoice_models.dart';
import 'create_invoice_screen.dart';
import 'invoice_detail_screen.dart';
import 'widgets/invoice_status_style.dart';

class InvoiceListScreen extends ConsumerWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(filteredInvoiceListProvider);
    final statusFilter = ref.watch(invoiceStatusFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Invoices'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateInvoiceScreen())),
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
                ...InvoiceStatus.values.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip(ref, s.label, statusFilter == s, s),
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
                  return const Center(child: Text('Not find any Invoice', style: TextStyle(color: AppColors.textSecondary)));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(invoiceListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final inv = list[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoice: inv))),
                          title: Row(
                            children: [
                              Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: InvoiceStatusStyle.chipColor(inv.status), borderRadius: BorderRadius.circular(20)),
                                child: Text(inv.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: InvoiceStatusStyle.color(inv.status))),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${inv.partyName ?? ''} · ${DateFormat('dd MMM yyyy').format(inv.invoiceDate)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(inv.grandTotal.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _chip(WidgetRef ref, String label, bool selected, InvoiceStatus? status) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary)),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => ref.read(invoiceStatusFilterProvider.notifier).state = status,
    );
  }
}