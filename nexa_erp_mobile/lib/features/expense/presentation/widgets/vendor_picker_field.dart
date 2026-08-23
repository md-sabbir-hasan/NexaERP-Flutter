import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../application/expense_provider.dart';
import '../../../parties/data/party_models.dart';

class VendorPickerField extends ConsumerWidget {
  final PartyModel? selected;
  final void Function(PartyModel) onSelected;

  const VendorPickerField({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(vendorListProvider);

    return InkWell(
      onTap: () async {
        final vendors = vendorsAsync.valueOrNull ?? [];
        if (vendors.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কোনো vendor পাওয়া যায়নি')));
          return;
        }
        final result = await showModalBottomSheet<PartyModel>(
          context: context,
          builder: (_) => ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shrinkWrap: true,
            children: vendors.map((v) => ListTile(
              title: Text(v.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text(v.code, style: const TextStyle(fontSize: 11)),
              onTap: () => Navigator.pop(context, v),
            )).toList(),
          ),
        );
        if (result != null) onSelected(result);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Vendor / Party',
          prefixIcon: const Icon(Icons.store_outlined, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          selected?.name ?? 'Select vendor...',
          style: TextStyle(fontSize: 13, color: selected != null ? AppColors.textPrimary : AppColors.textSecondary),
        ),
      ),
    );
  }
}