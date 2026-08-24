import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'invoice_models.dart';

class InvoiceRepository {
  final Dio _dio;
  InvoiceRepository(this._dio);

  Future<List<InvoiceModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.invoices);
    final apiResponse = ApiResponse<List<InvoiceModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<InvoiceModel> create(InvoiceRequest request) async {
    final response = await _dio.post(ApiEndpoints.invoices, data: request.toJson());
    final apiResponse = ApiResponse<InvoiceModel>.fromJson(response.data, (json) => InvoiceModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<InvoiceModel> post(int id) async {
    final response = await _dio.post(ApiEndpoints.invoicePost(id));
    final apiResponse = ApiResponse<InvoiceModel>.fromJson(response.data, (json) => InvoiceModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<InvoiceModel> cancel(int id, CancelledReason reason) async {
    final response = await _dio.post(
      ApiEndpoints.invoiceCancel(id),
      queryParameters: {'reason': reason.backendValue},
    );
    final apiResponse = ApiResponse<InvoiceModel>.fromJson(response.data, (json) => InvoiceModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<void> submitApproval(int id) async {
    await _dio.post(ApiEndpoints.invoiceSubmitApproval(id));
  }
}