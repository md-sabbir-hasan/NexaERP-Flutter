import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/vendorbill_models.dart';

class VendorBillBudgetWarningBanner extends StatelessWidget {
  final List<BudgetWarning> warnings;
  const VendorBillBudgetWarningBanner({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.iconOrange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: warnings.map((w) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.iconOrange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    w.message ?? '${w.accountName ?? ''} Budget Range Extent',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8A5300)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}