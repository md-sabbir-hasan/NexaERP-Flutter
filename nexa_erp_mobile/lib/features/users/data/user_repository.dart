import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/page_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'user_models.dart';

class UserRepository {
  final Dio _dio;
  UserRepository(this._dio);

  Future<PageResponse<AppUser>> getAll({int page = 0, int size = 20, String? search, UserStatus? status}) async {
    final response = await _dio.get(ApiEndpoints.users, queryParameters: {
      'page': page,
      'size': size,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status.name.toUpperCase(),
    });
    final apiResponse = ApiResponse<PageResponse<AppUser>>.fromJson(
      response.data,
          (json) => PageResponse.fromJson(json as Map<String, dynamic>, (item) => AppUser.fromJson(item)),
    );
    return apiResponse.data!;
  }

  Future<AppUser> create(UserRequest request) async {
    final response = await _dio.post(ApiEndpoints.users, data: request.toJson());
    final apiResponse = ApiResponse<AppUser>.fromJson(response.data, (json) => AppUser.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<AppUser> update(int id, UserRequest request) async {
    final response = await _dio.put(ApiEndpoints.userById(id), data: request.toJson());
    final apiResponse = ApiResponse<AppUser>.fromJson(response.data, (json) => AppUser.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<void> deactivate(int id) async => _dio.patch(ApiEndpoints.userDeactivate(id));
  Future<void> activate(int id) async => _dio.patch(ApiEndpoints.userActivate(id));
}