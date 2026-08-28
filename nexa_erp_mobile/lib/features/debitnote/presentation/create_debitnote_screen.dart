import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/nexa_text_field.dart';
import '../../creditnote/presentation/widgets/return_item_selector.dart';
import '../../vendorbill/data/vendorbill_models.dart';
import '../application/debitnote_provider.dart';
import '../data/debitnote_models.dart';

class CreateDebitNoteScreen extends ConsumerStatefulWidget {
  const CreateDebitNoteScreen({super.key});

  @override
  ConsumerState<CreateDebitNoteScreen> createState() => _CreateDebitNoteScreenState();
}

class _CreateDebitNoteScreenState extends ConsumerState<CreateDebitNoteScreen> {
  VendorBillModel? _bill;
  DateTime _date = DateTime.now();
  DebitNoteReason _reason = DebitNoteReason.salesReturn;
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  List<ReturnItemDraft> _itemDrafts = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _refCtrl.dispose();
    _notesCtrl.dispose();
    for (final d in _itemDrafts) {
      d.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickBill() async {
    final billsAsync = ref.read(postedVendorBillsProvider);
    final bills = billsAsync.valueOrNull ?? [];
    if (bills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No posted vendor bill found.')));
      return;
    }
    final result = await showModalBottomSheet<VendorBillModel>(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shrinkWrap: true,
        children: bills.map((b) => ListTile(
          title: Text(b.billNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: Text('${b.partyName ?? ''} · ${b.netPayable.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
          onTap: () => Navigator.pop(context, b),
        )).toList(),
      ),
    );
    if (result != null) {
      setState(() {
        _bill = result;
        for (final d in _itemDrafts) {
          d.dispose();
        }
        _itemDrafts = result.items
            .map((item) => ReturnItemDraft(
          sourceItemId: item.id!,
          description: item.description,
          maxQuantity: item.quantity,
          unitPrice: item.unitPrice,
        ))
            .toList();
      });
    }
  }

  Future<void> _submit() async {
    if (_bill == null) {
      _showError('Please select a vendor bill first');
      return;
    }
    final selected = _itemDrafts.where((d) => d.selected).toList();
    if (selected.isEmpty) {
      _showError('Please select at least one item.');
      return;
    }
    for (final d in selected) {
      if (d.quantity <= 0 || d.quantity > d.maxQuantity) {
        _showError('${d.description} Please enter a valid quantity (max ${d.maxQuantity})');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final request = DebitNoteRequest(
      vendorBillId: _bill!.id,
      debitNoteDate: _date,
      reason: _reason,
      reference: _refCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      items: selected.map((d) => DebitNoteItemRequest(vendorBillItemId: d.sourceItemId, quantity: d.quantity)).toList(),
    );

    final result = await ref.read(debitNoteActionsProvider.notifier).create(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result != null) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debit note created (Draft)')));
      } else {
        _showError('Something went wrong. Please try again.');
      }
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('New Debit Note'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                InkWell(
                  onTap: _pickBill,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Vendor Bill', prefixIcon: const Icon(Icons.receipt_outlined, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(
                      _bill != null ? '${_bill!.billNumber} - ${_bill!.partyName ?? ''}' : 'Select vendor bill',
                      style: TextStyle(fontSize: 13, color: _bill != null ? AppColors.textPrimary : AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Debit Note Date', prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(DateFormat('dd MMM yyyy').format(_date)),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<DebitNoteReason>(
                  initialValue: _reason,
                  decoration: InputDecoration(labelText: 'Reason', prefixIcon: const Icon(Icons.info_outline, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: DebitNoteReason.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                  onChanged: (v) => setState(() => _reason = v ?? DebitNoteReason.salesReturn),
                ),
                const SizedBox(height: 14),
                NexaTextField(controller: _refCtrl, label: 'Reference (optional)', hint: 'Return slip no...', icon: Icons.confirmation_number_outlined),
                const SizedBox(height: 14),
                NexaTextField(controller: _notesCtrl, label: 'Notes (optional)', hint: 'Additional notes...', icon: Icons.notes),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_bill != null) ...[
            const Text('Select Items to Debit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ReturnItemSelectorList(drafts: _itemDrafts, onChanged: () => setState(() {})),
            ),
          ],
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
}