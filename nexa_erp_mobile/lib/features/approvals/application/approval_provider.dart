import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/approval_repository.dart';
import '../data/approval_models.dart';
import '../../../core/network/providers.dart';

final approvalRepositoryProvider = Provider<ApprovalRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApprovalRepository(dio);
});

final approvalPendingCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(approvalRepositoryProvider);
  return repo.getPendingCount();
});

enum ApprovalTab { pending, myRequests }

class ApprovalListState {
  final List<ApprovalRequest> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  ApprovalListState({required this.items, required this.page, required this.hasMore, this.isLoadingMore = false});

  ApprovalListState copyWith({List<ApprovalRequest>? items, int? page, bool? hasMore, bool? isLoadingMore}) =>
      ApprovalListState(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class ApprovalListNotifier extends FamilyAsyncNotifier<ApprovalListState, ApprovalTab> {
  static const _pageSize = 20;

  @override
  Future<ApprovalListState> build(ApprovalTab arg) async {
    final repo = ref.read(approvalRepositoryProvider);
    final result = arg == ApprovalTab.pending
        ? await repo.getPending(page: 0, size: _pageSize)
        : await repo.getMyRequests(page: 0, size: _pageSize);
    return ApprovalListState(items: result.content, page: 0, hasMore: !result.last);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final repo = ref.read(approvalRepositoryProvider);
    final nextPage = current.page + 1;
    final result = arg == ApprovalTab.pending
        ? await repo.getPending(page: nextPage, size: _pageSize)
        : await repo.getMyRequests(page: nextPage, size: _pageSize);

    state = AsyncData(current.copyWith(
      items: [...current.items, ...result.content],
      page: nextPage,
      hasMore: !result.last,
      isLoadingMore: false,
    ));
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  void removeItem(int approvalId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(items: current.items.where((a) => a.id != approvalId).toList()));
  }
}

final approvalListProvider =
AsyncNotifierProvider.family<ApprovalListNotifier, ApprovalListState, ApprovalTab>(
  ApprovalListNotifier.new,
);

class ApprovalActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> approve(int id, {String? comment}) async {
    try {
      final repo = ref.read(approvalRepositoryProvider);
      await repo.approve(id, comment: comment);
      ref.read(approvalListProvider(ApprovalTab.pending).notifier).removeItem(id);
      ref.invalidate(approvalPendingCountProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reject(int id, String comment) async {
    try {
      final repo = ref.read(approvalRepositoryProvider);
      await repo.reject(id, comment);
      ref.read(approvalListProvider(ApprovalTab.pending).notifier).removeItem(id);
      ref.invalidate(approvalPendingCountProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> returnForCorrection(int id, String comment) async {
    try {
      final repo = ref.read(approvalRepositoryProvider);
      await repo.returnForCorrection(id, comment);
      ref.read(approvalListProvider(ApprovalTab.pending).notifier).removeItem(id);
      ref.invalidate(approvalPendingCountProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final approvalActionsProvider = NotifierProvider<ApprovalActionsNotifier, AsyncValue<void>>(
  ApprovalActionsNotifier.new,
);