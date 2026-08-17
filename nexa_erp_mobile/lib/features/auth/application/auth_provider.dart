import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_erp_mobile/core/network/providers.dart';
import 'package:nexa_erp_mobile/features/auth/data/auth_models.dart';
import 'package:nexa_erp_mobile/features/auth/data/auth_repository.dart';


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

// null = logged out, CurrentUser = logged in
class AuthNotifier extends AsyncNotifier<CurrentUser?> {
  @override
  Future<CurrentUser?> build() async {
    final storage = ref.watch(secureStorageProvider);
    final hasSession = await storage.hasValidSession();
    if (!hasSession) return null;

    try {
      final repo = ref.read(authRepositoryProvider);
      return await repo.getCurrentUser();
    } catch (_) {
      await storage.clearTokens();
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final storage = ref.read(secureStorageProvider);
    final repo = ref.read(authRepositoryProvider);

    try {
      final loginRes = await repo.login(email, password);
      await storage.saveTokens(
        accessToken: loginRes.accessToken,
        refreshToken: loginRes.refreshToken,
      );
      final user = await repo.getCurrentUser();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.logout();
    } catch (_) {
      // network fail - local session clear
    }
    await storage.clearTokens();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, CurrentUser?>(
  AuthNotifier.new,
);

// permission check helper
final hasPermissionProvider = Provider.family<bool, String>((ref, code) {
  final user = ref.watch(authProvider).valueOrNull;
  return user?.hasPermission(code) ?? false;
});