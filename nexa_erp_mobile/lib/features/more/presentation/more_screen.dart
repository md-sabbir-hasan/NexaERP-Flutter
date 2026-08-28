import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/application/auth_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('More'), backgroundColor: AppColors.bg, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.chipBlue,
                  child: Text(
                    (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _menuTile(Icons.notifications_outlined, 'Notifications', () => context.push('/notifications')),
          _menuTile(Icons.settings_outlined, 'System Settings', () {}),
          _menuTile(Icons.people_outline, 'Users', () => context.push('/users')),
          _menuTile(Icons.shield_outlined, 'Roles & Permissions', () => context.push('/roles')),
          _menuTile(Icons.history, 'Audit Log', () {}),
          _menuTile(Icons.receipt_outlined, 'Expenses', () => context.push('/expenses')),
          _menuTile(Icons.receipt_long_outlined, 'Invoices', () => context.push('/invoices')),
          _menuTile(Icons.request_page_outlined, 'Vendor Bills', () => context.push('/vendor-bills')),
          _menuTile(Icons.payments_outlined, 'Payments', () => context.push('/payments')),
          _menuTile(Icons.assignment_return_outlined, 'Credit Notes', () => context.push('/credit-notes')),
          _menuTile(Icons.assignment_returned_outlined, 'Debit Notes', () => context.push('/debit-notes')),
          const SizedBox(height: 10),
          _menuTile(
            Icons.logout,
            'Logout',
                () => ref.read(authProvider.notifier).logout(),
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Icon(icon, color: color ?? AppColors.textPrimary),
          title: Text(label, style: TextStyle(color: color ?? AppColors.textPrimary, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
          onTap: onTap,
        ),
      ),
    );
  }
}