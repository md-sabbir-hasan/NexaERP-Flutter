import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../application/account_provider.dart';
import '../../data/account_models.dart';
import 'account_form_sheet.dart';
import 'account_type_style.dart';

void showAccountDetailSheet(BuildContext context, AccountModel account) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _AccountDetailSheet(account: account),
  );
}

class _AccountDetailSheet extends ConsumerWidget {
  final AccountModel account;
  const _AccountDetailSheet({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AccountTypeStyle.chipColor(account.type), borderRadius: BorderRadius.circular(12)),
                child: Icon(AccountTypeStyle.icon(account.type), color: AccountTypeStyle.color(account.type)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${account.code} · ${account.type.label}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _infoRow('Current Balance', account.currentBalance.toStringAsFixed(2)),
          if (account.parentName != null) _infoRow('Parent Account', account.parentName!),
          _infoRow('Status', account.isActive ? 'Active' : 'Inactive'),
          if (account.isCashEquivalent) _infoRow('Cash Equivalent', 'Yes'),
          if (account.description != null && account.description!.isNotEmpty)
            _infoRow('Description', account.description!),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showAccountFormSheet(context, existing: account);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: account.isDefault
                      ? null
                      : () async {
                    final ok = await ref.read(accountActionsProvider.notifier).toggleActive(account);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'Status আপডেট হয়েছে' : 'সমস্যা হয়েছে')),
                      );
                    }
                  },
                  icon: Icon(account.isActive ? Icons.block : Icons.check_circle, size: 16),
                  label: Text(account.isActive ? 'Deactivate' : 'Activate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: account.isActive ? AppColors.danger : AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}