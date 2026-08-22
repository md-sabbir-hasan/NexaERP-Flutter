import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../application/account_provider.dart';
import '../data/account_models.dart';
import 'widgets/account_detail_sheet.dart';
import 'widgets/account_form_sheet.dart';
import 'widgets/account_tree_tile.dart';

class AccountsPlaceholderScreen extends ConsumerStatefulWidget {
  const AccountsPlaceholderScreen({super.key});

  @override
  ConsumerState<AccountsPlaceholderScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsPlaceholderScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(accountSearchResultProvider);
    final filter = ref.watch(accountFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Chart of Accounts'),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => showAccountFormSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => ref.read(accountFilterProvider.notifier).state = filter.copyWith(keyword: v),
              decoration: InputDecoration(
                hintText: 'Search account name or code...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('All', filter.type == null, () {
                  ref.read(accountFilterProvider.notifier).state = filter.copyWith(clearType: true);
                }),
                const SizedBox(width: 8),
                ...AccountType.values.map((t) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _filterChip(t.label, filter.type == t, () {
                    ref.read(accountFilterProvider.notifier).state = filter.copyWith(type: t);
                  }),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: resultAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const Center(child: Text('কোনো account পাওয়া যায়নি', style: TextStyle(color: AppColors.textSecondary)));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(accountSearchResultProvider),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      itemCount: accounts.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) => AccountTreeTile(
                        account: accounts[index],
                        onTap: (a) => showAccountDetailSheet(context, a),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary)),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => onTap(),
    );
  }
}