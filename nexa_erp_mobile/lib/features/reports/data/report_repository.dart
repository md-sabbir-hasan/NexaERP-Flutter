import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'report_models.dart';

class ReportRepository {
  final Dio _dio;
  ReportRepository(this._dio);

  String _fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<TrialBalanceReport> getTrialBalance(DateTime asOfDate) async {
    final response = await _dio.get(ApiEndpoints.reportTrialBalance, queryParameters: {'asOfDate': _fmt(asOfDate)});
    final apiResponse = ApiResponse<TrialBalanceReport>.fromJson(response.data, (json) => TrialBalanceReport.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<ProfitLossReport> getProfitLoss(DateTime fromDate, DateTime toDate) async {
    final response = await _dio.get(ApiEndpoints.reportProfitLoss, queryParameters: {'fromDate': _fmt(fromDate), 'toDate': _fmt(toDate)});
    final apiResponse = ApiResponse<ProfitLossReport>.fromJson(response.data, (json) => ProfitLossReport.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<BalanceSheetReport> getBalanceSheet(DateTime asOfDate) async {
    final response = await _dio.get(ApiEndpoints.reportBalanceSheet, queryParameters: {'asOfDate': _fmt(asOfDate)});
    final apiResponse = ApiResponse<BalanceSheetReport>.fromJson(response.data, (json) => BalanceSheetReport.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<LedgerReport> getLedger(int accountId, DateTime fromDate, DateTime toDate) async {
    final response = await _dio.get(ApiEndpoints.reportLedger(accountId), queryParameters: {'fromDate': _fmt(fromDate), 'toDate': _fmt(toDate)});
    final apiResponse = ApiResponse<LedgerReport>.fromJson(response.data, (json) => LedgerReport.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }
}