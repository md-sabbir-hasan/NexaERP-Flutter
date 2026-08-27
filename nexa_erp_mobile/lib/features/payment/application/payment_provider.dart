import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/payment_repository.dart';
import '../data/payment_models.dart';
import '../../../core/network/providers.dart';
import '../../invoice/application/invoice_provider.dart';
import '../../invoice/data/invoice_models.dart';
import '../../vendorbill/application/vendorbill_provider.dart';
import '../../vendorbill/data/vendorbill_models.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRepository(dio);
});

final paymentListProvider = FutureProvider.autoDispose<List<PaymentModel>>((ref) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getAll();
});

final paymentTypeFilterProvider = StateProvider.autoDispose<PaymentType?>((ref) => null);

final filteredPaymentListProvider = Provider.autoDispose<AsyncValue<List<PaymentModel>>>((ref) {
  final listAsync = ref.watch(paymentListProvider);
  final filter = ref.watch(paymentTypeFilterProvider);
  return listAsync.whenData((list) {
    if (filter == null) return list;
    return list.where((p) => p.paymentType == filter).toList();
  });
});

// নির্দিষ্ট customer এর outstanding (unpaid) invoice গুলো — manual allocation এর জন্য
final outstandingInvoicesForPartyProvider = Provider.family.autoDispose<AsyncValue<List<InvoiceModel>>, int>((ref, partyId) {
  final listAsync = ref.watch(invoiceListProvider);
  return listAsync.whenData((list) => list.where((i) => i.partyId == partyId && i.dueAmount > 0).toList());
});

// নির্দিষ্ট vendor এর outstanding (unpaid) bill গুলো — manual allocation এর জন্য
final outstandingBillsForPartyProvider = Provider.family.autoDispose<AsyncValue<List<VendorBillModel>>, int>((ref, partyId) {
  final listAsync = ref.watch(vendorBillListProvider);
  return listAsync.whenData((list) => list.where((b) => b.partyId == partyId && b.dueAmount > 0).toList());
});

class PaymentActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<PaymentModel?> create(PaymentRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(paymentRepositoryProvider);
      final result = await repo.create(request);
      state = const AsyncData(null);
      ref.invalidate(paymentListProvider);
      ref.invalidate(invoiceListProvider);
      ref.invalidate(vendorBillListProvider);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> post(int id) async {
    try {
      await ref.read(paymentRepositoryProvider).post(id);
      ref.invalidate(paymentListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitApproval(int id) async {
    try {
      await ref.read(paymentRepositoryProvider).submitApproval(id);
      ref.invalidate(paymentListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancel(int id) async {
    try {
      await ref.read(paymentRepositoryProvider).cancel(id);
      ref.invalidate(paymentListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final paymentActionsProvider = NotifierProvider<PaymentActionsNotifier, AsyncValue<void>>(PaymentActionsNotifier.new);