import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/creditnote_models.dart';

class CreditNoteStatusStyle {
  static Color color(CreditNoteStatus status) {
    switch (status) {
      case CreditNoteStatus.draft: return AppColors.iconOrange;
      case CreditNoteStatus.approved: return AppColors.iconPurple;
      case CreditNoteStatus.posted: return AppColors.iconGreen;
      case CreditNoteStatus.cancelled: return AppColors.danger;
    }
  }

  static Color chipColor(CreditNoteStatus status) {
    switch (status) {
      case CreditNoteStatus.draft: return AppColors.chipOrange;
      case CreditNoteStatus.approved: return AppColors.chipPurple;
      case CreditNoteStatus.posted: return AppColors.chipGreen;
      case CreditNoteStatus.cancelled: return const Color(0xFFFFE1E1);
    }
  }
}