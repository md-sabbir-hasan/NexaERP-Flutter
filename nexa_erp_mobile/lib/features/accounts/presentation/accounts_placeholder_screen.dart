import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class AccountsPlaceholderScreen extends StatelessWidget {
  const AccountsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Accounts'), backgroundColor: AppColors.bg, elevation: 0),
      body: const Center(
        child: Text('Chart of Accounts module শীঘ্রই আসছে', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}