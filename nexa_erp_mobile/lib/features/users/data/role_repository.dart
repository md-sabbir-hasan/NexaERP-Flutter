import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'role_models.dart';

class RoleRepository {
  final Dio _dio;
  RoleRepository(this._dio);

  Future<List<RoleModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.roles);
    final apiResponse = ApiResponse<List<RoleModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => RoleModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<RoleModel> create(RoleRequest request) async {
    final response = await _dio.post(ApiEndpoints.roles, data: request.toJson());
    final apiResponse = ApiResponse<RoleModel>.fromJson(response.data, (json) => RoleModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<RoleModel> update(int id, RoleRequest request) async {
    final response = await _dio.put(ApiEndpoints.roleById(id), data: request.toJson());
    final apiResponse = ApiResponse<RoleModel>.fromJson(response.data, (json) => RoleModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<List<PermissionModel>> getAllPermissions() async {
    final response = await _dio.get(ApiEndpoints.permissions);
    final apiResponse = ApiResponse<List<PermissionModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => PermissionModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }
}