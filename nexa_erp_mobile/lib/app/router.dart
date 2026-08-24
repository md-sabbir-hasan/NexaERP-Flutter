import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexa_erp_mobile/features/approvals/presentation/approvals_screen.dart';
import 'package:nexa_erp_mobile/features/expense/presentation/expense_list_screen.dart';
import 'package:nexa_erp_mobile/features/invoice/presentation/invoice_list_screen.dart';
import 'package:nexa_erp_mobile/features/journal/presentation/journal_list_screen.dart';
import 'package:nexa_erp_mobile/features/users/presentation/roles_screen.dart';
import 'package:nexa_erp_mobile/features/users/presentation/users_screen.dart';
import '../features/auth/application/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/notifications/presentation/notification_screen.dart';
import '../features/accounts/presentation/accounts_placeholder_screen.dart';
import '../features/reports/presentation/reports_placeholder_screen.dart';
import '../features/more/presentation/more_screen.dart';
import 'shell/main_shell.dart';

class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRouterRefresh(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
      GoRoute(path: '/journals', builder: (_, __) => const JournalListScreen()),
      GoRoute(path: '/approvals', builder: (_, __) => const ApprovalsScreen()),
      GoRoute(path: '/users', builder: (_, __) => const UsersScreen()),
      GoRoute(path: '/roles', builder: (_, __) => const RolesScreen()),
      GoRoute(path: '/expenses', builder: (_, __) => const ExpenseListScreen()),
      GoRoute(path: '/invoices', builder: (_, __) => const InvoiceListScreen()),

      // Bottom-nav shell (persistent state per tab)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/accounts', builder: (_, __) => const AccountsPlaceholderScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/reports', builder: (_, __) => const ReportsPlaceholderScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
          ]),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading && !authState.hasValue && !authState.hasError;
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