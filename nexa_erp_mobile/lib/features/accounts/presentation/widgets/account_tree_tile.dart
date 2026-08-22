import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/account_models.dart';
import 'account_type_style.dart';

class AccountTreeTile extends StatefulWidget {
  final AccountModel account;
  final int depth;
  final void Function(AccountModel) onTap;

  const AccountTreeTile({
    super.key,
    required this.account,
    this.depth = 0,
    required this.onTap,
  });

  @override
  State<AccountTreeTile> createState() => _AccountTreeTileState();
}

class _AccountTreeTileState extends State<AccountTreeTile> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final a = widget.account;
    final hasChildren = a.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => widget.onTap(a),
          child: Padding(
            padding: EdgeInsets.only(left: widget.depth * 20.0, top: 10, bottom: 10, right: 8),
            child: Row(
              children: [
                if (hasChildren)
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Icon(
                      _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AccountTypeStyle.chipColor(a.type),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(AccountTypeStyle.icon(a.type), size: 14, color: AccountTypeStyle.color(a.type)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(a.code, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              a.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: a.isActive ? AppColors.textPrimary : AppColors.textSecondary,
                                decoration: a.isActive ? null : TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  a.currentBalance.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: a.currentBalance < 0 ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasChildren && _expanded)
          ...a.children.map((child) => AccountTreeTile(
            account: child,
            depth: widget.depth + 1,
            onTap: widget.onTap,
          )),
      ],
    );
  }
}