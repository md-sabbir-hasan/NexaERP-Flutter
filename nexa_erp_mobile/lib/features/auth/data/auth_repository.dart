import 'package:dio/dio.dart';
import 'package:nexa_erp_mobile/core/models/api_response.dart';
import 'package:nexa_erp_mobile/core/network/api_endpoints.dart';

import 'auth_models.dart';

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  Future<LoginResponse> login(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: LoginRequest(email: email, password: password).toJson(),
    );
    final apiResponse = ApiResponse<LoginResponse>.fromJson(
      response.data,
          (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<CurrentUser> getCurrentUser() async {
    final response = await _dio.get(ApiEndpoints.me);
    final apiResponse = ApiResponse<CurrentUser>.fromJson(
      response.data,
          (json) => CurrentUser.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }
}