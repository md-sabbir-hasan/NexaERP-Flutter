import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_erp_mobile/core/network/providers.dart';
import 'package:nexa_erp_mobile/features/invoice/data/invoice_models.dart';
import 'package:nexa_erp_mobile/features/invoice/data/invoice_repository.dart';
import 'package:nexa_erp_mobile/features/parties/application/party_provider.dart';
import 'package:nexa_erp_mobile/features/parties/data/party_models.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return InvoiceRepository(dio);
});

final customerListProvider = FutureProvider.autoDispose<List<PartyModel>>((ref) async {
  final repo = ref.watch(partyRepositoryProvider);
  return repo.getByType('CUSTOMER');
});

final invoiceListProvider = FutureProvider.autoDispose<List<InvoiceModel>>((ref) async {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.getAll();
});

final invoiceStatusFilterProvider = StateProvider.autoDispose<InvoiceStatus?>((ref) => null);

final filteredInvoiceListProvider = Provider.autoDispose<AsyncValue<List<InvoiceModel>>>((ref) {
  final listAsync = ref.watch(invoiceListProvider);
  final filter = ref.watch(invoiceStatusFilterProvider);
  return listAsync.whenData((list) {
    if (filter == null) return list;
    return list.where((i) => i.status == filter).toList();
  });
});

class InvoiceActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<InvoiceModel?> create(InvoiceRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(invoiceRepositoryProvider);
      final result = await repo.create(request);
      state = const AsyncData(null);
      ref.invalidate(invoiceListProvider);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> post(int id) async {
    try {
      await ref.read(invoiceRepositoryProvider).post(id);
      ref.invalidate(invoiceListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancel(int id, CancelledReason reason) async {
    try {
      await ref.read(invoiceRepositoryProvider).cancel(id, reason);
      ref.invalidate(invoiceListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitApproval(int id) async {
    try {
      await ref.read(invoiceRepositoryProvider).submitApproval(id);
      ref.invalidate(invoiceListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final invoiceActionsProvider = NotifierProvider<InvoiceActionsNotifier, AsyncValue<void>>(InvoiceActionsNotifier.new);