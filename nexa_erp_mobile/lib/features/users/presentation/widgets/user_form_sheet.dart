import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/nexa_text_field.dart';
import '../../application/user_provider.dart';
import '../../data/role_models.dart';
import '../../data/user_models.dart';
import 'role_picker_sheet.dart';

Future<void> showUserFormSheet(BuildContext context, {AppUser? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _UserFormSheet(existing: existing),
    ),
  );
}

class _UserFormSheet extends ConsumerStatefulWidget {
  final AppUser? existing;
  const _UserFormSheet({this.existing});

  @override
  ConsumerState<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends ConsumerState<_UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  Set<RoleModel> _selectedRoles = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.existing?.email ?? '');
    // existing user এর role name গুলো থেকে RoleModel বানানো সহজ না (id দরকার),
    // তাই edit mode এ role picker খুলে user নিজে reselect করবে
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickRoles() async {
    final result = await showRolePickerSheet(context, _selectedRoles.map((r) => r.id).toSet());
    if (result != null) setState(() => _selectedRoles = result);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কমপক্ষে একটা role সিলেক্ট করো'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final request = UserRequest(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      roleIds: _selectedRoles.map((r) => r.id).toSet(),
    );

    final notifier = ref.read(userActionsProvider.notifier);
    final success = widget.existing == null
        ? await notifier.create(request)
        : await notifier.update(widget.existing!.id, request);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existing == null ? 'User তৈরি হয়েছে, invite email পাঠানো হয়েছে' : 'User আপডেট হয়েছে')),
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

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 16),
              Text(isEdit ? 'Edit User' : 'New User', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              if (!isEdit) ...[
                const SizedBox(height: 4),
                const Text('নতুন user তৈরি করলে তার email এ invite পাঠানো হবে', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 18),
              NexaTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                hint: 'e.g. John Doe',
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name দিতে হবে' : null,
              ),
              const SizedBox(height: 14),
              NexaTextField(
                controller: _emailCtrl,
                label: 'Email',
                hint: 'user@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email দিতে হবে';
                  if (!v.contains('@')) return 'সঠিক email দাও';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const Text('Roles', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickRoles,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14)),
                  child: _selectedRoles.isEmpty
                      ? const Text('Select roles...', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                      : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedRoles.map((r) => Chip(
                      label: Text(r.name, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.chipBlue,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEdit ? 'Update' : 'Create & Invite', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}