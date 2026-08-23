import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/nexa_text_field.dart';
import '../application/role_provider.dart';
import '../data/role_models.dart';
import 'widgets/permission_group_selector.dart';

class RoleFormScreen extends ConsumerStatefulWidget {
  final RoleModel? existing;
  const RoleFormScreen({super.key, this.existing});

  @override
  ConsumerState<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends ConsumerState<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  Set<int> _selectedPermissionIds = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _descCtrl = TextEditingController(text: widget.existing?.description ?? '');
    _selectedPermissionIds = widget.existing?.permissions.map((p) => p.id).toSet() ?? {};
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final request = RoleRequest(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      permissionIds: _selectedPermissionIds,
    );

    final notifier = ref.read(roleActionsProvider.notifier);
    final success = widget.existing == null
        ? await notifier.create(request)
        : await notifier.update(widget.existing!.id, request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existing == null ? 'Role তৈরি হয়েছে' : 'Role আপডেট হয়েছে')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সমস্যা হয়েছে, আবার চেষ্টা করো'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final permissionsAsync = ref.watch(allPermissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Role' : 'New Role'),
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  NexaTextField(
                    controller: _nameCtrl,
                    label: 'Role Name',
                    hint: 'e.g. Accountant',
                    icon: Icons.badge_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name দিতে হবে' : null,
                  ),
                  const SizedBox(height: 14),
                  NexaTextField(
                    controller: _descCtrl,
                    label: 'Description (optional)',
                    hint: 'Short note about this role...',
                    icon: Icons.notes,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${_selectedPermissionIds.length} selected', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: permissionsAsync.when(
                loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Padding(padding: const EdgeInsets.all(20), child: Text('Error: $e')),
                data: (perms) => PermissionGroupSelector(
                  allPermissions: perms,
                  selectedIds: _selectedPermissionIds,
                  onChanged: (updated) => setState(() => _selectedPermissionIds = updated),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(isEdit ? 'Update Role' : 'Create Role', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}