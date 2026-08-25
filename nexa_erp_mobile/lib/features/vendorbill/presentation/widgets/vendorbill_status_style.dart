import 'package:flutter/material.dart';
import 'package:nexa_erp_mobile/features/vendorbill/data/vendorbill_models.dart';
import '../../../../app/theme/app_colors.dart';

class VendorBillStatusStyle {
  static Color color(VendorBillStatus status) {
    switch (status) {
      case VendorBillStatus.draft: return AppColors.iconOrange;
      case VendorBillStatus.approved: return AppColors.iconPurple;
      case VendorBillStatus.posted: return AppColors.iconBlue;
      case VendorBillStatus.partial: return AppColors.iconPurple;
      case VendorBillStatus.paid: return AppColors.iconGreen;
      case VendorBillStatus.cancelled: return AppColors.danger;
    }
  }

  static Color chipColor(VendorBillStatus status) {
    switch (status) {
      case VendorBillStatus.draft: return AppColors.chipOrange;
      case VendorBillStatus.approved: return AppColors.chipPurple;
      case VendorBillStatus.posted: return AppColors.chipBlue;
      case VendorBillStatus.partial: return AppColors.chipPurple;
      case VendorBillStatus.paid: return AppColors.chipGreen;
      case VendorBillStatus.cancelled: return const Color(0xFFFFE1E1);
    }
  }
}