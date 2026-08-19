import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class QuickAction {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String label;
  final VoidCallback onTap;
  QuickAction({required this.icon, required this.color, required this.bgColor, required this.label, required this.onTap});
}

class QuickActionsRow extends StatelessWidget {
  final List<QuickAction> actions;
  const QuickActionsRow({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((a) {
          return InkWell(
            onTap: a.onTap,
            borderRadius: BorderRadius.circular(30),
            child: Column(
              children: [
                CircleAvatar(radius: 24, backgroundColor: a.bgColor, child: Icon(a.icon, color: a.color)),
                const SizedBox(height: 8),
                Text(a.label, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}