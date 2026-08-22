import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/journal_repository.dart';
import '../data/journal_models.dart';
import '../../../core/network/providers.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return JournalRepository(dio);
});

final journalListProvider = FutureProvider.autoDispose<List<JournalEntry>>((ref) async {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.getAll();
});

final journalStatusFilterProvider = StateProvider.autoDispose<JournalStatus?>((ref) => null);

final filteredJournalListProvider = Provider.autoDispose<AsyncValue<List<JournalEntry>>>((ref) {
  final listAsync = ref.watch(journalListProvider);
  final statusFilter = ref.watch(journalStatusFilterProvider);

  return listAsync.whenData((list) {
    if (statusFilter == null) return list;
    return list.where((j) => j.status == statusFilter).toList();
  });
});

class JournalActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<JournalEntry?> create(JournalEntryRequest request) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(journalRepositoryProvider);
      final result = await repo.create(request);
      state = const AsyncData(null);
      ref.invalidate(journalListProvider);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<bool> post(int id) async {
    try {
      final repo = ref.read(journalRepositoryProvider);
      await repo.post(id);
      ref.invalidate(journalListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitApproval(int id) async {
    try {
      final repo = ref.read(journalRepositoryProvider);
      await repo.submitApproval(id);
      ref.invalidate(journalListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reverse(int id) async {
    try {
      final repo = ref.read(journalRepositoryProvider);
      await repo.reverse(id);
      ref.invalidate(journalListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      final repo = ref.read(journalRepositoryProvider);
      await repo.delete(id);
      ref.invalidate(journalListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final journalActionsProvider = NotifierProvider<JournalActionsNotifier, AsyncValue<void>>(
  JournalActionsNotifier.new,
);