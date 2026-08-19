import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/dashboard_models.dart';

class RecentActivityList extends StatelessWidget {
  final List<RecentActivity> activities;
  const RecentActivityList({super.key, required this.activities});

  (IconData, Color, Color) _iconFor(String? action, String? entityName) {
    final a = (action ?? '').toUpperCase();
    final e = (entityName ?? '').toUpperCase();
    if (e.contains('JOURNAL')) return (Icons.description, AppColors.iconGreen, AppColors.chipGreen);
    if (e.contains('INVOICE')) return (Icons.receipt_long, AppColors.iconBlue, AppColors.chipBlue);
    if (e.contains('PAYMENT')) return (Icons.payments, AppColors.iconOrange, AppColors.chipOrange);
    if (e.contains('USER')) return (Icons.person_add, AppColors.iconPurple, AppColors.chipPurple);
    if (a.contains('LOGIN')) return (Icons.login, AppColors.iconBlue, AppColors.chipBlue);
    return (Icons.circle_notifications, AppColors.iconBlue, AppColors.chipBlue);
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return DateFormat('dd MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('কোনো recent activity নেই', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const Divider(height: 20),
          ...List.generate(activities.take(5).length, (i) {
            final a = activities[i];
            final (icon, iconColor, chipColor) = _iconFor(a.action, a.entityName);
            final isLast = i == activities.take(5).length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${a.action ?? ''} ${a.entityName ?? ''}'.trim(),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.userName ?? a.description ?? '',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_timeAgo(a.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}