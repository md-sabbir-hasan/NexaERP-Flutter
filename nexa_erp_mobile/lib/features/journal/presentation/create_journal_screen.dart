import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/nexa_text_field.dart';
import '../../accounts/data/account_models.dart';
import '../application/journal_provider.dart';
import '../data/journal_models.dart';
import 'widgets/account_picker_sheet.dart';

class _LineDraft {
  AccountModel? account;
  final debitCtrl = TextEditingController();
  final creditCtrl = TextEditingController();
  final descCtrl = TextEditingController();
}

class CreateJournalScreen extends ConsumerStatefulWidget {
  const CreateJournalScreen({super.key});

  @override
  ConsumerState<CreateJournalScreen> createState() => _CreateJournalScreenState();
}

class _CreateJournalScreenState extends ConsumerState<CreateJournalScreen> {
  DateTime _date = DateTime.now();
  JournalEntryType _type = JournalEntryType.general;
  final _descCtrl = TextEditingController();
  final List<_LineDraft> _lines = [_LineDraft(), _LineDraft()];
  bool _isSubmitting = false;

  double get _totalDebit => _lines.fold(0.0, (sum, l) => sum + (double.tryParse(l.debitCtrl.text) ?? 0));
  double get _totalCredit => _lines.fold(0.0, (sum, l) => sum + (double.tryParse(l.creditCtrl.text) ?? 0));
  bool get _isBalanced => _totalDebit > 0 && (_totalDebit - _totalCredit).abs() < 0.01;

  void _addLine() => setState(() => _lines.add(_LineDraft()));

  void _removeLine(int index) {
    if (_lines.length <= 2) return;
    setState(() => _lines.removeAt(index));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickAccount(_LineDraft line) async {
    final account = await showAccountPickerSheet(context);
    if (account != null) setState(() => line.account = account);
  }

  Future<void> _submit() async {
    // validation
    for (final l in _lines) {
      if (l.account == null) {
        _showError('সব লাইনে account সিলেক্ট করতে হবে');
        return;
      }
    }
    if (!_isBalanced) {
      _showError('Debit ও Credit সমান হতে হবে');
      return;
    }

    setState(() => _isSubmitting = true);

    final request = JournalEntryRequest(
      date: _date,
      description: _descCtrl.text.trim(),
      type: _type,
      lines: _lines
          .map((l) => JournalLine(
        accountId: l.account!.id,
        debit: double.tryParse(l.debitCtrl.text) ?? 0,
        credit: double.tryParse(l.creditCtrl.text) ?? 0,
        description: l.descCtrl.text.trim(),
      ))
          .toList(),
    );

    final result = await ref.read(journalActionsProvider.notifier).create(request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result != null) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry তৈরি হয়েছে (Draft)')),
        );
      } else {
        _showError('সমস্যা হয়েছে, আবার চেষ্টা করো');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    for (final l in _lines) {
      l.debitCtrl.dispose();
      l.creditCtrl.dispose();
      l.descCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
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
                      labelText: 'Date',
                      prefixIcon: const Icon(Icons.calendar_today, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(DateFormat('dd MMM yyyy').format(_date)),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<JournalEntryType>(
                  initialValue: _type,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    prefixIcon: const Icon(Icons.category_outlined, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: JournalEntryType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v ?? JournalEntryType.general),
                ),
                const SizedBox(height: 14),
                NexaTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  hint: 'Narration for this entry...',
                  icon: Icons.notes,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Journal Lines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              TextButton.icon(onPressed: _addLine, icon: const Icon(Icons.add, size: 16), label: const Text('Add Line')),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_lines.length, (index) {
            final line = _lines[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickAccount(line),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Account',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              line.account != null ? '${line.account!.code} - ${line.account!.name}' : 'Select account',
                              style: TextStyle(
                                fontSize: 12,
                                color: line.account != null ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      if (_lines.length > 2)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
                          onPressed: () => _removeLine(index),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: line.debitCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) {
                            if (v.isNotEmpty && double.tryParse(v) != null && double.parse(v) > 0) {
                              line.creditCtrl.clear();
                            }
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            labelText: 'Debit',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: line.creditCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) {
                            if (v.isNotEmpty && double.tryParse(v) != null && double.parse(v) > 0) {
                              line.debitCtrl.clear();
                            }
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            labelText: 'Credit',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isBalanced ? AppColors.chipGreen : AppColors.chipOrange,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Debit', style: TextStyle(fontSize: 12)),
                    Text(_totalDebit.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Credit', style: TextStyle(fontSize: 12)),
                    Text(_totalCredit.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isBalanced ? Icons.check_circle : Icons.warning, size: 16, color: _isBalanced ? AppColors.success : AppColors.iconOrange),
                    const SizedBox(width: 6),
                    Text(
                      _isBalanced ? 'Balanced' : 'Debit ও Credit সমান নয়',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _isBalanced ? AppColors.success : AppColors.iconOrange),
                    ),
                  ],
                ),
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
            onPressed: (_isBalanced && !_isSubmitting) ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save as Draft', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}