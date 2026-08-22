import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/approval_models.dart';

class ApprovalStatusStyle {
  static Color color(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending: return AppColors.iconOrange;
      case ApprovalStatus.approved: return AppColors.iconGreen;
      case ApprovalStatus.rejected: return AppColors.danger;
      case ApprovalStatus.returned: return AppColors.iconPurple;
      case ApprovalStatus.cancelled: return AppColors.textSecondary;
    }
  }

  static Color chipColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending: return AppColors.chipOrange;
      case ApprovalStatus.approved: return AppColors.chipGreen;
      case ApprovalStatus.rejected: return const Color(0xFFFFE1E1);
      case ApprovalStatus.returned: return AppColors.chipPurple;
      case ApprovalStatus.cancelled: return const Color(0xFFEDEDED);
    }
  }

  static IconData entityIcon(ApprovalEntityType type) {
    switch (type) {
      case ApprovalEntityType.manualJournal: return Icons.description;
      case ApprovalEntityType.vendorBill: return Icons.receipt;
      case ApprovalEntityType.invoice: return Icons.receipt_long;
      case ApprovalEntityType.payment: return Icons.payments;
    }
  }
}