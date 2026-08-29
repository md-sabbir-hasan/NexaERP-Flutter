import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/nexa_text_field.dart';
import '../../application/bank_provider.dart';
import '../../data/bank_models.dart';

Future<void> showBankTransferFormSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const Padding(
      padding: EdgeInsets.zero,
      child: _BankTransferFormSheet(),
    ),
  );
}

class _BankTransferFormSheet extends ConsumerStatefulWidget {
  const _BankTransferFormSheet();

  @override
  ConsumerState<_BankTransferFormSheet> createState() => _BankTransferFormSheetState();
}

class _BankTransferFormSheetState extends ConsumerState<_BankTransferFormSheet> {
  DateTime _date = DateTime.now();
  BankAccountModel? _fromAccount;
  BankAccountModel? _toAccount;
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _date = picked);
  }

  Future<BankAccountModel?> _pickAccount(List<BankAccountModel> accounts) {
    return showModalBottomSheet<BankAccountModel>(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shrinkWrap: true,
        children: accounts.map((a) => ListTile(
          title: Text(a.accountName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: Text(a.currentBalance.toStringAsFixed(2), style: const TextStyle(fontSize: 11)),
          onTap: () => Navigator.pop(context, a),
        )).toList(),
      ),
    );
  }

  Future<void> _submit() async {
    if (_fromAccount == null || _toAccount == null) {
      _showError('Please select both accounts');
      return;
    }
    if (_fromAccount!.id == _toAccount!.id) {
      _showError('Source and destination account cannot be the same');
      return;
    }
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    setState(() => _isSubmitting = true);

    final request = BankTransferRequest(
      fromBankAccountId: _fromAccount!.id,
      toBankAccountId: _toAccount!.id,
      transactionDate: _date,
      amount: amount,
      description: _descCtrl.text.trim(),
    );

    final ok = await ref.read(bankTransactionActionsProvider.notifier).transfer(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer completed successfully')));
      } else {
        _showError('Something went wrong, please try again');
      }
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(bankAccountListProvider);

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 16),
            const Text('Transfer Funds', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            accountsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (accounts) => Column(
                children: [
                  InkWell(
                    onTap: () async {
                      final a = await _pickAccount(accounts);
                      if (a != null) setState(() => _fromAccount = a);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'From Account', prefixIcon: const Icon(Icons.arrow_upward, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                      child: Text(_fromAccount?.accountName ?? 'Select source account', style: TextStyle(fontSize: 13, color: _fromAccount != null ? AppColors.textPrimary : AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () async {
                      final a = await _pickAccount(accounts);
                      if (a != null) setState(() => _toAccount = a);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'To Account', prefixIcon: const Icon(Icons.arrow_downward, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                      child: Text(_toAccount?.accountName ?? 'Select destination account', style: TextStyle(fontSize: 13, color: _toAccount != null ? AppColors.textPrimary : AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),
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
            NexaTextField(controller: _amountCtrl, label: 'Amount', hint: '0.00', icon: Icons.attach_money, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 14),
            NexaTextField(controller: _descCtrl, label: 'Description (optional)', hint: 'Transfer note...', icon: Icons.notes),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Transfer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}