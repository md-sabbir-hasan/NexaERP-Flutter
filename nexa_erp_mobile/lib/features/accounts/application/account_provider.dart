import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/account_repository.dart';
import '../data/account_models.dart';
import '../../../core/network/providers.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AccountRepository(dio);
});

// Tree view data (default view)
final accountTreeProvider = FutureProvider.autoDispose<List<AccountModel>>((ref) async {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.getTree();
});

// Search/filter state
class AccountFilter {
  final String keyword;
  final AccountType? type;
  final bool? active;
  AccountFilter({this.keyword = '', this.type, this.active});

  AccountFilter copyWith({String? keyword, AccountType? type, bool? active, bool clearType = false}) =>
      AccountFilter(
        keyword: keyword ?? this.keyword,
        type: clearType ? null : (type ?? this.type),
        active: active ?? this.active,
      );
}

final accountFilterProvider = StateProvider.autoDispose<AccountFilter>((ref) => AccountFilter());

final accountSearchResultProvider = FutureProvider.autoDispose<List<AccountModel>>((ref) async {
  final filter = ref.watch(accountFilterProvider);
  final repo = ref.watch(accountRepositoryProvider);

  // filter খালি হলে tree view দেখাবো, নাহলে search API কল করব
  if (filter.keyword.isEmpty && filter.type == null && filter.active == null) {
    return repo.getTree();
  }
  return repo.search(keyword: filter.keyword, type: filter.type, active: filter.active);
});

// Create/Update actions notifier
class AccountActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create(AccountRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(accountRepositoryProvider);
      await repo.create(request);
      state = const AsyncData(null);
      ref.invalidate(accountTreeProvider);
      ref.invalidate(accountSearchResultProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> update(int id, AccountRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(accountRepositoryProvider);
      await repo.update(id, request);
      state = const AsyncData(null);
      ref.invalidate(accountTreeProvider);
      ref.invalidate(accountSearchResultProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> toggleActive(AccountModel account) async {
    try {
      final repo = ref.read(accountRepositoryProvider);
      if (account.isActive) {
        await repo.deactivate(account.id);
      } else {
        await repo.activate(account.id);
      }
      ref.invalidate(accountTreeProvider);
      ref.invalidate(accountSearchResultProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final accountActionsProvider = NotifierProvider<AccountActionsNotifier, AsyncValue<void>>(
  AccountActionsNotifier.new,
);