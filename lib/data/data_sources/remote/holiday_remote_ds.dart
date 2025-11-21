import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../models/holiday/holiday.dart';

/// Remote data source for holiday API calls
class HolidayRemoteDataSource {
  final ApiClient _apiClient;

  HolidayRemoteDataSource(this._apiClient);

  Map<String, dynamic> _normalizeHolidayJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final map = Map<String, dynamic>.from(json);

      // Normalize nested customerId objects to string id
      final customer = map['customerId'];
      if (customer is Map) {
        // Prefer id for canonical reference
        String? id;
        if (customer.containsKey('_id')) {
          id = customer['_id']?.toString();
        } else if (customer.containsKey('id')) {
          id = customer['id']?.toString();
        }

        // Try to build a friendly display string: Name (Address)
        final name = (customer['name'] ?? customer['fullName'] ?? customer['customerName'] ?? '')?.toString();
        final address = (customer['address'] ?? customer['addressLine'] ?? customer['location'] ?? '')?.toString();

        if (name != null && name.isNotEmpty) {
          if (address != null && address.isNotEmpty) {
            map['customerId'] = '$name ($address)';
          } else {
            map['customerId'] = name;
          }
        } else if (id != null && id.isNotEmpty) {
          map['customerId'] = id;
        } else {
          map['customerId'] = customer.toString();
        }
      }

      // Some APIs wrap payload under different keys (e.g. _id already present)
      return map;
    }
    return {'customerId': json.toString()};
  }

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

      return Holiday.fromJson(_normalizeHolidayJson(response.data));
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

      final data = response.data;

      List rawList = [];
      if (data is Map<String, dynamic>) {
        if (data.containsKey('holidays') && data['holidays'] is List) {
          rawList = data['holidays'] as List;
        } else if (data.containsKey('data') && data['data'] is List) {
          rawList = data['data'] as List;
        } else if (data.values.any((v) => v is List)) {
          // fallback to first list value
          rawList = data.values.firstWhere((v) => v is List) as List;
        }
      } else if (data is List) {
        rawList = data;
      }

      final holidays = rawList
          .map((json) => Holiday.fromJson(_normalizeHolidayJson(json)))
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
      final data = response.data;
      final rawList = data is List ? data : (data is Map && data['holidays'] is List ? data['holidays'] as List : []);

      final holidays = rawList
          .map((json) => Holiday.fromJson(_normalizeHolidayJson(json)))
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
      final data = response.data;
      final rawList = data is List ? data : (data is Map && data['holidays'] is List ? data['holidays'] as List : []);

      final holidays = rawList
          .map((json) => Holiday.fromJson(_normalizeHolidayJson(json)))
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
      return Holiday.fromJson(_normalizeHolidayJson(response.data));
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

      return Holiday.fromJson(_normalizeHolidayJson(response.data));
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
