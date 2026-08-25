import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vendorbill_repository.dart';
import '../data/vendorbill_models.dart';
import '../../../core/network/providers.dart';

final vendorBillRepositoryProvider = Provider<VendorBillRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VendorBillRepository(dio);
});

final vendorBillListProvider = FutureProvider.autoDispose<List<VendorBillModel>>((ref) async {
  final repo = ref.watch(vendorBillRepositoryProvider);
  return repo.getAll();
});

final vendorBillStatusFilterProvider = StateProvider.autoDispose<VendorBillStatus?>((ref) => null);

final filteredVendorBillListProvider = Provider.autoDispose<AsyncValue<List<VendorBillModel>>>((ref) {
  final listAsync = ref.watch(vendorBillListProvider);
  final filter = ref.watch(vendorBillStatusFilterProvider);
  return listAsync.whenData((list) {
    if (filter == null) return list;
    return list.where((b) => b.status == filter).toList();
  });
});

class VendorBillActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<VendorBillModel?> create(VendorBillRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(vendorBillRepositoryProvider);
      final result = await repo.create(request);
      state = const AsyncData(null);
      ref.invalidate(vendorBillListProvider);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> approve(int id) async {
    try {
      await ref.read(vendorBillRepositoryProvider).approve(id);
      ref.invalidate(vendorBillListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitApproval(int id) async {
    try {
      await ref.read(vendorBillRepositoryProvider).submitApproval(id);
      ref.invalidate(vendorBillListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> post(int id) async {
    try {
      await ref.read(vendorBillRepositoryProvider).post(id);
      ref.invalidate(vendorBillListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancel(int id, VendorBillCancelledReason reason) async {
    try {
      await ref.read(vendorBillRepositoryProvider).cancel(id, reason);
      ref.invalidate(vendorBillListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final vendorBillActionsProvider = NotifierProvider<VendorBillActionsNotifier, AsyncValue<void>>(VendorBillActionsNotifier.new);