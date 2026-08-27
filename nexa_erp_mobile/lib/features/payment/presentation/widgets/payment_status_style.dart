import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/payment_models.dart';

class PaymentStatusStyle {
  static Color color(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.draft: return AppColors.iconOrange;
      case PaymentStatus.posted: return AppColors.iconGreen;
      case PaymentStatus.cancelled: return AppColors.danger;
    }
  }

  static Color chipColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.draft: return AppColors.chipOrange;
      case PaymentStatus.posted: return AppColors.chipGreen;
      case PaymentStatus.cancelled: return const Color(0xFFFFE1E1);
    }
  }

  static Color typeColor(PaymentType type) => type == PaymentType.receipt ? AppColors.iconGreen : AppColors.iconOrange;
  static IconData typeIcon(PaymentType type) => type == PaymentType.receipt ? Icons.arrow_downward : Icons.arrow_upward;
}