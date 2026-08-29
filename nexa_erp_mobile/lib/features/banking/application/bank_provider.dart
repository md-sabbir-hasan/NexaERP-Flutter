import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bank_repository.dart';
import '../data/bank_models.dart';
import '../../../core/network/providers.dart';

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BankRepository(dio);
});

final bankAccountListProvider = FutureProvider.autoDispose<List<BankAccountModel>>((ref) async {
  final repo = ref.watch(bankRepositoryProvider);
  return repo.getAllAccounts();
});

final bankTransactionsProvider = FutureProvider.family.autoDispose<List<BankTransactionModel>, int>((ref, accountId) async {
  final repo = ref.watch(bankRepositoryProvider);
  return repo.getTransactionsByAccount(accountId);
});

class BankAccountActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create(BankAccountRequest request) async {
    try {
      await ref.read(bankRepositoryProvider).createAccount(request);
      ref.invalidate(bankAccountListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(int id, BankAccountRequest request) async {
    try {
      await ref.read(bankRepositoryProvider).updateAccount(id, request);
      ref.invalidate(bankAccountListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleActive(BankAccountModel account) async {
    try {
      final repo = ref.read(bankRepositoryProvider);
      if (account.isActive) {
        await repo.deactivateAccount(account.id);
      } else {
        await repo.activateAccount(account.id);
      }
      ref.invalidate(bankAccountListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final bankAccountActionsProvider = NotifierProvider<BankAccountActionsNotifier, AsyncValue<void>>(BankAccountActionsNotifier.new);

class BankTransactionActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create(BankTransactionRequest request) async {
    try {
      await ref.read(bankRepositoryProvider).createTransaction(request);
      ref.invalidate(bankAccountListProvider);
      ref.invalidate(bankTransactionsProvider(request.bankAccountId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reconcile(int id, int accountId) async {
    try {
      await ref.read(bankRepositoryProvider).reconcile(id);
      ref.invalidate(bankTransactionsProvider(accountId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unreconcile(int id, int accountId) async {
    try {
      await ref.read(bankRepositoryProvider).unreconcile(id);
      ref.invalidate(bankTransactionsProvider(accountId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> voidTransaction(int id, int accountId) async {
    try {
      await ref.read(bankRepositoryProvider).voidTransaction(id);
      ref.invalidate(bankTransactionsProvider(accountId));
      ref.invalidate(bankAccountListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> transfer(BankTransferRequest request) async {
    try {
      await ref.read(bankRepositoryProvider).transfer(request);
      ref.invalidate(bankAccountListProvider);
      ref.invalidate(bankTransactionsProvider(request.fromBankAccountId));
      ref.invalidate(bankTransactionsProvider(request.toBankAccountId));
      return true;
    } catch (_) {
      return false;
    }
  }
}

final bankTransactionActionsProvider = NotifierProvider<BankTransactionActionsNotifier, AsyncValue<void>>(BankTransactionActionsNotifier.new);