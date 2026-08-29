import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/nexa_text_field.dart';
import '../../../accounts/data/account_models.dart';
import '../../../journal/presentation/widgets/account_picker_sheet.dart';
import '../../application/fixedasset_provider.dart';
import '../../data/fixedasset_models.dart';

Future<void> showAssetDisposalFormSheet(BuildContext context, FixedAssetModel asset) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _AssetDisposalFormSheet(asset: asset),
    ),
  );
}

class _AssetDisposalFormSheet extends ConsumerStatefulWidget {
  final FixedAssetModel asset;
  const _AssetDisposalFormSheet({required this.asset});

  @override
  ConsumerState<_AssetDisposalFormSheet> createState() => _AssetDisposalFormSheetState();
}

class _AssetDisposalFormSheetState extends ConsumerState<_AssetDisposalFormSheet> {
  DateTime _date = DateTime.now();
  final _proceedsCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  AccountModel? _proceedsAccount;
  AccountModel? _gainLossAccount;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _proceedsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2015), lastDate: DateTime(2100));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final proceeds = double.tryParse(_proceedsCtrl.text) ?? 0;
    setState(() => _isSubmitting = true);

    final request = AssetDisposalRequest(
      disposalDate: _date,
      disposalProceeds: proceeds,
      proceedsAccountId: proceeds > 0 ? _proceedsAccount?.id : null,
      gainLossAccountId: _gainLossAccount?.id,
      notes: _notesCtrl.text.trim(),
    );

    final ok = await ref.read(fixedAssetActionsProvider.notifier).dispose(widget.asset.id, request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        Navigator.pop(context);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asset disposed successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Something went wrong, please try again'), backgroundColor: AppColors.danger));
      }
    }
  }

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
            Text('Dispose ${widget.asset.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Current book value: ${widget.asset.bookValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: 'Disposal Date', prefixIcon: const Icon(Icons.calendar_today, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(DateFormat('dd MMM yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 14),
            NexaTextField(
              controller: _proceedsCtrl,
              label: 'Disposal Proceeds',
              hint: '0.00 (leave 0 if scrapped)',
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (_) => null,
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () async {
                final a = await showAccountPickerSheet(context, cashEquivalentOnly: true, title: 'Select Proceeds Account');
                if (a != null) setState(() => _proceedsAccount = a);
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: 'Proceeds Account (Cash/Bank)', prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(_proceedsAccount != null ? '${_proceedsAccount!.code} - ${_proceedsAccount!.name}' : 'Select if proceeds > 0', style: TextStyle(fontSize: 12, color: _proceedsAccount != null ? AppColors.textPrimary : AppColors.textSecondary)),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () async {
                final a = await showAccountPickerSheet(context, title: 'Select Gain/Loss Account');
                if (a != null) setState(() => _gainLossAccount = a);
              },
              child: InputDecorator(
                decoration: InputDecoration(labelText: 'Gain/Loss on Disposal Account', prefixIcon: const Icon(Icons.trending_up, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(_gainLossAccount != null ? '${_gainLossAccount!.code} - ${_gainLossAccount!.name}' : 'Select if there is a gain/loss', style: TextStyle(fontSize: 12, color: _gainLossAccount != null ? AppColors.textPrimary : AppColors.textSecondary)),
              ),
            ),
            const SizedBox(height: 14),
            NexaTextField(controller: _notesCtrl, label: 'Notes (optional)', hint: 'Reason for disposal...', icon: Icons.notes),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Confirm Disposal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}