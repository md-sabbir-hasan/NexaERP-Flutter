import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_erp_mobile/core/network/providers.dart';
import 'package:nexa_erp_mobile/features/notifications/data/notification_models.dart';
import 'package:nexa_erp_mobile/features/notifications/data/notification_repository.dart';
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(dio);
});

// Badge count — auto-refresh এর জন্য পরে periodic timer add করা যাবে
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadCount();
});

class NotificationListState {
  final List<AppNotification> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  NotificationListState({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  NotificationListState copyWith({
    List<AppNotification>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) => NotificationListState(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class NotificationListNotifier extends AsyncNotifier<NotificationListState> {
  static const _pageSize = 20;

  @override
  Future<NotificationListState> build() async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.getNotifications(page: 0, size: _pageSize);
    return NotificationListState(
      items: result.content,
      page: 0,
      hasMore: !result.last,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final repo = ref.read(notificationRepositoryProvider);
    final nextPage = current.page + 1;
    final result = await repo.getNotifications(page: nextPage, size: _pageSize);

    state = AsyncData(current.copyWith(
      items: [...current.items, ...result.content],
      page: nextPage,
      hasMore: !result.last,
      isLoadingMore: false,
    ));
  }

  Future<void> markAsRead(int id) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAsRead(id);

    final updated = current.items.map((n) {
      return n.id == id ? n.copyWith(read: true, readAt: DateTime.now()) : n;
    }).toList();

    state = AsyncData(current.copyWith(items: updated));
    ref.invalidate(unreadCountProvider);
  }

  Future<void> markAllAsRead() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllAsRead();

    final updated = current.items.map((n) => n.copyWith(read: true)).toList();
    state = AsyncData(current.copyWith(items: updated));
    ref.invalidate(unreadCountProvider);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final notificationListProvider =
AsyncNotifierProvider<NotificationListNotifier, NotificationListState>(
  NotificationListNotifier.new,
);