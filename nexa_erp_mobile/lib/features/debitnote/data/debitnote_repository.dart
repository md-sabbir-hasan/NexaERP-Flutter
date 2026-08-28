import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'debitnote_models.dart';

class DebitNoteRepository {
  final Dio _dio;
  DebitNoteRepository(this._dio);

  Future<List<DebitNoteModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.debitNotes);
    final apiResponse = ApiResponse<List<DebitNoteModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => DebitNoteModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<DebitNoteModel> create(DebitNoteRequest request) async {
    final response = await _dio.post(ApiEndpoints.debitNotes, data: request.toJson());
    final apiResponse = ApiResponse<DebitNoteModel>.fromJson(response.data, (json) => DebitNoteModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<DebitNoteModel> approve(int id) async {
    final response = await _dio.patch(ApiEndpoints.debitNoteApprove(id));
    final apiResponse = ApiResponse<DebitNoteModel>.fromJson(response.data, (json) => DebitNoteModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<DebitNoteModel> post(int id) async {
    final response = await _dio.patch(ApiEndpoints.debitNotePost(id));
    final apiResponse = ApiResponse<DebitNoteModel>.fromJson(response.data, (json) => DebitNoteModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<DebitNoteModel> cancel(int id, DebitNoteCancelledReason reason) async {
    final response = await _dio.patch(ApiEndpoints.debitNoteCancel(id), queryParameters: {'reason': reason.backendValue});
    final apiResponse = ApiResponse<DebitNoteModel>.fromJson(response.data, (json) => DebitNoteModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }
}