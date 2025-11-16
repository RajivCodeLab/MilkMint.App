import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../models/holiday/holiday.dart';

/// Remote data source for holiday API calls
class HolidayRemoteDataSource {
  final ApiClient _apiClient;

  HolidayRemoteDataSource(this._apiClient);

  /// Create holiday request
  Future<Holiday> createHoliday({
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    try {
      final response = await _apiClient.post(
        '/holidays',
        data: {
          'customerId': customerId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          if (reason != null) 'reason': reason,
        },
      );

      return Holiday.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get holidays (paginated)
  Future<List<Holiday>> getHolidays({
    int page = 1,
    int limit = 20,
    String? status,
    String? customerId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;
      if (customerId != null) queryParams['customerId'] = customerId;

      final response = await _apiClient.get(
        '/holidays',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final holidays = (data['data'] as List)
          .map((json) => Holiday.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return holidays;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get upcoming holidays
  Future<List<Holiday>> getUpcomingHolidays() async {
    try {
      final response = await _apiClient.get('/holidays/upcoming');

      final holidays = (response.data as List)
          .map((json) => Holiday.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return holidays;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get holidays for specific customer
  Future<List<Holiday>> getCustomerHolidays(String customerId) async {
    try {
      final response = await _apiClient.get('/holidays/customer/$customerId');

      final holidays = (response.data as List)
          .map((json) => Holiday.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return holidays;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get holiday by ID
  Future<Holiday> getHolidayById(String id) async {
    try {
      final response = await _apiClient.get('/holidays/$id');
      return Holiday.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update holiday status (vendor only)
  Future<Holiday> updateHolidayStatus(
    String id, {
    required String status,
    String? vendorNotes,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/holidays/$id/status',
        data: {
          'status': status,
          if (vendorNotes != null) 'vendorNotes': vendorNotes,
        },
      );

      return Holiday.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel holiday
  Future<void> cancelHoliday(String id) async {
    try {
      await _apiClient.delete('/holidays/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'Holiday operation failed';
      return Exception(message);
    }
    return Exception('Network error: ${e.message}');
  }
}
