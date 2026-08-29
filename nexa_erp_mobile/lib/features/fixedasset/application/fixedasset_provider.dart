import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/fixedasset_repository.dart';
import '../data/fixedasset_models.dart';
import '../../../core/network/providers.dart';

final fixedAssetRepositoryProvider = Provider<FixedAssetRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FixedAssetRepository(dio);
});

final fixedAssetListProvider = FutureProvider.autoDispose<List<FixedAssetModel>>((ref) async {
  final repo = ref.watch(fixedAssetRepositoryProvider);
  return repo.getAll();
});

final depreciationHistoryProvider = FutureProvider.family.autoDispose<List<DepreciationEntry>, int>((ref, assetId) async {
  final repo = ref.watch(fixedAssetRepositoryProvider);
  return repo.getDepreciationHistory(assetId);
});

class FixedAssetActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create(FixedAssetRequest request) async {
    try {
      await ref.read(fixedAssetRepositoryProvider).create(request);
      ref.invalidate(fixedAssetListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> runDepreciation(int id, DateTime asOfDate) async {
    try {
      await ref.read(fixedAssetRepositoryProvider).runDepreciation(id, asOfDate);
      ref.invalidate(fixedAssetListProvider);
      ref.invalidate(depreciationHistoryProvider(id));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> runDepreciationForAll(DateTime asOfDate) async {
    try {
      await ref.read(fixedAssetRepositoryProvider).runDepreciationForAll(asOfDate);
      ref.invalidate(fixedAssetListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> dispose(int id, AssetDisposalRequest request) async {
    try {
      await ref.read(fixedAssetRepositoryProvider).dispose(id, request);
      ref.invalidate(fixedAssetListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final fixedAssetActionsProvider = NotifierProvider<FixedAssetActionsNotifier, AsyncValue<void>>(FixedAssetActionsNotifier.new);