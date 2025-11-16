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

      return Payment.fromJson(response.data);
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

      final data = response.data as Map<String, dynamic>;
      final payments = (data['data'] as List)
          .map((json) => Payment.fromJson(json as Map<String, dynamic>))
          .toList();
      
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
          .map((json) => Payment.fromJson(json as Map<String, dynamic>))
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
          .map((json) => Payment.fromJson(json as Map<String, dynamic>))
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
      return Payment.fromJson(response.data);
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
}
