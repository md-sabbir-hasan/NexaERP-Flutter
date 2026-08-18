import 'package:dio/dio.dart';
import 'package:nexa_erp_mobile/core/models/api_response.dart';
import 'package:nexa_erp_mobile/core/network/api_endpoints.dart';

import 'dashboard_models.dart';

class DashboardRepository {
  final Dio _dio;
  DashboardRepository(this._dio);

  Future<DashboardSummary> getSummary() async {
    final response = await _dio.get(ApiEndpoints.dashboardSummary);
    final apiResponse = ApiResponse<DashboardSummary>.fromJson(
      response.data,
          (json) => DashboardSummary.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<DashboardWorkflowSummary> getWorkflowSummary() async {
    final response = await _dio.get(ApiEndpoints.dashboardWorkflow);
    final apiResponse = ApiResponse<DashboardWorkflowSummary>.fromJson(
      response.data,
          (json) => DashboardWorkflowSummary.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }
}