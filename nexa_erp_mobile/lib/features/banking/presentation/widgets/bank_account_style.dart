import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/bank_models.dart';

class BankAccountStyle {
  static IconData icon(BankAccountType type) {
    switch (type) {
      case BankAccountType.cash: return Icons.payments_outlined;
      case BankAccountType.bank: return Icons.account_balance_outlined;
      case BankAccountType.mobileWallet: return Icons.phone_android_outlined;
    }
  }

  static Color color(BankAccountType type) {
    switch (type) {
      case BankAccountType.cash: return AppColors.iconGreen;
      case BankAccountType.bank: return AppColors.iconBlue;
      case BankAccountType.mobileWallet: return AppColors.iconOrange;
    }
  }

  static Color chipColor(BankAccountType type) {
    switch (type) {
      case BankAccountType.cash: return AppColors.chipGreen;
      case BankAccountType.bank: return AppColors.chipBlue;
      case BankAccountType.mobileWallet: return AppColors.chipOrange;
    }
  }
}