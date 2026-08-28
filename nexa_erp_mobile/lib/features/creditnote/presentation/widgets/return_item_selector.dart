import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class ReturnItemDraft {
  final int sourceItemId;
  final String description;
  final double maxQuantity;
  final double unitPrice;
  bool selected;
  final qtyCtrl = TextEditingController();

  ReturnItemDraft({
    required this.sourceItemId,
    required this.description,
    required this.maxQuantity,
    required this.unitPrice,
    this.selected = false,
  }) {
    qtyCtrl.text = maxQuantity.toStringAsFixed(2);
  }

  double get quantity => double.tryParse(qtyCtrl.text) ?? 0;
  double get lineEstimate => quantity * unitPrice;

  void dispose() => qtyCtrl.dispose();
}

class ReturnItemSelectorList extends StatefulWidget {
  final List<ReturnItemDraft> drafts;
  final VoidCallback onChanged;

  const ReturnItemSelectorList({super.key, required this.drafts, required this.onChanged});

  @override
  State<ReturnItemSelectorList> createState() => _ReturnItemSelectorListState();
}

class _ReturnItemSelectorListState extends State<ReturnItemSelectorList> {
  @override
  Widget build(BuildContext context) {
    if (widget.drafts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('এই document এর কোনো item পাওয়া যায়নি', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      );
    }

    return Column(
      children: widget.drafts.map((d) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                    child: Text(d.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              if (d.selected)
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: d.qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => widget.onChanged(),
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Qty (max ${d.maxQuantity.toStringAsFixed(2)})',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('~ ${d.lineEstimate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}