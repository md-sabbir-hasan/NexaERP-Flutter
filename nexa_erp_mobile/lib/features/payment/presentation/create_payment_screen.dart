import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/nexa_text_field.dart';
import '../../accounts/data/account_models.dart';
import '../../expense/presentation/widgets/vendor_picker_field.dart';
import '../../invoice/presentation/widgets/customer_picker_field.dart';
import '../../journal/presentation/widgets/account_picker_sheet.dart';
import '../../parties/data/party_models.dart';
import '../application/payment_provider.dart';
import '../data/payment_models.dart';
import 'widgets/allocation_picker.dart';

class CreatePaymentScreen extends ConsumerStatefulWidget {
  final PaymentType initialType;
  const CreatePaymentScreen({super.key, this.initialType = PaymentType.receipt});

  @override
  ConsumerState<CreatePaymentScreen> createState() => _CreatePaymentScreenState();
}

class _CreatePaymentScreenState extends ConsumerState<CreatePaymentScreen> {
  late PaymentType _type;
  DateTime _date = DateTime.now();
  PartyModel? _party;
  AccountModel? _account;
  PaymentMethod _method = PaymentMethod.cash;
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _autoAllocate = true;
  bool _isSubmitting = false;
  List<AllocationDraft> _allocationDrafts = [];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    for (final d in _allocationDrafts) {
      d.dispose();
    }
    super.dispose();
  }

  double get _selectedAllocationTotal =>
      _allocationDrafts.where((d) => d.selected).fold(0.0, (s, d) => s + d.amount);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickAccount() async {
    final account = await showAccountPickerSheet(context, cashEquivalentOnly: true, title: 'Select Cash/Bank Account');
    if (account != null) setState(() => _account = account);
  }

  void _onPartySelected(PartyModel party) {
    setState(() {
      _party = party;
      for (final d in _allocationDrafts) {
        d.dispose();
      }
      _allocationDrafts = [];
    });
    _loadOutstanding();
  }

  void _loadOutstanding() {
    if (_party == null) return;
    if (_type == PaymentType.receipt) {
      final invoicesAsync = ref.read(outstandingInvoicesForPartyProvider(_party!.id));
      invoicesAsync.whenData((list) {
        setState(() {
          _allocationDrafts = list
              .map((i) => AllocationDraft(referenceId: i.id, documentNumber: i.invoiceNumber, maxDue: i.dueAmount, referenceType: PaymentReferenceType.invoice))
              .toList();
        });
      });
    } else {
      final billsAsync = ref.read(outstandingBillsForPartyProvider(_party!.id));
      billsAsync.whenData((list) {
        setState(() {
          _allocationDrafts = list
              .map((b) => AllocationDraft(referenceId: b.id, documentNumber: b.billNumber, maxDue: b.dueAmount, referenceType: PaymentReferenceType.vendorBill))
              .toList();
        });
      });
    }
  }

  Future<void> _submit() async {
    if (_party == null) {
      _showError('${_type == PaymentType.receipt ? "Customer" : "Vendor"} Select');
      return;
    }
    if (_account == null) {
      _showError('Select Cash/Bank account');
      return;
    }
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0) {
      _showError('Enter Correct amount');
      return;
    }
    if (!_autoAllocate) {
      final selected = _allocationDrafts.where((d) => d.selected).toList();
      if (selected.isEmpty) {
        _showError('Select at least one document, or turn on Auto Allocate');
        return;
      }
      if ((_selectedAllocationTotal - amount).abs() > 0.01) {
        _showError('The total amount must equal the allocation');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final request = PaymentRequest(
      partyId: _party!.id,
      accountId: _account!.id,
      paymentDate: _date,
      paymentType: _type,
      amount: amount,
      paymentMethod: _method,
      transactionRef: _refCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      autoAllocate: _autoAllocate,
      allocations: _autoAllocate
          ? null
          : _allocationDrafts
          .where((d) => d.selected)
          .map((d) => PaymentAllocationRequest(referenceType: d.referenceType, referenceId: d.referenceId, allocatedAmount: d.amount))
          .toList(),
    );

    final result = await ref.read(paymentActionsProvider.notifier).create(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result != null) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Created (Draft)')));
      } else {
        _showError('An error occurred, please try again');
      }
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(_type.label), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Receive (from Customer)'),
                  selected: _type == PaymentType.receipt,
                  selectedColor: AppColors.success,
                  labelStyle: TextStyle(fontSize: 11, color: _type == PaymentType.receipt ? Colors.white : AppColors.textPrimary),
                  onSelected: (_) => setState(() {
                    _type = PaymentType.receipt;
                    _party = null;
                    _allocationDrafts = [];
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Pay (to Vendor)'),
                  selected: _type == PaymentType.payment,
                  selectedColor: AppColors.iconOrange,
                  labelStyle: TextStyle(fontSize: 11, color: _type == PaymentType.payment ? Colors.white : AppColors.textPrimary),
                  onSelected: (_) => setState(() {
                    _type = PaymentType.payment;
                    _party = null;
                    _allocationDrafts = [];
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Date', prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(DateFormat('dd MMM yyyy').format(_date)),
                  ),
                ),
                const SizedBox(height: 14),
                _type == PaymentType.receipt
                    ? CustomerPickerField(selected: _party, onSelected: _onPartySelected)
                    : VendorPickerField(selected: _party, onSelected: _onPartySelected),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickAccount,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Cash/Bank Account', prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(
                      _account != null ? '${_account!.code} - ${_account!.name}' : 'Select account',
                      style: TextStyle(fontSize: 13, color: _account != null ? AppColors.textPrimary : AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                NexaTextField(
                  controller: _amountCtrl,
                  label: 'Amount',
                  hint: '0.00',
                  icon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (v == null || double.tryParse(v) == null || double.parse(v) <= 0) ? 'Enter Correct amount' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<PaymentMethod>(
                  initialValue: _method,
                  decoration: InputDecoration(labelText: 'Payment Method', prefixIcon: const Icon(Icons.payment, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: PaymentMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(),
                  onChanged: (v) => setState(() => _method = v ?? PaymentMethod.cash),
                ),
                const SizedBox(height: 14),
                NexaTextField(controller: _refCtrl, label: 'Transaction Ref (optional)', hint: 'Cheque no / TXN id...', icon: Icons.confirmation_number_outlined),
                const SizedBox(height: 14),
                NexaTextField(controller: _notesCtrl, label: 'Notes (optional)', hint: 'Additional notes...', icon: Icons.notes),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _autoAllocate,
                  activeColor: AppColors.primary,
                  title: const Text('Auto Allocate (FIFO)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('It will automatically apply starting from the oldest due document', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  onChanged: (v) => setState(() => _autoAllocate = v),
                ),
                if (!_autoAllocate) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  if (_party == null)
                    const Text('Select Party First', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
                  else ...[
                    const Text('Select documents to pay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    AllocationPickerList(drafts: _allocationDrafts, onChanged: () => setState(() {})),
                    const SizedBox(height: 8),
                    Text('Selected total: ${_selectedAllocationTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ],
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
                : const Text('Save Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}