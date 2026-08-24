import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../application/invoice_provider.dart';
import '../../../parties/data/party_models.dart';

class CustomerPickerField extends ConsumerWidget {
  final PartyModel? selected;
  final void Function(PartyModel) onSelected;

  const CustomerPickerField({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customerListProvider);

    return InkWell(
      onTap: () async {
        final customers = customersAsync.valueOrNull ?? [];
        if (customers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কোনো customer পাওয়া যায়নি')));
          return;
        }
        final result = await showModalBottomSheet<PartyModel>(
          context: context,
          builder: (_) => ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shrinkWrap: true,
            children: customers.map((c) => ListTile(
              title: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(c.code, style: const TextStyle(fontSize: 11)),
              onTap: () => Navigator.pop(context, c),
            )).toList(),
          ),
        );
        if (result != null) onSelected(result);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Customer',
          prefixIcon: const Icon(Icons.person_outline, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          selected?.name ?? 'Select customer...',
          style: TextStyle(fontSize: 13, color: selected != null ? AppColors.textPrimary : AppColors.textSecondary),
        ),
      ),
    );
  }
}