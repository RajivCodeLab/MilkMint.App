import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

/// Remote data source for notification API calls
class NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSource(this._apiClient);

  /// Send notification to a specific user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _apiClient.post(
        '/notifications/send',
        data: {
          'userId': userId,
          'title': title,
          'body': body,
          if (data != null) 'data': data,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Send bulk notification to multiple tokens
  Future<void> sendBulkNotification({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _apiClient.post(
        '/notifications/send-bulk',
        data: {
          'tokens': tokens,
          'title': title,
          'body': body,
          if (data != null) 'data': data,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'Notification operation failed';
      return Exception(message);
    }
    return Exception('Network error: ${e.message}');
  }
}
