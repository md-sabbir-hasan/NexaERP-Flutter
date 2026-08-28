import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/debitnote_models.dart';

class DebitNoteStatusStyle {
  static Color color(DebitNoteStatus status) {
    switch (status) {
      case DebitNoteStatus.draft: return AppColors.iconOrange;
      case DebitNoteStatus.approved: return AppColors.iconPurple;
      case DebitNoteStatus.posted: return AppColors.iconGreen;
      case DebitNoteStatus.cancelled: return AppColors.danger;
    }
  }

  static Color chipColor(DebitNoteStatus status) {
    switch (status) {
      case DebitNoteStatus.draft: return AppColors.chipOrange;
      case DebitNoteStatus.approved: return AppColors.chipPurple;
      case DebitNoteStatus.posted: return AppColors.chipGreen;
      case DebitNoteStatus.cancelled: return const Color(0xFFFFE1E1);
    }
  }
}