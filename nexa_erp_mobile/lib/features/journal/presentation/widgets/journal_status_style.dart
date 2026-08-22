import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/journal_models.dart';

class JournalStatusStyle {
  static Color color(JournalStatus status) {
    switch (status) {
      case JournalStatus.draft: return AppColors.iconOrange;
      case JournalStatus.posted: return AppColors.iconGreen;
      case JournalStatus.reversed: return AppColors.danger;
    }
  }

  static Color chipColor(JournalStatus status) {
    switch (status) {
      case JournalStatus.draft: return AppColors.chipOrange;
      case JournalStatus.posted: return AppColors.chipGreen;
      case JournalStatus.reversed: return const Color(0xFFFFE1E1);
    }
  }
}