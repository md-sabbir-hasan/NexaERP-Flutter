import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _storage;
  bool _isRefreshing = false;

  AuthInterceptor(this._dio, this._storage);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // login/refresh call এ token attach করার দরকার নেই
    if (!options.path.contains('/auth/login') &&
        !options.path.contains('/auth/refresh')) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    // 401 হলে refresh token দিয়ে নতুন access token নিয়ে original request retry
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null) {
          await _storage.clearTokens();
          _isRefreshing = false;
          handler.next(err);
          return;
        }

        final response = await _dio.post(
          ApiEndpoints.refresh,
          data: {'refreshToken': refreshToken},
        );

        final data = response.data['data'];
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        await _storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // original failed request retry
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(retryOptions);

        _isRefreshing = false;
        handler.resolve(retryResponse);
        return;
      } catch (_) {
        await _storage.clearTokens();
        _isRefreshing = false;
        handler.next(err);
        return;
      }
    }
    handler.next(err);
  }
}