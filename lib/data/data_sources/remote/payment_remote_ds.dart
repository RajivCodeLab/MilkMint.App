import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../models/payment/payment.dart';

/// Remote data source for payment API calls
class PaymentRemoteDataSource {
  final ApiClient _apiClient;

  PaymentRemoteDataSource(this._apiClient);

  /// Record a new payment
  Future<Payment> recordPayment({
    required String customerId,
    String? invoiceId,
    required double amount,
    required String mode,
    required DateTime paymentDate,
    String? transactionId,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/payments',
        data: {
          'customerId': customerId,
          if (invoiceId != null) 'invoiceId': invoiceId,
          'amount': amount,
          'mode': mode,
          'paymentDate': paymentDate.toIso8601String().split('T')[0],
          if (transactionId != null) 'transactionId': transactionId,
          if (notes != null) 'notes': notes,
        },
      );

      final resp = response.data;
      if (resp is Map<String, dynamic>) {
        final normalized = _normalizePaymentJson(resp);
        return Payment.fromJson(normalized);
      }
      return Payment.fromJson(resp as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get payments (paginated)
  Future<List<Payment>> getPayments({
    int page = 1,
    int limit = 20,
    String? customerId,
    String? mode,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (customerId != null) queryParams['customerId'] = customerId;
      if (mode != null) queryParams['mode'] = mode;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get(
        '/payments',
        queryParameters: queryParams,
      );
      final resp = response.data;

      List<dynamic> listData = [];

      if (resp is Map<String, dynamic>) {
        // support { data: [...] } wrapper
        if (resp.containsKey('data') && resp['data'] is List) {
          listData = resp['data'] as List<dynamic>;
        } else if (resp.values.any((v) => v is List)) {
          listData = resp.values.firstWhere((v) => v is List, orElse: () => <dynamic>[]) as List<dynamic>;
        } else {
          throw Exception('Unexpected payments response format');
        }
      } else if (resp is List) {
        listData = resp;
      } else {
        throw Exception('Unexpected payments response type');
      }

      final payments = listData.map((json) {
        final map = json as Map<String, dynamic>;
        final normalized = _normalizePaymentJson(map);
        return Payment.fromJson(normalized);
      }).toList();

      return payments;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get payment statistics
  Future<Map<String, dynamic>> getPaymentStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get(
        '/payments/stats',
        queryParameters: queryParams,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get payments for specific customer
  Future<List<Payment>> getCustomerPayments(String customerId) async {
    try {
      final response = await _apiClient.get('/payments/customer/$customerId');

      final payments = (response.data as List)
          .map((json) {
            final map = json as Map<String, dynamic>;
            final normalized = _normalizePaymentJson(map);
            return Payment.fromJson(normalized);
          })
          .toList();
      
      return payments;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get payments for specific invoice
  Future<List<Payment>> getInvoicePayments(String invoiceId) async {
    try {
      final response = await _apiClient.get('/payments/invoice/$invoiceId');

      final payments = (response.data as List)
          .map((json) {
            final map = json as Map<String, dynamic>;
            final normalized = _normalizePaymentJson(map);
            return Payment.fromJson(normalized);
          })
          .toList();
      
      return payments;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get payment by ID
  Future<Payment> getPaymentById(String id) async {
    try {
      final response = await _apiClient.get('/payments/$id');
      final resp = response.data as Map<String, dynamic>;
      final normalized = _normalizePaymentJson(resp);
      return Payment.fromJson(normalized);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update payment status
  Future<Payment> updatePaymentStatus(String id, {required String status}) async {
    try {
      final response = await _apiClient.patch(
        '/payments/$id/status',
        data: {'status': status},
      );

      return Payment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete payment
  Future<void> deletePayment(String id) async {
    try {
      await _apiClient.delete('/payments/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'Payment operation failed';
      return Exception(message);
    }
    return Exception('Network error: ${e.message}');
  }

  /// Normalize server payment JSON to the shape expected by `Payment.fromJson`.
  ///
  /// The backend returns `_id` and `paymentDate`/`createdAt` fields. The
  /// `Payment` model expects `paymentId` and `timestamp`. This helper maps
  /// `_id -> paymentId` and `paymentDate/createdAt -> timestamp`, preserving
  /// other fields.
  Map<String, dynamic> _normalizePaymentJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{}..addAll(json);

    // Ensure paymentId exists
    if (!normalized.containsKey('paymentId') && normalized.containsKey('_id')) {
      normalized['paymentId'] = normalized['_id'];
    }

    // Map paymentDate or createdAt to timestamp (ISO string)
    if (!normalized.containsKey('timestamp')) {
      if (normalized.containsKey('paymentDate') && normalized['paymentDate'] != null) {
        normalized['timestamp'] = normalized['paymentDate'];
      } else if (normalized.containsKey('createdAt') && normalized['createdAt'] != null) {
        normalized['timestamp'] = normalized['createdAt'];
      } else if (normalized.containsKey('updatedAt') && normalized['updatedAt'] != null) {
        normalized['timestamp'] = normalized['updatedAt'];
      }
    }

    // If customerId is returned as object, extract its `_id`.
    if (normalized.containsKey('customerId') && normalized['customerId'] is Map) {
      final cust = normalized['customerId'] as Map<String, dynamic>;
      if (cust.containsKey('_id')) {
        normalized['customerId'] = cust['_id'];
      }
      // preserve customerName/customerPhone if provided separately
      if (!normalized.containsKey('customerName') && cust.containsKey('name')) {
        normalized['customerName'] = cust['name'];
      }
      if (!normalized.containsKey('customerPhone') && cust.containsKey('phone')) {
        normalized['customerPhone'] = cust['phone'];
      }
    }

    return normalized;
  }
}
