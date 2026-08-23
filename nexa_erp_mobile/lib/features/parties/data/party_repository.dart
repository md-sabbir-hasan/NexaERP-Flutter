import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'party_models.dart';

class PartyRepository {
  final Dio _dio;
  PartyRepository(this._dio);

  Future<List<PartyModel>> getByType(String type) async {
    final response = await _dio.get(ApiEndpoints.partiesByType(type));
    final apiResponse = ApiResponse<List<PartyModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => PartyModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }
}