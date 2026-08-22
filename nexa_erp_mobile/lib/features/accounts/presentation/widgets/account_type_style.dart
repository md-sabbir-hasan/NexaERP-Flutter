import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/account_models.dart';

class AccountTypeStyle {
  static Color color(AccountType type) {
    switch (type) {
      case AccountType.asset: return AppColors.iconBlue;
      case AccountType.liability: return AppColors.danger;
      case AccountType.equity: return AppColors.iconPurple;
      case AccountType.revenue: return AppColors.iconGreen;
      case AccountType.expense: return AppColors.iconOrange;
    }
  }

  static Color chipColor(AccountType type) {
    switch (type) {
      case AccountType.asset: return AppColors.chipBlue;
      case AccountType.liability: return const Color(0xFFFFE1E1);
      case AccountType.equity: return AppColors.chipPurple;
      case AccountType.revenue: return AppColors.chipGreen;
      case AccountType.expense: return AppColors.chipOrange;
    }
  }

  static IconData icon(AccountType type) {
    switch (type) {
      case AccountType.asset: return Icons.account_balance;
      case AccountType.liability: return Icons.credit_card;
      case AccountType.equity: return Icons.pie_chart;
      case AccountType.revenue: return Icons.trending_up;
      case AccountType.expense: return Icons.trending_down;
    }
  }
}