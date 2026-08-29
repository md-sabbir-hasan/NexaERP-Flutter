import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/nexa_text_field.dart';
import '../../application/bank_provider.dart';
import '../../data/bank_models.dart';

Future<void> showBankAccountFormSheet(BuildContext context, {BankAccountModel? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _BankAccountFormSheet(existing: existing),
    ),
  );
}

class _BankAccountFormSheet extends ConsumerStatefulWidget {
  final BankAccountModel? existing;
  const _BankAccountFormSheet({this.existing});

  @override
  ConsumerState<_BankAccountFormSheet> createState() => _BankAccountFormSheetState();
}

class _BankAccountFormSheetState extends ConsumerState<_BankAccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _accountNumberCtrl;
  late final TextEditingController _bankNameCtrl;
  late final TextEditingController _branchCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _openingBalanceCtrl;
  late final TextEditingController _notesCtrl;
  BankAccountType _type = BankAccountType.bank;
  WalletProvider _walletProvider = WalletProvider.bkash;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.accountName ?? '');
    _accountNumberCtrl = TextEditingController(text: e?.accountNumber ?? '');
    _bankNameCtrl = TextEditingController(text: e?.bankName ?? '');
    _branchCtrl = TextEditingController(text: e?.branchName ?? '');
    _mobileCtrl = TextEditingController(text: e?.mobileNumber ?? '');
    _openingBalanceCtrl = TextEditingController(text: (e?.openingBalance ?? 0).toStringAsFixed(2));
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _type = e?.accountType ?? BankAccountType.bank;
    _walletProvider = e?.walletProvider ?? WalletProvider.bkash;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _bankNameCtrl.dispose();
    _branchCtrl.dispose();
    _mobileCtrl.dispose();
    _openingBalanceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final request = BankAccountRequest(
      accountName: _nameCtrl.text.trim(),
      accountNumber: _accountNumberCtrl.text.trim(),
      bankName: _type == BankAccountType.bank ? _bankNameCtrl.text.trim() : null,
      branchName: _type == BankAccountType.bank ? _branchCtrl.text.trim() : null,
      accountType: _type,
      openingBalance: double.tryParse(_openingBalanceCtrl.text) ?? 0,
      notes: _notesCtrl.text.trim(),
      mobileNumber: _type == BankAccountType.mobileWallet ? _mobileCtrl.text.trim() : null,
      walletProvider: _type == BankAccountType.mobileWallet ? _walletProvider : null,
    );

    final notifier = ref.read(bankAccountActionsProvider.notifier);
    final success = widget.existing == null
        ? await notifier.create(request)
        : await notifier.update(widget.existing!.id, request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existing == null ? 'Bank account created' : 'Bank account updated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong, please try again'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 16),
              Text(isEdit ? 'Edit Bank Account' : 'New Bank Account', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              const Text('Account Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: BankAccountType.values.map((t) {
                  final selected = _type == t;
                  return ChoiceChip(
                    label: Text(t.label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary)),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.bg,
                    onSelected: (_) => setState(() => _type = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              NexaTextField(
                controller: _nameCtrl,
                label: 'Account Display Name',
                hint: 'e.g. Main Bank Account',
                icon: Icons.badge_outlined,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              if (_type == BankAccountType.bank) ...[
                NexaTextField(controller: _bankNameCtrl, label: 'Bank Name', hint: 'e.g. Prime Bank', icon: Icons.account_balance_outlined),
                const SizedBox(height: 14),
                NexaTextField(controller: _branchCtrl, label: 'Branch Name (optional)', hint: 'Branch name...', icon: Icons.location_on_outlined),
                const SizedBox(height: 14),
                NexaTextField(controller: _accountNumberCtrl, label: 'Account Number', hint: 'Bank account number...', icon: Icons.numbers),
                const SizedBox(height: 14),
              ],
              if (_type == BankAccountType.mobileWallet) ...[
                DropdownButtonFormField<WalletProvider>(
                  initialValue: _walletProvider,
                  decoration: InputDecoration(labelText: 'Wallet Provider', prefixIcon: const Icon(Icons.phone_android, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                  items: WalletProvider.values.map((w) => DropdownMenuItem(value: w, child: Text(w.label))).toList(),
                  onChanged: (v) => setState(() => _walletProvider = v ?? WalletProvider.bkash),
                ),
                const SizedBox(height: 14),
                NexaTextField(controller: _mobileCtrl, label: 'Mobile Number', hint: '01XXXXXXXXX', icon: Icons.phone, keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
              ],
              NexaTextField(
                controller: _openingBalanceCtrl,
                label: 'Opening Balance',
                hint: '0.00',
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 14),
              NexaTextField(controller: _notesCtrl, label: 'Notes (optional)', hint: 'Additional notes...', icon: Icons.notes),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEdit ? 'Update' : 'Create', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}