import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_erp_mobile/features/parties/application/party_provider.dart';
import '../data/expense_repository.dart';
import '../data/expense_models.dart';
import '../../../core/network/providers.dart';
import '../../parties/data/party_models.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ExpenseRepository(dio);
});


final vendorListProvider = FutureProvider.autoDispose<List<PartyModel>>((ref) async {
  final repo = ref.watch(partyRepositoryProvider);
  return repo.getByType('VENDOR');
});

final expenseListProvider = FutureProvider.autoDispose<List<ExpenseModel>>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getAll();
});

final expenseStatusFilterProvider = StateProvider.autoDispose<ExpenseStatus?>((ref) => null);

final filteredExpenseListProvider = Provider.autoDispose<AsyncValue<List<ExpenseModel>>>((ref) {
  final listAsync = ref.watch(expenseListProvider);
  final filter = ref.watch(expenseStatusFilterProvider);
  return listAsync.whenData((list) {
    if (filter == null) return list;
    return list.where((e) => e.status == filter).toList();
  });
});

class ExpenseActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<ExpenseModel?> create(ExpenseRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(expenseRepositoryProvider);
      final result = await repo.create(request);
      state = const AsyncData(null);
      ref.invalidate(expenseListProvider);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> post(int id) async {
    try {
      final repo = ref.read(expenseRepositoryProvider);
      await repo.post(id);
      ref.invalidate(expenseListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> cancel(int id, String reason) async {
    try {
      final repo = ref.read(expenseRepositoryProvider);
      await repo.cancel(id, reason);
      ref.invalidate(expenseListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final expenseActionsProvider = NotifierProvider<ExpenseActionsNotifier, AsyncValue<void>>(ExpenseActionsNotifier.new);