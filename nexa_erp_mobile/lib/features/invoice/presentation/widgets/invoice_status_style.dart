import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/invoice_models.dart';

class InvoiceStatusStyle {
  static Color color(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft: return AppColors.iconOrange;
      case InvoiceStatus.posted: return AppColors.iconBlue;
      case InvoiceStatus.partial: return AppColors.iconPurple;
      case InvoiceStatus.paid: return AppColors.iconGreen;
      case InvoiceStatus.cancelled: return AppColors.danger;
    }
  }

  static Color chipColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft: return AppColors.chipOrange;
      case InvoiceStatus.posted: return AppColors.chipBlue;
      case InvoiceStatus.partial: return AppColors.chipPurple;
      case InvoiceStatus.paid: return AppColors.chipGreen;
      case InvoiceStatus.cancelled: return const Color(0xFFFFE1E1);
    }
  }
}