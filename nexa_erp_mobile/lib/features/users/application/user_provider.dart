import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_repository.dart';
import '../data/user_models.dart';
import '../../../core/network/providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRepository(dio);
});

class UserFilter {
  final String search;
  final UserStatus? status;
  UserFilter({this.search = '', this.status});
  UserFilter copyWith({String? search, UserStatus? status, bool clearStatus = false}) =>
      UserFilter(search: search ?? this.search, status: clearStatus ? null : (status ?? this.status));
}

final userFilterProvider = StateProvider.autoDispose<UserFilter>((ref) => UserFilter());

class UserListState {
  final List<AppUser> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  UserListState({required this.items, required this.page, required this.hasMore, this.isLoadingMore = false});
  UserListState copyWith({List<AppUser>? items, int? page, bool? hasMore, bool? isLoadingMore}) => UserListState(
    items: items ?? this.items, page: page ?? this.page, hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class UserListNotifier extends AsyncNotifier<UserListState> {
  static const _pageSize = 20;

  @override
  Future<UserListState> build() async {
    final filter = ref.watch(userFilterProvider);
    final repo = ref.read(userRepositoryProvider);
    final result = await repo.getAll(page: 0, size: _pageSize, search: filter.search, status: filter.status);
    return UserListState(items: result.content, page: 0, hasMore: !result.last);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final filter = ref.read(userFilterProvider);
    final repo = ref.read(userRepositoryProvider);
    final nextPage = current.page + 1;
    final result = await repo.getAll(page: nextPage, size: _pageSize, search: filter.search, status: filter.status);
    state = AsyncData(current.copyWith(
      items: [...current.items, ...result.content], page: nextPage, hasMore: !result.last, isLoadingMore: false,
    ));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final userListProvider = AsyncNotifierProvider<UserListNotifier, UserListState>(UserListNotifier.new);

class UserActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create(UserRequest request) async {
    try {
      await ref.read(userRepositoryProvider).create(request);
      ref.invalidate(userListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(int id, UserRequest request) async {
    try {
      await ref.read(userRepositoryProvider).update(id, request);
      ref.invalidate(userListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleActive(AppUser user) async {
    try {
      final repo = ref.read(userRepositoryProvider);
      if (user.status == UserStatus.active) {
        await repo.deactivate(user.id);
      } else {
        await repo.activate(user.id);
      }
      ref.invalidate(userListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final userActionsProvider = NotifierProvider<UserActionsNotifier, AsyncValue<void>>(UserActionsNotifier.new);