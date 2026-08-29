import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'bank_models.dart';

class BankRepository {
  final Dio _dio;
  BankRepository(this._dio);

  Future<List<BankAccountModel>> getAllAccounts() async {
    final response = await _dio.get(ApiEndpoints.bankAccounts);
    final apiResponse = ApiResponse<List<BankAccountModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => BankAccountModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<BankAccountModel> createAccount(BankAccountRequest request) async {
    final response = await _dio.post(ApiEndpoints.bankAccounts, data: request.toJson());
    final apiResponse = ApiResponse<BankAccountModel>.fromJson(response.data, (json) => BankAccountModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<BankAccountModel> updateAccount(int id, BankAccountRequest request) async {
    final response = await _dio.put(ApiEndpoints.bankAccountById(id), data: request.toJson());
    final apiResponse = ApiResponse<BankAccountModel>.fromJson(response.data, (json) => BankAccountModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<void> deactivateAccount(int id) async => _dio.patch(ApiEndpoints.bankAccountDeactivate(id));
  Future<void> activateAccount(int id) async => _dio.patch(ApiEndpoints.bankAccountActivate(id));

  Future<List<BankTransactionModel>> getTransactionsByAccount(int accountId) async {
    final response = await _dio.get(ApiEndpoints.bankTransactionsByAccount(accountId));
    final apiResponse = ApiResponse<List<BankTransactionModel>>.fromJson(
      response.data,
          (json) => (json as List).map((e) => BankTransactionModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
    return apiResponse.data ?? [];
  }

  Future<BankTransactionModel> createTransaction(BankTransactionRequest request) async {
    final response = await _dio.post(ApiEndpoints.bankTransactions, data: request.toJson());
    final apiResponse = ApiResponse<BankTransactionModel>.fromJson(response.data, (json) => BankTransactionModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<BankTransactionModel> reconcile(int id) async {
    final response = await _dio.patch(ApiEndpoints.bankTransactionReconcile(id));
    final apiResponse = ApiResponse<BankTransactionModel>.fromJson(response.data, (json) => BankTransactionModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<BankTransactionModel> unreconcile(int id) async {
    final response = await _dio.patch(ApiEndpoints.bankTransactionUnreconcile(id));
    final apiResponse = ApiResponse<BankTransactionModel>.fromJson(response.data, (json) => BankTransactionModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<BankTransactionModel> voidTransaction(int id) async {
    final response = await _dio.patch(ApiEndpoints.bankTransactionVoid(id));
    final apiResponse = ApiResponse<BankTransactionModel>.fromJson(response.data, (json) => BankTransactionModel.fromJson(json as Map<String, dynamic>));
    return apiResponse.data!;
  }

  Future<void> transfer(BankTransferRequest request) async {
    await _dio.post(ApiEndpoints.bankTransfer, data: request.toJson());
  }
}