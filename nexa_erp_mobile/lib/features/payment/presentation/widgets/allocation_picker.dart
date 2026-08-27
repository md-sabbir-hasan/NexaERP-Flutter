import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/payment_models.dart';

class AllocationDraft {
  final int referenceId;
  final String documentNumber;
  final double maxDue;
  final PaymentReferenceType referenceType;
  bool selected;
  final controller = TextEditingController();

  AllocationDraft({
    required this.referenceId,
    required this.documentNumber,
    required this.maxDue,
    required this.referenceType,
    this.selected = false,
  }) {
    controller.text = maxDue.toStringAsFixed(2);
  }

  double get amount => double.tryParse(controller.text) ?? 0;

  void dispose() => controller.dispose();
}

class AllocationPickerList extends StatefulWidget {
  final List<AllocationDraft> drafts;
  final VoidCallback onChanged;

  const AllocationPickerList({super.key, required this.drafts, required this.onChanged});

  @override
  State<AllocationPickerList> createState() => _AllocationPickerListState();
}

class _AllocationPickerListState extends State<AllocationPickerList> {
  @override
  Widget build(BuildContext context) {
    if (widget.drafts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('This party has no outstanding due', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      );
    }

    return Column(
      children: widget.drafts.map((d) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Checkbox(
                value: d.selected,
                activeColor: AppColors.primary,
                onChanged: (v) {
                  setState(() => d.selected = v ?? false);
                  widget.onChanged();
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.documentNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Due: ${d.maxDue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: d.controller,
                  enabled: d.selected,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => widget.onChanged(),
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}