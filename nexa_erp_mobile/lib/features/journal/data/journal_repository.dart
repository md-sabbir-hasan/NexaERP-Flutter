import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'journal_models.dart';

class JournalRepository {
  final Dio _dio;
  JournalRepository(this._dio);

  Future<List<JournalEntry>> getAll() async {
    final response = await _dio.get(ApiEndpoints.journals);
    final apiResponse = ApiResponse<List<JournalEntry>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<JournalEntry> getById(int id) async {
    final response = await _dio.get(ApiEndpoints.journalById(id));
    final apiResponse = ApiResponse<JournalEntry>.fromJson(
      response.data,
          (json) => JournalEntry.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<JournalEntry> create(JournalEntryRequest request) async {
    final response = await _dio.post(ApiEndpoints.journals, data: request.toJson());
    final apiResponse = ApiResponse<JournalEntry>.fromJson(
      response.data,
          (json) => JournalEntry.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<JournalEntry> update(int id, JournalEntryRequest request) async {
    final response = await _dio.put(ApiEndpoints.journalById(id), data: request.toJson());
    final apiResponse = ApiResponse<JournalEntry>.fromJson(
      response.data,
          (json) => JournalEntry.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<JournalEntry> post(int id) async {
    final response = await _dio.post(ApiEndpoints.journalPost(id));
    final apiResponse = ApiResponse<JournalEntry>.fromJson(
      response.data,
          (json) => JournalEntry.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<void> submitApproval(int id) async {
    await _dio.post(ApiEndpoints.journalSubmitApproval(id));
  }

  Future<JournalEntry> reverse(int id) async {
    final response = await _dio.post(ApiEndpoints.journalReverse(id));
    final apiResponse = ApiResponse<JournalEntry>.fromJson(
      response.data,
          (json) => JournalEntry.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<void> delete(int id) async {
    await _dio.delete(ApiEndpoints.journalById(id));
  }
}