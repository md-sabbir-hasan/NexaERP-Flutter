import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../application/role_provider.dart';
import 'role_form_screen.dart';

class RolesScreen extends ConsumerWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(roleListProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Roles'),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RoleFormScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: rolesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (roles) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(roleListProvider),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final r = roles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RoleFormScreen(existing: r))),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.chipPurple, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.shield_outlined, color: AppColors.iconPurple, size: 18),
                  ),
                  title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${r.permissions.length} permissions · ${r.userCount ?? 0} users', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}