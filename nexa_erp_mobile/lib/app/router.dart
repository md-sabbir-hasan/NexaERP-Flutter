import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexa_erp_mobile/features/auth/application/auth_provider.dart';
import 'package:nexa_erp_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:nexa_erp_mobile/features/splash/presentation/login_screen.dart';
import 'package:nexa_erp_mobile/features/splash/presentation/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    ],
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.valueOrNull != null;
      final goingToSplash = state.matchedLocation == '/splash';
      final goingToLogin = state.matchedLocation == '/login';

      if (isLoading) return goingToSplash ? null : '/splash';
      if (!isLoggedIn) return goingToLogin ? null : '/login';
      if (isLoggedIn && (goingToLogin || goingToSplash)) return '/dashboard';
      return null;
    },
  );
});