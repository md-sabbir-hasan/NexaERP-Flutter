import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/creditnote_repository.dart';
import '../data/creditnote_models.dart';
import '../../../core/network/providers.dart';
import '../../invoice/application/invoice_provider.dart';
import '../../invoice/data/invoice_models.dart';

final creditNoteRepositoryProvider = Provider<CreditNoteRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CreditNoteRepository(dio);
});

final creditNoteListProvider = FutureProvider.autoDispose<List<CreditNoteModel>>((ref) async {
  final repo = ref.watch(creditNoteRepositoryProvider);
  return repo.getAll();
});

final postedInvoicesProvider = Provider.autoDispose<AsyncValue<List<InvoiceModel>>>((ref) {
  final listAsync = ref.watch(invoiceListProvider);
  return listAsync.whenData((list) => list.where((i) => i.status != InvoiceStatus.draft && i.status != InvoiceStatus.cancelled).toList());
});

class CreditNoteActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<CreditNoteModel?> create(CreditNoteRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(creditNoteRepositoryProvider);
      final result = await repo.create(request);
      state = const AsyncData(null);
      ref.invalidate(creditNoteListProvider);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> approve(int id) async {
    try {
      await ref.read(creditNoteRepositoryProvider).approve(id);
      ref.invalidate(creditNoteListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> post(int id) async {
    try {
      await ref.read(creditNoteRepositoryProvider).post(id);
      ref.invalidate(creditNoteListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancel(int id, CreditNoteCancelledReason reason) async {
    try {
      await ref.read(creditNoteRepositoryProvider).cancel(id, reason);
      ref.invalidate(creditNoteListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final creditNoteActionsProvider = NotifierProvider<CreditNoteActionsNotifier, AsyncValue<void>>(CreditNoteActionsNotifier.new);