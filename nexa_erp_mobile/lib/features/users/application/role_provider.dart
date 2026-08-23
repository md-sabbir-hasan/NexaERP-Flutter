import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/role_repository.dart';
import '../data/role_models.dart';
import '../../../core/network/providers.dart';

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return RoleRepository(dio);
});

final roleListProvider = FutureProvider.autoDispose<List<RoleModel>>((ref) async {
  final repo = ref.watch(roleRepositoryProvider);
  return repo.getAll();
});

final allPermissionsProvider = FutureProvider.autoDispose<List<PermissionModel>>((ref) async {
  final repo = ref.watch(roleRepositoryProvider);
  return repo.getAllPermissions();
});

class RoleActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create(RoleRequest request) async {
    try {
      await ref.read(roleRepositoryProvider).create(request);
      ref.invalidate(roleListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(int id, RoleRequest request) async {
    try {
      await ref.read(roleRepositoryProvider).update(id, request);
      ref.invalidate(roleListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final roleActionsProvider = NotifierProvider<RoleActionsNotifier, AsyncValue<void>>(RoleActionsNotifier.new);