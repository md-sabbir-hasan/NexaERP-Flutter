import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/report_repository.dart';
import '../data/report_models.dart';
import '../../../core/network/providers.dart';
import '../../accounts/data/account_models.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportRepository(dio);
});

// Trial Balance —as-of date
final trialBalanceDateProvider = StateProvider.autoDispose<DateTime>((ref) => DateTime.now());

final trialBalanceProvider = FutureProvider.autoDispose<TrialBalanceReport>((ref) async {
  final date = ref.watch(trialBalanceDateProvider);
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getTrialBalance(date);
});

// Balance Sheet — as-of date
final balanceSheetDateProvider = StateProvider.autoDispose<DateTime>((ref) => DateTime.now());

final balanceSheetProvider = FutureProvider.autoDispose<BalanceSheetReport>((ref) async {
  final date = ref.watch(balanceSheetDateProvider);
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getBalanceSheet(date);
});

// Profit & Loss — date range
class DateRange {
  final DateTime from;
  final DateTime to;
  DateRange({required this.from, required this.to});
}

final profitLossRangeProvider = StateProvider.autoDispose<DateRange>((ref) {
  final now = DateTime.now();
  return DateRange(from: DateTime(now.year, now.month, 1), to: now);
});

final profitLossProvider = FutureProvider.autoDispose<ProfitLossReport>((ref) async {
  final range = ref.watch(profitLossRangeProvider);
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getProfitLoss(range.from, range.to);
});

// Ledger — account + date range
class LedgerParams {
  final AccountModel account;
  final DateTime from;
  final DateTime to;
  LedgerParams({required this.account, required this.from, required this.to});
}

final ledgerParamsProvider = StateProvider.autoDispose<LedgerParams?>((ref) => null);

final ledgerReportProvider = FutureProvider.autoDispose<LedgerReport?>((ref) async {
  final params = ref.watch(ledgerParamsProvider);
  if (params == null) return null;
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getLedger(params.account.id, params.from, params.to);
});