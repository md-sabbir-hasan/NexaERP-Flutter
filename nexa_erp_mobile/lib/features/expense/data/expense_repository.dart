import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'expense_models.dart';

class ExpenseRepository {
  final Dio _dio;
  ExpenseRepository(this._dio);

  Future<List<ExpenseModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.expenses);
    final apiResponse = ApiResponse<List<ExpenseModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<ExpenseModel> create(ExpenseRequest request) async {
    final response = await _dio.post(ApiEndpoints.expenses, data: request.toJson());
    final apiResponse = ApiResponse<ExpenseModel>.fromJson(response.data, (json) => ExpenseModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<ExpenseModel> post(int id) async {
    final response = await _dio.post(ApiEndpoints.expensePost(id));
    final apiResponse = ApiResponse<ExpenseModel>.fromJson(response.data, (json) => ExpenseModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<ExpenseModel> cancel(int id, String reason) async {
    final response = await _dio.post(ApiEndpoints.expenseCancel(id), data: {'reason': reason});
    final apiResponse = ApiResponse<ExpenseModel>.fromJson(response.data, (json) => ExpenseModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }
}