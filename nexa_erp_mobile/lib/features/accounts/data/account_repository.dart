import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'account_models.dart';

class AccountRepository {
  final Dio _dio;
  AccountRepository(this._dio);

  Future<List<AccountModel>> getAll() async {
    final response = await _dio.get(ApiEndpoints.accounts);
    return _parseList(response.data);
  }

  Future<List<AccountModel>> getTree() async {
    final response = await _dio.get(ApiEndpoints.accountsTree);
    return _parseList(response.data);
  }

  Future<List<AccountModel>> search({String? keyword, AccountType? type, bool? active}) async {
    final response = await _dio.get(ApiEndpoints.accountsSearch, queryParameters: {
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (type != null) 'type': type.backendValue,
      if (active != null) 'active': active,
    });
    return _parseList(response.data);
  }

  Future<AccountModel> getById(int id) async {
    final response = await _dio.get(ApiEndpoints.accountById(id));
    final apiResponse = ApiResponse<AccountModel>.fromJson(
      response.data,
          (json) => AccountModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<AccountModel> create(AccountRequest request) async {
    final response = await _dio.post(ApiEndpoints.accounts, data: request.toJson());
    final apiResponse = ApiResponse<AccountModel>.fromJson(
      response.data,
          (json) => AccountModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<AccountModel> update(int id, AccountRequest request) async {
    final response = await _dio.put(ApiEndpoints.accountById(id), data: request.toJson());
    final apiResponse = ApiResponse<AccountModel>.fromJson(
      response.data,
          (json) => AccountModel.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<void> deactivate(int id) async {
    await _dio.patch(ApiEndpoints.accountDeactivate(id));
  }

  Future<void> activate(int id) async {
    await _dio.patch(ApiEndpoints.accountActivate(id));
  }

  List<AccountModel> _parseList(dynamic data) {
    final apiResponse = ApiResponse<List<AccountModel>>.fromJson(
      data,
          (json) => (json as List).map((e) => AccountModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }
}