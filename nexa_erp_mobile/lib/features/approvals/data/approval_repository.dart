import 'package:dio/dio.dart';
import '../../../core/models/api_response.dart';
import '../../../core/models/page_response.dart';
import '../../../core/network/api_endpoints.dart';
import 'approval_models.dart';

class ApprovalRepository {
  final Dio _dio;
  ApprovalRepository(this._dio);

  Future<PageResponse<ApprovalRequest>> getPending({int page = 0, int size = 20}) async {
    final response = await _dio.get(ApiEndpoints.approvalsPending, queryParameters: {'page': page, 'size': size});
    return _parsePage(response.data);
  }

  Future<PageResponse<ApprovalRequest>> getMyRequests({int page = 0, int size = 20}) async {
    final response = await _dio.get(ApiEndpoints.approvalsMyRequests, queryParameters: {'page': page, 'size': size});
    return _parsePage(response.data);
  }

  Future<int> getPendingCount() async {
    final response = await _dio.get(ApiEndpoints.approvalsPendingCount);
    final apiResponse = ApiResponse<int>.fromJson(response.data, (json) => json as int);
    return apiResponse.data ?? 0;
  }

  Future<ApprovalRequest> approve(int id, {String? comment}) async {
    final response = await _dio.post(
      ApiEndpoints.approvalApprove(id),
      data: comment != null && comment.isNotEmpty ? {'comment': comment} : null,
    );
    final apiResponse = ApiResponse<ApprovalRequest>.fromJson(
      response.data,
          (json) => ApprovalRequest.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<ApprovalRequest> reject(int id, String comment) async {
    final response = await _dio.post(ApiEndpoints.approvalReject(id), data: {'comment': comment});
    final apiResponse = ApiResponse<ApprovalRequest>.fromJson(
      response.data,
          (json) => ApprovalRequest.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  Future<ApprovalRequest> returnForCorrection(int id, String comment) async {
    final response = await _dio.post(ApiEndpoints.approvalReturn(id), data: {'comment': comment});
    final apiResponse = ApiResponse<ApprovalRequest>.fromJson(
      response.data,
          (json) => ApprovalRequest.fromJson(json as Map<String, dynamic>),
    );
    return apiResponse.data!;
  }

  PageResponse<ApprovalRequest> _parsePage(dynamic data) {
    final apiResponse = ApiResponse<PageResponse<ApprovalRequest>>.fromJson(
      data,
          (json) => PageResponse.fromJson(
        json as Map<String, dynamic>,
            (item) => ApprovalRequest.fromJson(item),
      ),
    );
    return apiResponse.data!;
  }
}