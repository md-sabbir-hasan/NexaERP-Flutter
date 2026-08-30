import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import 'trial_balance_screen.dart';
import 'profit_loss_screen.dart';
import 'balance_sheet_screen.dart';
import 'ledger_screen.dart';

class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      _ReportItem('Trial Balance', 'All account balances at a point in time', Icons.balance, AppColors.iconBlue, AppColors.chipBlue, const TrialBalanceScreen()),
      _ReportItem('Profit & Loss', 'Revenue vs expense over a period', Icons.trending_up, AppColors.iconGreen, AppColors.chipGreen, const ProfitLossScreen()),
      _ReportItem('Balance Sheet', 'Assets, liabilities and equity snapshot', Icons.account_balance, AppColors.iconPurple, AppColors.chipPurple, const BalanceSheetScreen()),
      _ReportItem('Ledger', 'Transaction history for a single account', Icons.receipt_long, AppColors.iconOrange, AppColors.chipOrange, const LedgerScreen()),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Reports'), backgroundColor: AppColors.bg, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final r = reports[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => r.screen)),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: r.chipColor, borderRadius: BorderRadius.circular(12)),
                child: Icon(r.icon, color: r.color),
              ),
              title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(r.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }
}

class _ReportItem {
  final String title, subtitle;
  final IconData icon;
  final Color color, chipColor;
  final Widget screen;
  _ReportItem(this.title, this.subtitle, this.icon, this.color, this.chipColor, this.screen);
}