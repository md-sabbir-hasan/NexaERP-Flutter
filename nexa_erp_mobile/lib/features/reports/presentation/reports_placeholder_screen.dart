import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class ReportsPlaceholderScreen extends StatelessWidget {
  const ReportsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Reports'), backgroundColor: AppColors.bg, elevation: 0),
      body: const Center(
        child: Text('Reports module শীঘ্রই আসছে', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}