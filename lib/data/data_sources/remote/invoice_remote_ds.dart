import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../models/invoice/invoice.dart';

/// Remote data source for invoice API calls
class InvoiceRemoteDataSource {
  final ApiClient _apiClient;

  InvoiceRemoteDataSource(this._apiClient);

  /// Generate invoices for a month
  Future<Map<String, dynamic>> generateInvoices({
    required String month,
    bool force = false,
  }) async {
    try {
      final response = await _apiClient.post(
        '/invoices/generate',
        data: {
          'month': month,
          'force': force,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get invoices (paginated)
  Future<List<Invoice>> getInvoices({
    int page = 1,
    int limit = 20,
    String? month,
    bool? paid,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (month != null) queryParams['month'] = month;
      if (paid != null) queryParams['paid'] = paid;

      final response = await _apiClient.get(
        '/invoices',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final invoices = (data['data'] as List)
          .map((json) => Invoice.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return invoices;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get unpaid invoices
  Future<List<Invoice>> getUnpaidInvoices() async {
    try {
      final response = await _apiClient.get('/invoices/unpaid');

      final invoices = (response.data as List)
          .map((json) => Invoice.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return invoices;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get invoice statistics
  Future<Map<String, dynamic>> getInvoiceStats({String? month}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;

      final response = await _apiClient.get(
        '/invoices/stats',
        queryParameters: queryParams,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get invoice by ID
  Future<Invoice> getInvoiceById(String id) async {
    try {
      final response = await _apiClient.get('/invoices/$id');
      return Invoice.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark invoice as paid
  Future<Invoice> markInvoiceAsPaid(String id) async {
    try {
      final response = await _apiClient.patch('/invoices/$id/mark-paid');
      return Invoice.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete invoice
  Future<void> deleteInvoice(String id) async {
    try {
      await _apiClient.delete('/invoices/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'Invoice operation failed';
      return Exception(message);
    }
    return Exception('Network error: ${e.message}');
  }
}
