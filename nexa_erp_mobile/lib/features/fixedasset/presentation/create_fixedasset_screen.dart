import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/nexa_text_field.dart';
import '../../accounts/data/account_models.dart';
import '../../journal/presentation/widgets/account_picker_sheet.dart';
import '../application/fixedasset_provider.dart';
import '../data/fixedasset_models.dart';

class CreateFixedAssetScreen extends ConsumerStatefulWidget {
  const CreateFixedAssetScreen({super.key});

  @override
  ConsumerState<CreateFixedAssetScreen> createState() => _CreateFixedAssetScreenState();
}

class _CreateFixedAssetScreenState extends ConsumerState<CreateFixedAssetScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _salvageCtrl = TextEditingController(text: '0');
  final _lifeCtrl = TextEditingController(text: '5');
  final _reducingRateCtrl = TextEditingController(text: '20');
  DateTime _purchaseDate = DateTime.now();
  DepreciationMethod _method = DepreciationMethod.straightLine;
  AccountModel? _assetAccount;
  AccountModel? _depreciationExpenseAccount;
  AccountModel? _accumulatedDepreciationAccount;
  AccountModel? _paymentSourceAccount;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    _salvageCtrl.dispose();
    _lifeCtrl.dispose();
    _reducingRateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _purchaseDate, firstDate: DateTime(2015), lastDate: DateTime(2100));
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<AccountModel?> _pickAny(String title) => showAccountPickerSheet(context, title: title);

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return _showError('Asset name is required');
    final cost = double.tryParse(_costCtrl.text);
    if (cost == null || cost <= 0) return _showError('Enter a valid purchase cost');
    final life = int.tryParse(_lifeCtrl.text);
    if (life == null || life < 1) return _showError('Enter a valid useful life (years)');
    if (_assetAccount == null) return _showError('Please select the asset account');
    if (_depreciationExpenseAccount == null) return _showError('Please select the depreciation expense account');
    if (_accumulatedDepreciationAccount == null) return _showError('Please select the accumulated depreciation account');
    if (_paymentSourceAccount == null) return _showError('Please select the payment source account');

    setState(() => _isSubmitting = true);

    final request = FixedAssetRequest(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      assetAccountId: _assetAccount!.id,
      depreciationExpenseAccountId: _depreciationExpenseAccount!.id,
      accumulatedDepreciationAccountId: _accumulatedDepreciationAccount!.id,
      paymentSourceAccountId: _paymentSourceAccount!.id,
      purchaseDate: _purchaseDate,
      purchaseCost: cost,
      salvageValue: double.tryParse(_salvageCtrl.text) ?? 0,
      usefulLifeYears: life,
      depreciationMethod: _method,
      reducingBalanceRate: _method == DepreciationMethod.reducingBalance ? double.tryParse(_reducingRateCtrl.text) : null,
    );

    final ok = await ref.read(fixedAssetActionsProvider.notifier).create(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fixed asset registered successfully')));
      } else {
        _showError('Something went wrong, please try again');
      }
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));

  Widget _accountPickerTile(String label, AccountModel? selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.account_balance_outlined, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(
          selected != null ? '${selected.code} - ${selected.name}' : 'Select account',
          style: TextStyle(fontSize: 12, color: selected != null ? AppColors.textPrimary : AppColors.textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('New Fixed Asset'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                NexaTextField(controller: _nameCtrl, label: 'Asset Name', hint: 'e.g. Office Laptop - Dell XPS', icon: Icons.badge_outlined),
                const SizedBox(height: 14),
                NexaTextField(controller: _descCtrl, label: 'Description (optional)', hint: 'Additional details...', icon: Icons.notes),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Purchase Date', prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(DateFormat('dd MMM yyyy').format(_purchaseDate)),
                  ),
                ),
                const SizedBox(height: 14),
                NexaTextField(controller: _costCtrl, label: 'Purchase Cost', hint: '0.00', icon: Icons.attach_money, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 14),
                NexaTextField(controller: _salvageCtrl, label: 'Salvage Value', hint: '0.00', icon: Icons.money_off, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 14),
                NexaTextField(controller: _lifeCtrl, label: 'Useful Life (years)', hint: '5', icon: Icons.timelapse, keyboardType: TextInputType.number),
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
                const Text('Depreciation Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Straight Line', style: TextStyle(fontSize: 11)),
                        selected: _method == DepreciationMethod.straightLine,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: _method == DepreciationMethod.straightLine ? Colors.white : AppColors.textPrimary),
                        onSelected: (_) => setState(() => _method = DepreciationMethod.straightLine),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Reducing Balance', style: TextStyle(fontSize: 11)),
                        selected: _method == DepreciationMethod.reducingBalance,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: _method == DepreciationMethod.reducingBalance ? Colors.white : AppColors.textPrimary),
                        onSelected: (_) => setState(() => _method = DepreciationMethod.reducingBalance),
                      ),
                    ),
                  ],
                ),
                if (_method == DepreciationMethod.reducingBalance) ...[
                  const SizedBox(height: 14),
                  NexaTextField(controller: _reducingRateCtrl, label: 'Reducing Balance Rate (%)', hint: '20', icon: Icons.percent, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                ],
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
                const Text('Linked Accounts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _accountPickerTile('Asset Account', _assetAccount, () async {
                  final a = await _pickAny('Asset Account');
                  if (a != null) setState(() => _assetAccount = a);
                }),
                const SizedBox(height: 12),
                _accountPickerTile('Depreciation Expense Account', _depreciationExpenseAccount, () async {
                  final a = await _pickAny('Depreciation Expense Account');
                  if (a != null) setState(() => _depreciationExpenseAccount = a);
                }),
                const SizedBox(height: 12),
                _accountPickerTile('Accumulated Depreciation Account', _accumulatedDepreciationAccount, () async {
                  final a = await _pickAny('Accumulated Depreciation Account');
                  if (a != null) setState(() => _accumulatedDepreciationAccount = a);
                }),
                const SizedBox(height: 12),
                _accountPickerTile('Payment Source (Cash/Bank/Payable)', _paymentSourceAccount, () async {
                  final a = await _pickAny('Payment Source Account');
                  if (a != null) setState(() => _paymentSourceAccount = a);
                }),
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
                : const Text('Register Asset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}