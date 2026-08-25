import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/nexa_text_field.dart';
import '../../expense/presentation/widgets/vendor_picker_field.dart';
import '../../parties/data/party_models.dart';
import '../application/vendorbill_provider.dart';
import '../data/vendorbill_models.dart';
import 'widgets/vendorbill_budget_warning_banner.dart';
import 'widgets/vendorbill_item_editor.dart';

class CreateVendorBillScreen extends ConsumerStatefulWidget {
  const CreateVendorBillScreen({super.key});

  @override
  ConsumerState<CreateVendorBillScreen> createState() => _CreateVendorBillScreenState();
}

class _CreateVendorBillScreenState extends ConsumerState<CreateVendorBillScreen> {
  DateTime _date = DateTime.now();
  PartyModel? _vendor;
  VendorBillType _billType = VendorBillType.expense;
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<VendorBillItemDraft> _items = [VendorBillItemDraft()];
  bool _isSubmitting = false;
  List<BudgetWarning> _warnings = [];

  double get _subTotal => _items.fold(0.0, (s, d) => s + d.toItem().computedSubTotal);
  double get _discountTotal => _items.fold(0.0, (s, d) => s + d.toItem().computedDiscountAmount);
  double get _vatTotal => _items.fold(0.0, (s, d) => s + d.toItem().computedVatAmount);
  double get _tdsTotal => _items.fold(0.0, (s, d) => s + d.toItem().computedTdsAmount);
  double get _netPayable => _items.fold(0.0, (s, d) => s + d.toItem().computedLineTotal);

  void _addItem() => setState(() => _items.add(VendorBillItemDraft()));
  void _removeItem(int index) {
    if (_items.length <= 1) return;
    _items[index].dispose();
    setState(() => _items.removeAt(index));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (_vendor == null) {
      _showError('Select Vendor');
      return;
    }
    for (final d in _items) {
      if (d.expenseAccount == null) {
        _showError('Select Expense Account in Every line');
        return;
      }
      if (d.descCtrl.text.trim().isEmpty) {
        _showError('Must be Write description in every line');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final request = VendorBillRequest(
      partyId: _vendor!.id,
      billDate: _date,
      vendorBillRef: _refCtrl.text.trim(),
      billType: _billType,
      notes: _notesCtrl.text.trim(),
      items: _items.map((d) => d.toItem()).toList(),
    );

    final result = await ref.read(vendorBillActionsProvider.notifier).create(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result != null) {
        if (result.budgetWarnings.isEmpty) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vendor bill Crated (Draft)')));
        } else {
          setState(() => _warnings = result.budgetWarnings);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill Created Successfully but budget over')));
        }
      } else {
        _showError('Try Again');
      }
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));

  @override
  void dispose() {
    _refCtrl.dispose();
    _notesCtrl.dispose();
    for (final d in _items) {
      d.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('New Vendor Bill'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
        children: [
          VendorBillBudgetWarningBanner(warnings: _warnings),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Bill Date', prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(DateFormat('dd MMM yyyy').format(_date)),
                  ),
                ),
                const SizedBox(height: 14),
                VendorPickerField(selected: _vendor, onSelected: (v) => setState(() => _vendor = v)),
                const SizedBox(height: 14),
                DropdownButtonFormField<VendorBillType>(
                  initialValue: _billType,
                  decoration: InputDecoration(labelText: 'Bill Type', prefixIcon: const Icon(Icons.category_outlined, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: VendorBillType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                  onChanged: (v) => setState(() => _billType = v ?? VendorBillType.expense),
                ),
                const SizedBox(height: 14),
                NexaTextField(controller: _refCtrl, label: 'Vendor Bill Ref (optional)', hint: 'Vendor\'s own invoice no...', icon: Icons.confirmation_number_outlined),
                const SizedBox(height: 14),
                NexaTextField(controller: _notesCtrl, label: 'Notes (optional)', hint: 'Additional notes...', icon: Icons.notes),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              TextButton.icon(onPressed: _addItem, icon: const Icon(Icons.add, size: 16), label: const Text('Add Item')),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_items.length, (index) {
            return VendorBillItemEditorCard(
              draft: _items[index],
              onRemove: _items.length > 1 ? () => _removeItem(index) : null,
              onChanged: () => setState(() {}),
            );
          }),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.chipOrange, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                _totalRow('Sub Total', _subTotal),
                _totalRow('Discount', -_discountTotal),
                _totalRow('VAT', _vatTotal),
                _totalRow('TDS', -_tdsTotal),
                const Divider(),
                _totalRow('Net Payable', _netPayable, isBold: true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save as Draft', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 14 : 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value.toStringAsFixed(2), style: TextStyle(fontSize: isBold ? 15 : 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}