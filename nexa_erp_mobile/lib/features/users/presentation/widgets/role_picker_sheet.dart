import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../application/role_provider.dart';
import '../../data/role_models.dart';

Future<Set<RoleModel>?> showRolePickerSheet(BuildContext context, Set<int> selectedIds) {
  return showModalBottomSheet<Set<RoleModel>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RolePickerSheet(selectedIds: selectedIds),
  );
}

class _RolePickerSheet extends ConsumerStatefulWidget {
  final Set<int> selectedIds;
  const _RolePickerSheet({required this.selectedIds});

  @override
  ConsumerState<_RolePickerSheet> createState() => _RolePickerSheetState();
}

class _RolePickerSheetState extends ConsumerState<_RolePickerSheet> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.selectedIds};
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(roleListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 14),
            const Text('Select Roles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: rolesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (roles) => ListView.builder(
                  controller: scrollController,
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final r = roles[index];
                    final isSelected = _selected.contains(r.id);
                    return CheckboxListTile(
                      value: isSelected,
                      activeColor: AppColors.primary,
                      title: Text(r.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text('${r.permissions.length} permissions', style: const TextStyle(fontSize: 11)),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(r.id);
                          } else {
                            _selected.remove(r.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final rolesAsyncVal = rolesAsync.valueOrNull ?? [];
                  final selectedRoles = rolesAsyncVal.where((r) => _selected.contains(r.id)).toSet();
                  Navigator.pop(context, selectedRoles);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Done (${_selected.length} selected)', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}