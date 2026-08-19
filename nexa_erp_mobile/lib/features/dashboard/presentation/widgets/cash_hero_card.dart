import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class CashHeroCard extends StatelessWidget {
  final String currencyCode;
  final double cashPosition;
  final double receivable;
  final double payable;
  final int overdueInvoiceCount;
  final int overdueBillCount;

  const CashHeroCard({
    super.key,
    required this.currencyCode,
    required this.cashPosition,
    required this.receivable,
    required this.payable,
    this.overdueInvoiceCount = 0,
    this.overdueBillCount = 0,
  });

  String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final posFromEnd = intPart.length - i;
      buf.write(intPart[i]);
      if (posFromEnd > 1 && posFromEnd <= 3) continue;
      if (posFromEnd > 3 && (posFromEnd - 3) % 2 == 0) buf.write(',');
    }
    return '$buf.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cash Position', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      '$currencyCode ${_fmt(cashPosition)}',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _amountBlock('Receivable', receivable, overdueInvoiceCount),
              ),
              Container(width: 1, height: 38, color: Colors.white24),
              const SizedBox(width: 16),
              Expanded(
                child: _amountBlock('Payable', payable, overdueBillCount),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountBlock(String label, double value, int overdueCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text('৳ ${_fmt(value)}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        if (overdueCount > 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Color(0xFFFFB4B4), size: 11),
                const SizedBox(width: 4),
                Text(
                  '$overdueCount overdue',
                  style: const TextStyle(color: Color(0xFFFFB4B4), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}