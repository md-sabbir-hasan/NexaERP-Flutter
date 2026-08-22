import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

enum DecisionType { approve, reject, returnForCorrection }

class DecisionResult {
  final String? comment;
  DecisionResult(this.comment);
}

Future<DecisionResult?> showDecisionDialog(BuildContext context, DecisionType type) {
  final commentCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isCommentRequired = type != DecisionType.approve;

  String title, actionLabel;
  Color color;
  switch (type) {
    case DecisionType.approve:
      title = 'Approve Request';
      actionLabel = 'Approve';
      color = AppColors.success;
      break;
    case DecisionType.reject:
      title = 'Reject Request';
      actionLabel = 'Reject';
      color = AppColors.danger;
      break;
    case DecisionType.returnForCorrection:
      title = 'Return for Correction';
      actionLabel = 'Return';
      color = AppColors.iconPurple;
      break;
  }

  return showDialog<DecisionResult>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: commentCtrl,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: isCommentRequired ? 'কারণ লিখো (আবশ্যক)' : 'Comment (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (v) {
            if (isCommentRequired && (v == null || v.trim().isEmpty)) return 'Comment দিতে হবে';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: color),
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.pop(context, DecisionResult(commentCtrl.text.trim()));
          },
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}