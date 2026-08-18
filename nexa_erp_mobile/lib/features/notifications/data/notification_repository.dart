import 'package:dio/dio.dart';
import 'package:nexa_erp_mobile/core/models/api_response.dart';
import 'package:nexa_erp_mobile/core/models/page_response.dart';
import 'package:nexa_erp_mobile/core/network/api_endpoints.dart';
import 'notification_models.dart';

class NotificationRepository {
  final Dio _dio;
  NotificationRepository(this._dio);

  Future<PageResponse<AppNotification>> getNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'size': size, 'unreadOnly': unreadOnly},
    );
    final apiResponse = ApiResponse<PageResponse<AppNotification>>.fromJson(
      response.data,
          (json) => PageResponse.fromJson(
        json as Map<String, dynamic>,
            (item) => AppNotification.fromJson(item),
      ),
    );
    return apiResponse.data!;
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiEndpoints.unreadCount);
    final apiResponse = ApiResponse<int>.fromJson(response.data, (json) => json as int);
    return apiResponse.data ?? 0;
  }

  Future<AppNotification> markAsRead(int id) async {
    final response = await _dio.patch(ApiEndpoints.markRead(id));
    final apiResponse = ApiResponse<AppNotification>.fromJson(
      response.data,
          (json) => AppNotification.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<void> markAllAsRead() async {
    await _dio.patch(ApiEndpoints.markAllRead);
  }
}