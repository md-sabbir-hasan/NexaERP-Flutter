import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'creditnote_models.dart';

class CreditNoteRepository {
  final Dio _dio;
  CreditNoteRepository(this._dio);

  Future<List<CreditNoteModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.creditNotes);
    final apiResponse = ApiResponse<List<CreditNoteModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => CreditNoteModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<CreditNoteModel> create(CreditNoteRequest request) async {
    final response = await _dio.post(ApiEndpoints.creditNotes, data: request.toJson());
    final apiResponse = ApiResponse<CreditNoteModel>.fromJson(response.data, (json) => CreditNoteModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<CreditNoteModel> approve(int id) async {
    final response = await _dio.patch(ApiEndpoints.creditNoteApprove(id));
    final apiResponse = ApiResponse<CreditNoteModel>.fromJson(response.data, (json) => CreditNoteModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<CreditNoteModel> post(int id) async {
    final response = await _dio.patch(ApiEndpoints.creditNotePost(id));
    final apiResponse = ApiResponse<CreditNoteModel>.fromJson(response.data, (json) => CreditNoteModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<CreditNoteModel> cancel(int id, CreditNoteCancelledReason reason) async {
    final response = await _dio.patch(ApiEndpoints.creditNoteCancel(id), queryParameters: {'reason': reason.backendValue});
    final apiResponse = ApiResponse<CreditNoteModel>.fromJson(response.data, (json) => CreditNoteModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }
}