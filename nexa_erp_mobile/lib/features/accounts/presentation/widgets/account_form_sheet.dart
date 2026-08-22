import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/nexa_text_field.dart';
import '../../application/account_provider.dart';
import '../../data/account_models.dart';

Future<void> showAccountFormSheet(BuildContext context, {AccountModel? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _AccountFormSheet(existing: existing),
    ),
  );
}

class _AccountFormSheet extends ConsumerStatefulWidget {
  final AccountModel? existing;
  const _AccountFormSheet({this.existing});

  @override
  ConsumerState<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<_AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  AccountType _type = AccountType.asset;
  bool _isCashEquivalent = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _codeCtrl = TextEditingController(text: e?.code ?? '');
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _type = e?.type ?? AccountType.asset;
    _isCashEquivalent = e?.isCashEquivalent ?? false;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final request = AccountRequest(
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type: _type,
      parentId: widget.existing?.parentId,
      isCashEquivalent: _isCashEquivalent,
    );

    final notifier = ref.read(accountActionsProvider.notifier);
    final success = widget.existing == null
        ? await notifier.create(request)
        : await notifier.update(widget.existing!.id, request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existing == null ? 'Account তৈরি হয়েছে' : 'Account আপডেট হয়েছে')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সমস্যা হয়েছে, আবার চেষ্টা করো'), backgroundColor: AppColors.danger),
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
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
              ),
              const SizedBox(height: 16),
              Text(isEdit ? 'Edit Account' : 'New Account', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              NexaTextField(
                controller: _codeCtrl,
                label: 'Account Code',
                hint: 'e.g. 1001',
                icon: Icons.tag,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Code দিতে হবে';
                  if (!RegExp(r'^\d+$').hasMatch(v.trim())) return 'শুধু সংখ্যা হতে হবে';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              NexaTextField(
                controller: _nameCtrl,
                label: 'Account Name',
                hint: 'e.g. Cash in Hand',
                icon: Icons.label_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name দিতে হবে' : null,
              ),
              const SizedBox(height: 14),
              const Text('Account Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AccountType.values.map((t) {
                  final selected = _type == t;
                  return ChoiceChip(
                    label: Text(t.label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary)),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.bg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) => setState(() => _type = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              NexaTextField(
                controller: _descCtrl,
                label: 'Description (optional)',
                hint: 'Short note...',
                icon: Icons.notes,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isCashEquivalent,
                activeColor: AppColors.primary,
                title: const Text('Cash Equivalent Account', style: TextStyle(fontSize: 13)),
                subtitle: const Text('ব্যাংক/ক্যাশ রিলেটেড হিসাব হলে চালু করো', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                onChanged: (v) => setState(() => _isCashEquivalent = v),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
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