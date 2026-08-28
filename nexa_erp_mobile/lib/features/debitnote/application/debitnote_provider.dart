import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/debitnote_repository.dart';
import '../data/debitnote_models.dart';
import '../../../core/network/providers.dart';
import '../../vendorbill/application/vendorbill_provider.dart';
import '../../vendorbill/data/vendorbill_models.dart';

final debitNoteRepositoryProvider = Provider<DebitNoteRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DebitNoteRepository(dio);
});

final debitNoteListProvider = FutureProvider.autoDispose<List<DebitNoteModel>>((ref) async {
  final repo = ref.watch(debitNoteRepositoryProvider);
  return repo.getAll();
});


final postedVendorBillsProvider = Provider.autoDispose<AsyncValue<List<VendorBillModel>>>((ref) {
  final listAsync = ref.watch(vendorBillListProvider);
  return listAsync.whenData((list) => list.where((b) => b.status != VendorBillStatus.draft && b.status != VendorBillStatus.cancelled).toList());
});

class DebitNoteActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<DebitNoteModel?> create(DebitNoteRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(debitNoteRepositoryProvider);
      final result = await repo.create(request);
      state = const AsyncData(null);
      ref.invalidate(debitNoteListProvider);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> approve(int id) async {
    try {
      await ref.read(debitNoteRepositoryProvider).approve(id);
      ref.invalidate(debitNoteListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> post(int id) async {
    try {
      await ref.read(debitNoteRepositoryProvider).post(id);
      ref.invalidate(debitNoteListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancel(int id, DebitNoteCancelledReason reason) async {
    try {
      await ref.read(debitNoteRepositoryProvider).cancel(id, reason);
      ref.invalidate(debitNoteListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final debitNoteActionsProvider = NotifierProvider<DebitNoteActionsNotifier, AsyncValue<void>>(DebitNoteActionsNotifier.new);