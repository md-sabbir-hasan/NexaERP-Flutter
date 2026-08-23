import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/expense_models.dart';

class ExpenseStatusStyle {
  static Color color(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.draft: return AppColors.iconOrange;
      case ExpenseStatus.posted: return AppColors.iconGreen;
      case ExpenseStatus.cancelled: return AppColors.danger;
    }
  }

  static Color chipColor(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.draft: return AppColors.chipOrange;
      case ExpenseStatus.posted: return AppColors.chipGreen;
      case ExpenseStatus.cancelled: return const Color(0xFFFFE1E1);
    }
  }

  static Color paymentColor(ExpensePaymentStatus status) {
    switch (status) {
      case ExpensePaymentStatus.unpaid: return AppColors.danger;
      case ExpensePaymentStatus.partial: return AppColors.iconOrange;
      case ExpensePaymentStatus.paid: return AppColors.iconGreen;
    }
  }
}