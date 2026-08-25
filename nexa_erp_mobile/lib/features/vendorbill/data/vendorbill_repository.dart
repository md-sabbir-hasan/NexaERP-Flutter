import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'vendorbill_models.dart';

class VendorBillRepository {
  final Dio _dio;
  VendorBillRepository(this._dio);

  Future<List<VendorBillModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.vendorBills);
    final apiResponse = ApiResponse<List<VendorBillModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => VendorBillModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<VendorBillModel> create(VendorBillRequest request) async {
    final response = await _dio.post(ApiEndpoints.vendorBills, data: request.toJson());
    final apiResponse = ApiResponse<VendorBillModel>.fromJson(response.data, (json) => VendorBillModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<VendorBillModel> approve(int id) async {
    final response = await _dio.post(ApiEndpoints.vendorBillApprove(id));
    final apiResponse = ApiResponse<VendorBillModel>.fromJson(response.data, (json) => VendorBillModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<void> submitApproval(int id) async {
    await _dio.post(ApiEndpoints.vendorBillSubmitApproval(id));
  }

  Future<VendorBillModel> post(int id) async {
    final response = await _dio.post(ApiEndpoints.vendorBillPost(id));
    final apiResponse = ApiResponse<VendorBillModel>.fromJson(response.data, (json) => VendorBillModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<VendorBillModel> cancel(int id, VendorBillCancelledReason reason) async {
    final response = await _dio.post(ApiEndpoints.vendorBillCancel(id), queryParameters: {'reason': reason.backendValue});
    final apiResponse = ApiResponse<VendorBillModel>.fromJson(response.data, (json) => VendorBillModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }
}