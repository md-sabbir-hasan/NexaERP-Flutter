import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../application/user_provider.dart';
import '../data/user_models.dart';
import 'widgets/user_form_sheet.dart';
import 'widgets/user_status_style.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(userListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(userListProvider);
    final filter = ref.watch(userFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => showUserFormSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (v) => ref.read(userFilterProvider.notifier).state = filter.copyWith(search: v),
              decoration: InputDecoration(
                hintText: 'Search name or email...',
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
                _chip('All', filter.status == null, () => ref.read(userFilterProvider.notifier).state = filter.copyWith(clearStatus: true)),
                const SizedBox(width: 8),
                ...UserStatus.values.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip(s.label, filter.status == s, () => ref.read(userFilterProvider.notifier).state = filter.copyWith(status: s)),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (state) {
                if (state.items.isEmpty) {
                  return const Center(child: Text('কোনো user পাওয়া যায়নি', style: TextStyle(color: AppColors.textSecondary)));
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(userListProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: state.items.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                      }
                      final user = state.items[index];
                      return _UserCard(user: user);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
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

class _UserCard extends ConsumerWidget {
  final AppUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.chipBlue,
            child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(user.email, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: user.roles.take(2).map((r) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.chipPurple, borderRadius: BorderRadius.circular(20)),
                    child: Text(r, style: const TextStyle(fontSize: 9, color: AppColors.iconPurple)),
                  )).toList(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: UserStatusStyle.chipColor(user.status), borderRadius: BorderRadius.circular(20)),
                child: Text(user.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: UserStatusStyle.color(user.status))),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                onSelected: (v) async {
                  if (v == 'toggle') {
                    final ok = await ref.read(userActionsProvider.notifier).toggleActive(user);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Status আপডেট হয়েছে' : 'সমস্যা হয়েছে')));
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(user.status == UserStatus.active ? 'Deactivate' : 'Activate'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}