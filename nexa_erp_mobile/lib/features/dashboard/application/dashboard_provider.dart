import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_erp_mobile/core/network/providers.dart';
import 'package:nexa_erp_mobile/features/dashboard/data/dashboard_models.dart';
import 'package:nexa_erp_mobile/features/dashboard/data/dashboard_repository.dart';


final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRepository(dio);
});

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getSummary();
});

final dashboardWorkflowProvider = FutureProvider.autoDispose<DashboardWorkflowSummary>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getWorkflowSummary();
});