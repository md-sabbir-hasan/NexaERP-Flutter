import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/role_models.dart';

class PermissionGroupSelector extends StatelessWidget {
  final List<PermissionModel> allPermissions;
  final Set<int> selectedIds;
  final void Function(Set<int>) onChanged;

  const PermissionGroupSelector({
    super.key,
    required this.allPermissions,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<PermissionModel>>{};
    for (final p in allPermissions) {
      grouped.putIfAbsent(p.module, () => []).add(p);
    }
    final modules = grouped.keys.toList()..sort();

    return Column(
      children: modules.map((module) {
        final perms = grouped[module]!;
        final allSelected = perms.every((p) => selectedIds.contains(p.id));

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Row(
              children: [
                Checkbox(
                  value: allSelected,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    final updated = {...selectedIds};
                    if (v == true) {
                      updated.addAll(perms.map((p) => p.id));
                    } else {
                      updated.removeAll(perms.map((p) => p.id));
                    }
                    onChanged(updated);
                  },
                ),
                Text(module, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 6),
                Text('(${perms.length})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
            children: perms.map((p) {
              final isSelected = selectedIds.contains(p.id);
              return CheckboxListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(left: 32, right: 8),
                value: isSelected,
                activeColor: AppColors.primary,
                title: Text(p.name, style: const TextStyle(fontSize: 12)),
                onChanged: (v) {
                  final updated = {...selectedIds};
                  if (v == true) {
                    updated.add(p.id);
                  } else {
                    updated.remove(p.id);
                  }
                  onChanged(updated);
                },
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}