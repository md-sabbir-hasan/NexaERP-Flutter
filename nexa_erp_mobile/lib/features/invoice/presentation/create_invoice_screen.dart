import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/nexa_text_field.dart';
import '../../parties/data/party_models.dart';
import '../application/invoice_provider.dart';
import '../data/invoice_models.dart';
import 'widgets/customer_picker_field.dart';
import 'widgets/invoice_item_editor.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  DateTime _date = DateTime.now();
  PartyModel? _customer;
  final _referenceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<InvoiceItemDraft> _items = [InvoiceItemDraft()];
  bool _isSubmitting = false;

  double get _subTotal => _items.fold(0.0, (sum, d) => sum + d.toItem().computedSubTotal);
  double get _discountTotal => _items.fold(0.0, (sum, d) => sum + d.toItem().computedDiscountAmount);
  double get _vatTotal => _items.fold(0.0, (sum, d) => sum + d.toItem().computedVatAmount);
  double get _grandTotal => _items.fold(0.0, (sum, d) => sum + d.toItem().computedLineTotal);

  void _addItem() => setState(() => _items.add(InvoiceItemDraft()));

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
    if (_customer == null) {
      _showError('Select Customer');
      return;
    }
    for (final d in _items) {
      if (d.descCtrl.text.trim().isEmpty) {
        _showError('Enter description in every line');
        return;
      }
      final item = d.toItem();
      if (item.quantity <= 0 || item.unitPrice < 0) {
        _showError('Enter Right quantity/price ');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final request = InvoiceRequest(
      partyId: _customer!.id,
      invoiceDate: _date,
      reference: _referenceCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      items: _items.map((d) => d.toItem()).toList(),
    );

    final result = await ref.read(invoiceActionsProvider.notifier).create(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result != null) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice has been created (Draft)')));
      } else {
        _showError('There was a problem, please try again.');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));
  }

  @override
  void dispose() {
    _referenceCtrl.dispose();
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
      appBar: AppBar(title: const Text('New Invoice'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Invoice Date',
                      prefixIcon: const Icon(Icons.calendar_today, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(DateFormat('dd MMM yyyy').format(_date)),
                  ),
                ),
                const SizedBox(height: 14),
                CustomerPickerField(selected: _customer, onSelected: (c) => setState(() => _customer = c)),
                const SizedBox(height: 14),
                NexaTextField(controller: _referenceCtrl, label: 'Reference (optional)', hint: 'PO number...', icon: Icons.confirmation_number_outlined),
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
            return InvoiceItemEditorCard(
              draft: _items[index],
              onRemove: _items.length > 1 ? () => _removeItem(index) : null,
              onChanged: () => setState(() {}),
            );
          }),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.chipBlue, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                _totalRow('Sub Total', _subTotal),
                _totalRow('Discount', -_discountTotal),
                _totalRow('VAT', _vatTotal),
                const Divider(),
                _totalRow('Grand Total', _grandTotal, isBold: true),
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