import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'payment_models.dart';

class PaymentRepository {
  final Dio _dio;
  PaymentRepository(this._dio);

  Future<List<PaymentModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.payments);
    final apiResponse = ApiResponse<List<PaymentModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<PaymentModel> create(PaymentRequest request) async {
    final response = await _dio.post(ApiEndpoints.payments, data: request.toJson());
    final apiResponse = ApiResponse<PaymentModel>.fromJson(response.data, (json) => PaymentModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<PaymentModel> post(int id) async {
    final response = await _dio.post(ApiEndpoints.paymentPost(id));
    final apiResponse = ApiResponse<PaymentModel>.fromJson(response.data, (json) => PaymentModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<void> submitApproval(int id) async {
    await _dio.post(ApiEndpoints.paymentSubmitApproval(id));
  }

  Future<PaymentModel> cancel(int id) async {
    final response = await _dio.post(ApiEndpoints.paymentCancel(id));
    final apiResponse = ApiResponse<PaymentModel>.fromJson(response.data, (json) => PaymentModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }
}