import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../accounts/data/account_models.dart';
import '../../../journal/presentation/widgets/account_picker_sheet.dart';
import '../../data/vendorbill_models.dart';

class VendorBillItemDraft {
  AccountModel? expenseAccount;
  final descCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController(text: '0');
  final discountCtrl = TextEditingController(text: '0');
  final vatCtrl = TextEditingController(text: '0');
  final tdsCtrl = TextEditingController(text: '0');

  VendorBillItem toItem() => VendorBillItem(
    expenseAccountId: expenseAccount?.id ?? 0,
    description: descCtrl.text.trim(),
    quantity: double.tryParse(qtyCtrl.text) ?? 0,
    unitPrice: double.tryParse(priceCtrl.text) ?? 0,
    discountPercent: double.tryParse(discountCtrl.text) ?? 0,
    vatRate: double.tryParse(vatCtrl.text) ?? 0,
    tdsRate: double.tryParse(tdsCtrl.text) ?? 0,
  );

  void dispose() {
    descCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
    discountCtrl.dispose();
    vatCtrl.dispose();
    tdsCtrl.dispose();
  }
}

class VendorBillItemEditorCard extends StatefulWidget {
  final VendorBillItemDraft draft;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const VendorBillItemEditorCard({super.key, required this.draft, this.onRemove, required this.onChanged});

  @override
  State<VendorBillItemEditorCard> createState() => _VendorBillItemEditorCardState();
}

class _VendorBillItemEditorCardState extends State<VendorBillItemEditorCard> {
  Future<void> _pickExpenseAccount() async {
    final account = await showAccountPickerSheet(context, filterType: AccountType.expense, title: 'Select Expense Account');
    if (account != null) {
      setState(() => widget.draft.expenseAccount = account);
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.draft.toItem();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickExpenseAccount,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Expense Account', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text(
                      widget.draft.expenseAccount != null ? '${widget.draft.expenseAccount!.code} - ${widget.draft.expenseAccount!.name}' : 'Select account',
                      style: TextStyle(fontSize: 12, color: widget.draft.expenseAccount != null ? AppColors.textPrimary : AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              if (widget.onRemove != null)
                IconButton(icon: const Icon(Icons.close, size: 18, color: AppColors.danger), onPressed: widget.onRemove),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.draft.descCtrl,
            onChanged: (_) => setState(widget.onChanged),
            decoration: InputDecoration(labelText: 'Description', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TextField(controller: widget.draft.qtyCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(widget.onChanged), decoration: InputDecoration(labelText: 'Qty', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: widget.draft.priceCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(widget.onChanged), decoration: InputDecoration(labelText: 'Unit Price', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: widget.draft.discountCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(widget.onChanged), decoration: InputDecoration(labelText: 'Disc %', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
              const SizedBox(width: 6),
              Expanded(child: TextField(controller: widget.draft.vatCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(widget.onChanged), decoration: InputDecoration(labelText: 'VAT %', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
              const SizedBox(width: 6),
              Expanded(child: TextField(controller: widget.draft.tdsCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(widget.onChanged), decoration: InputDecoration(labelText: 'TDS %', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Line Total: ${item.computedLineTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}