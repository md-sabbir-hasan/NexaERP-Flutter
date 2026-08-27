import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/payment_provider.dart';
import '../data/payment_models.dart';
import 'create_payment_screen.dart';
import 'payment_detail_screen.dart';
import 'widgets/payment_status_style.dart';

class PaymentListScreen extends ConsumerWidget {
  const PaymentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(filteredPaymentListProvider);
    final typeFilter = ref.watch(paymentTypeFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Payments'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showTypePicker(context),
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
                _chip(ref, 'All', typeFilter == null, null),
                const SizedBox(width: 8),
                _chip(ref, 'Receipts', typeFilter == PaymentType.receipt, PaymentType.receipt),
                const SizedBox(width: 8),
                _chip(ref, 'Payments', typeFilter == PaymentType.payment, PaymentType.payment),
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
                  return const Center(child: Text('No payment found', style: TextStyle(color: AppColors.textSecondary)));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(paymentListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final p = list[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentDetailScreen(payment: p))),
                          leading: CircleAvatar(
                            backgroundColor: PaymentStatusStyle.typeColor(p.paymentType).withOpacity(0.15),
                            child: Icon(PaymentStatusStyle.typeIcon(p.paymentType), size: 16, color: PaymentStatusStyle.typeColor(p.paymentType)),
                          ),
                          title: Row(
                            children: [
                              Text(p.paymentNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: PaymentStatusStyle.chipColor(p.status), borderRadius: BorderRadius.circular(20)),
                                child: Text(p.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: PaymentStatusStyle.color(p.status))),
                              ),
                            ],
                          ),
                          subtitle: Text('${p.partyName ?? ''} · ${DateFormat('dd MMM yyyy').format(p.paymentDate)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Text(p.amount.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  void _showTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_downward, color: AppColors.iconGreen),
              title: const Text('Receive Payment (from Customer)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreatePaymentScreen(initialType: PaymentType.receipt)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: AppColors.iconOrange),
              title: const Text('Make Payment (to Vendor)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreatePaymentScreen(initialType: PaymentType.payment)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(WidgetRef ref, String label, bool selected, PaymentType? type) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary)),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => ref.read(paymentTypeFilterProvider.notifier).state = type,
    );
  }
}