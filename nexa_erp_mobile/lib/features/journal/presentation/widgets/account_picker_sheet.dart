import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../accounts/application/account_provider.dart';
import '../../../accounts/data/account_models.dart';
import '../../../accounts/presentation/widgets/account_type_style.dart';

Future<AccountModel?> showAccountPickerSheet(BuildContext context) {
  return showModalBottomSheet<AccountModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AccountPickerSheet(),
  );
}

class _AccountPickerSheet extends ConsumerStatefulWidget {
  const _AccountPickerSheet();

  @override
  ConsumerState<_AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends ConsumerState<_AccountPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<AccountModel> _flatten(List<AccountModel> list) {
    final result = <AccountModel>[];
    for (final a in list) {
      result.add(a);
      if (a.children.isNotEmpty) result.addAll(_flatten(a.children));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final treeAsync = ref.watch(accountTreeProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 14),
            const Text('Select Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search account...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: AppColors.bg,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: treeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (tree) {
                  final flat = _flatten(tree).where((a) => a.isActive).toList();
                  final query = _searchCtrl.text.toLowerCase();
                  final filtered = query.isEmpty
                      ? flat
                      : flat.where((a) => a.name.toLowerCase().contains(query) || a.code.contains(query)).toList();

                  return ListView.separated(
                    controller: scrollController,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final a = filtered[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AccountTypeStyle.chipColor(a.type), borderRadius: BorderRadius.circular(8)),
                          child: Icon(AccountTypeStyle.icon(a.type), size: 14, color: AccountTypeStyle.color(a.type)),
                        ),
                        title: Text(a.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text('${a.code} · ${a.type.label}', style: const TextStyle(fontSize: 11)),
                        onTap: () => Navigator.pop(context, a),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}