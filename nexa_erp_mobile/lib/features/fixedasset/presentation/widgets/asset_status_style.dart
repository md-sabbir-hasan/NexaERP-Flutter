import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/fixedasset_models.dart';

class AssetStatusStyle {
  static Color color(AssetStatus status) {
    switch (status) {
      case AssetStatus.active: return AppColors.iconGreen;
      case AssetStatus.fullyDepreciated: return AppColors.iconOrange;
      case AssetStatus.disposed: return AppColors.textSecondary;
    }
  }

  static Color chipColor(AssetStatus status) {
    switch (status) {
      case AssetStatus.active: return AppColors.chipGreen;
      case AssetStatus.fullyDepreciated: return AppColors.chipOrange;
      case AssetStatus.disposed: return const Color(0xFFEDEDED);
    }
  }
}