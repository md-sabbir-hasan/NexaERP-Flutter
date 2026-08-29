import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'fixedasset_models.dart';

class FixedAssetRepository {
  final Dio _dio;
  FixedAssetRepository(this._dio);

  Future<List<FixedAssetModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.fixedAssets);
    final apiResponse = ApiResponse<List<FixedAssetModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => FixedAssetModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<FixedAssetModel> create(FixedAssetRequest request) async {
    final response = await _dio.post(ApiEndpoints.fixedAssets, data: request.toJson());
    final apiResponse = ApiResponse<FixedAssetModel>.fromJson(response.data, (json) => FixedAssetModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<List<DepreciationEntry>> getDepreciationHistory(int id) async {
    final response = await _dio.get(ApiEndpoints.fixedAssetDepreciationHistory(id));
    final apiResponse = ApiResponse<List<DepreciationEntry>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => DepreciationEntry.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<DepreciationEntry> runDepreciation(int id, DateTime asOfDate) async {
    final dateStr = '${asOfDate.year.toString().padLeft(4, '0')}-${asOfDate.month.toString().padLeft(2, '0')}-${asOfDate.day.toString().padLeft(2, '0')}';
    final response = await _dio.post(ApiEndpoints.fixedAssetRunDepreciation(id), data: {'asOfDate': dateStr});
    final apiResponse = ApiResponse<DepreciationEntry>.fromJson(response.data, (json) => DepreciationEntry.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<List<DepreciationEntry>> runDepreciationForAll(DateTime asOfDate) async {
    final dateStr = '${asOfDate.year.toString().padLeft(4, '0')}-${asOfDate.month.toString().padLeft(2, '0')}-${asOfDate.day.toString().padLeft(2, '0')}';
    final response = await _dio.post(ApiEndpoints.fixedAssetRunDepreciationAll, queryParameters: {'asOfDate': dateStr});
    final apiResponse = ApiResponse<List<DepreciationEntry>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => DepreciationEntry.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<FixedAssetModel> dispose(int id, AssetDisposalRequest request) async {
    final response = await _dio.post(ApiEndpoints.fixedAssetDispose(id), data: request.toJson());
    final apiResponse = ApiResponse<FixedAssetModel>.fromJson(response.data, (json) => FixedAssetModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }
}