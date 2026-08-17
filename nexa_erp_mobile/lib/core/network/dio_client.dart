import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  final Dio dio;

  DioClient(SecureStorageService storage)
      : dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  ) {
    dio.interceptors.add(AuthInterceptor(dio, storage));
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
}