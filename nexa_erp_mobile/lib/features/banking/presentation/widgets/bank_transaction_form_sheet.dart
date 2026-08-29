import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/nexa_text_field.dart';
import '../../../accounts/data/account_models.dart';
import '../../../journal/presentation/widgets/account_picker_sheet.dart';
import '../../application/bank_provider.dart';
import '../../data/bank_models.dart';

Future<void> showBankTransactionFormSheet(BuildContext context, int bankAccountId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _BankTransactionFormSheet(bankAccountId: bankAccountId),
    ),
  );
}

class _BankTransactionFormSheet extends ConsumerStatefulWidget {
  final int bankAccountId;
  const _BankTransactionFormSheet({required this.bankAccountId});

  @override
  ConsumerState<_BankTransactionFormSheet> createState() => _BankTransactionFormSheetState();
}

class _BankTransactionFormSheetState extends ConsumerState<_BankTransactionFormSheet> {
  TransactionType _type = TransactionType.credit;
  DateTime _date = DateTime.now();
  AccountModel? _contraAccount;
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickContraAccount() async {
    final account = await showAccountPickerSheet(context, title: 'Select Contra Account');
    if (account != null) setState(() => _contraAccount = account);
  }

  Future<void> _submit() async {
    if (_contraAccount == null) {
      _showError('Please select a contra account');
      return;
    }
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    setState(() => _isSubmitting = true);

    final request = BankTransactionRequest(
      bankAccountId: widget.bankAccountId,
      transactionDate: _date,
      transactionType: _type,
      amount: amount,
      description: _descCtrl.text.trim(),
      referenceNumber: _refCtrl.text.trim(),
      contraAccountId: _contraAccount!.id,
    );

    final ok = await ref.read(bankTransactionActionsProvider.notifier).create(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction added successfully')));
      } else {
        _showError('Something went wrong, please try again');
      }
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            const Text('New Transaction', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Money In'),
                    selected: _type == TransactionType.credit,
                    selectedColor: AppColors.success,
                    labelStyle: TextStyle(fontSize: 12, color: _type == TransactionType.credit ? Colors.white : AppColors.textPrimary),
                    onSelected: (_) => setState(() => _type = TransactionType.credit),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Money Out'),
                    selected: _type == TransactionType.debit,
                    selectedColor: AppColors.danger,
                    labelStyle: TextStyle(fontSize: 12, color: _type == TransactionType.debit ? Colors.white : AppColors.textPrimary),
                    onSelected: (_) => setState(() => _type = TransactionType.debit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: 'Date', prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(DateFormat('dd MMM yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 14),
            NexaTextField(
              controller: _amountCtrl,
              label: 'Amount',
              hint: '0.00',
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickContraAccount,
              child: InputDecorator(
                decoration: InputDecoration(labelText: 'Contra Account', prefixIcon: const Icon(Icons.swap_horiz, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(
                  _contraAccount != null ? '${_contraAccount!.code} - ${_contraAccount!.name}' : 'Select the other side account',
                  style: TextStyle(fontSize: 13, color: _contraAccount != null ? AppColors.textPrimary : AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 14),
            NexaTextField(controller: _descCtrl, label: 'Description (optional)', hint: 'Transaction note...', icon: Icons.notes),
            const SizedBox(height: 14),
            NexaTextField(controller: _refCtrl, label: 'Reference (optional)', hint: 'Cheque/TXN no...', icon: Icons.confirmation_number_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Add Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}