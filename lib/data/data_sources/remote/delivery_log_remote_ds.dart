import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../models/delivery/delivery_log.dart';

/// Remote data source for delivery log API calls
class DeliveryLogRemoteDataSource {
  final ApiClient _apiClient;

  DeliveryLogRemoteDataSource(this._apiClient);

  /// Create or update delivery log (upsert)
  Future<DeliveryLog> createDeliveryLog({
    required String customerId,
    required DateTime date,
    required bool delivered,
    required double quantityDelivered,
  }) async {
    try {
      final response = await _apiClient.post(
        '/delivery-logs',
        data: {
          'customerId': customerId,
          'date': date.toIso8601String().split('T')[0],
          'delivered': delivered,
          'quantityDelivered': quantityDelivered,
        },
      );

      return DeliveryLog.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Batch create/update delivery logs (for offline sync)
  Future<Map<String, dynamic>> batchCreateDeliveryLogs(
    List<Map<String, dynamic>> logs,
  ) async {
    try {
      final response = await _apiClient.post(
        '/delivery-logs/batch',
        data: {'logs': logs},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get delivery logs by date range
  Future<List<DeliveryLog>> getLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        '/delivery-logs',
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );

      final logs = (response.data as List)
          .map((json) => DeliveryLog.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return logs;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get delivery logs for specific customer
  Future<List<DeliveryLog>> getLogsByCustomer({
    required String customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'customerId': customerId,
      };
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get(
        '/delivery-logs/customer',
        queryParameters: queryParams,
      );

      final logs = (response.data as List)
          .map((json) => DeliveryLog.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return logs;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get monthly summary for billing
  Future<Map<String, dynamic>> getMonthlySummary({
    required int month,
    required int year,
  }) async {
    try {
      final response = await _apiClient.get(
        '/delivery-logs/monthly-summary',
        queryParameters: {
          'month': month,
          'year': year,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'Delivery log operation failed';
      return Exception(message);
    }
    return Exception('Network error: ${e.message}');
  }
}
