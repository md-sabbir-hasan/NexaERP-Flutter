import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/user_models.dart';

class UserStatusStyle {
  static Color color(UserStatus status) {
    switch (status) {
      case UserStatus.active: return AppColors.iconGreen;
      case UserStatus.inactive: return AppColors.textSecondary;
      case UserStatus.locked: return AppColors.danger;
      case UserStatus.pending: return AppColors.iconOrange;
    }
  }

  static Color chipColor(UserStatus status) {
    switch (status) {
      case UserStatus.active: return AppColors.chipGreen;
      case UserStatus.inactive: return const Color(0xFFEDEDED);
      case UserStatus.locked: return const Color(0xFFFFE1E1);
      case UserStatus.pending: return AppColors.chipOrange;
    }
  }
}