import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../application/approval_provider.dart';
import '../../data/approval_models.dart';
import 'approval_status_style.dart';
import 'decision_dialog.dart';

class ApprovalCard extends ConsumerStatefulWidget {
  final ApprovalRequest request;
  const ApprovalCard({super.key, required this.request});

  @override
  ConsumerState<ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends ConsumerState<ApprovalCard> {
  bool _isProcessing = false;

  Future<void> _handle(DecisionType type) async {
    final result = await showDecisionDialog(context, type);
    if (result == null) return;

    setState(() => _isProcessing = true);
    final notifier = ref.read(approvalActionsProvider.notifier);
    bool ok;
    switch (type) {
      case DecisionType.approve:
        ok = await notifier.approve(widget.request.id, comment: result.comment);
        break;
      case DecisionType.reject:
        ok = await notifier.reject(widget.request.id, result.comment ?? '');
        break;
      case DecisionType.returnForCorrection:
        ok = await notifier.returnForCorrection(widget.request.id, result.comment ?? '');
        break;
    }

    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'সফল হয়েছে' : 'সমস্যা হয়েছে, আবার চেষ্টা করো')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: ApprovalStatusStyle.chipColor(r.status), borderRadius: BorderRadius.circular(10)),
                child: Icon(ApprovalStatusStyle.entityIcon(r.entityType), size: 18, color: ApprovalStatusStyle.color(r.status)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.documentTitle ?? r.documentNumber ?? r.entityType.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('${r.entityType.label} · by ${r.makerName ?? ''}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: ApprovalStatusStyle.chipColor(r.status), borderRadius: BorderRadius.circular(20)),
                child: Text(r.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ApprovalStatusStyle.color(r.status))),
              ),
            ],
          ),
          if (r.submittedAt != null) ...[
            const SizedBox(height: 8),
            Text('Submitted: ${DateFormat('dd MMM yyyy, hh:mm a').format(r.submittedAt!)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
          if (r.decisionComment != null && r.decisionComment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
              child: Text('"${r.decisionComment}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
            ),
          ],
          if (r.canDecide && r.status == ApprovalStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => _handle(DecisionType.reject),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger), padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: const Text('Reject', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => _handle(DecisionType.returnForCorrection),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.iconPurple, side: const BorderSide(color: AppColors.iconPurple), padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: const Text('Return', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handle(DecisionType.approve),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: _isProcessing
                        ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Approve', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}