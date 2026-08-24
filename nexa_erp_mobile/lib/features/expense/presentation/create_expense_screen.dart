import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/nexa_text_field.dart';
import '../../accounts/data/account_models.dart';
import '../../journal/presentation/widgets/account_picker_sheet.dart';
import '../../parties/data/party_models.dart';
import '../application/expense_provider.dart';
import '../data/expense_models.dart';
import 'widgets/budget_warning_banner.dart';
import 'widgets/vendor_picker_field.dart';

class CreateExpenseScreen extends ConsumerStatefulWidget {
  const CreateExpenseScreen({super.key});

  @override
  ConsumerState<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends ConsumerState<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  AccountModel? _expenseAccount;
  AccountModel? _paymentAccount;
  PartyModel? _vendor;
  bool _paidImmediately = true;
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSubmitting = false;
  List<BudgetWarning> _warnings = [];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickExpenseAccount() async {
    final account = await showAccountPickerSheet(
      context,
      filterType: AccountType.expense,
      title: 'Select Expense Category',
    );
    if (account != null) setState(() => _expenseAccount = account);
  }

  Future<void> _pickPaymentAccount() async {
    final account = await showAccountPickerSheet(
      context,
      cashEquivalentOnly: true,
      title: 'Select Cash/Bank Account',
    );
    if (account != null) setState(() => _paymentAccount = account);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expenseAccount == null) {
      _showError('Select Expense category account');
      return;
    }
    if (_paidImmediately && _paymentAccount == null) {
      _showError('Select Payment account (Cash/Bank)');
      return;
    }

    setState(() => _isSubmitting = true);

    final request = ExpenseRequest(
      expenseDate: _date,
      expenseAccountId: _expenseAccount!.id,
      paidImmediately: _paidImmediately,
      paymentAccountId: _paidImmediately ? _paymentAccount!.id : null,
      partyId: _vendor?.id,
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      referenceNumber: _refCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    final result = await ref.read(expenseActionsProvider.notifier).create(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result != null) {
        setState(() => _warnings = result.budgetWarnings);
        if (_warnings.isEmpty) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense Created (Draft)')));
        } else {

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully, but you have exceeded your budget limit.')),
          );
        }
      } else {
        _showError('Error! Try Again');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('New Expense'),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            BudgetWarningBanner(warnings: _warnings),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Expense Date',
                        prefixIcon: const Icon(Icons.calendar_today, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(DateFormat('dd MMM yyyy').format(_date)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickExpenseAccount,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Expense Category',
                        prefixIcon: const Icon(Icons.category_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _expenseAccount != null ? '${_expenseAccount!.code} - ${_expenseAccount!.name}' : 'Select category account',
                        style: TextStyle(fontSize: 13, color: _expenseAccount != null ? AppColors.textPrimary : AppColors.textSecondary),
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
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter Amount';
                      final val = double.tryParse(v);
                      if (val == null || val <= 0) return 'Enter correct amount';
                      return null;
                    },
                  ),
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
                  const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Pay Now'),
                          selected: _paidImmediately,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: _paidImmediately ? Colors.white : AppColors.textPrimary),
                          onSelected: (_) => setState(() => _paidImmediately = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Pay Later'),
                          selected: !_paidImmediately,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: !_paidImmediately ? Colors.white : AppColors.textPrimary),
                          onSelected: (_) => setState(() => _paidImmediately = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_paidImmediately)
                    InkWell(
                      onTap: _pickPaymentAccount,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Pay From (Cash/Bank)',
                          prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _paymentAccount != null ? '${_paymentAccount!.code} - ${_paymentAccount!.name}' : 'Select cash/bank account',
                          style: TextStyle(fontSize: 13, color: _paymentAccount != null ? AppColors.textPrimary : AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    VendorPickerField(selected: _vendor, onSelected: (v) => setState(() => _vendor = v)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  NexaTextField(controller: _refCtrl, label: 'Reference Number (optional)', hint: 'Receipt/invoice no...', icon: Icons.confirmation_number_outlined),
                  const SizedBox(height: 14),
                  NexaTextField(controller: _notesCtrl, label: 'Notes (optional)', hint: 'Additional notes...', icon: Icons.notes),
                ],
              ),
            ),
          ],
        ),
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
                : const Text('Save Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}