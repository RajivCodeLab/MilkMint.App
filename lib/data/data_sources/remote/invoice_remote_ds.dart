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
    List<String>? customerIds,
  }) async {
    try {
      final payload = {
        'month': month,
        'force': force,
      };
      if (customerIds != null && customerIds.isNotEmpty) {
        payload['customerIds'] = customerIds;
      }

      final response = await _apiClient.post(
        '/invoices/generate',
        data: payload,
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

      final resp = response.data;

      List<dynamic> listData = [];

      if (resp is Map<String, dynamic>) {
        // Support different shapes: { data: [...] } or { invoices: [...] }
        if (resp.containsKey('data') && resp['data'] is List) {
          listData = resp['data'] as List<dynamic>;
        } else if (resp.containsKey('invoices') && resp['invoices'] is List) {
          listData = resp['invoices'] as List<dynamic>;
        } else if (resp.values.any((v) => v is List)) {
          // Fallback: pick the first list value
          listData = resp.values.firstWhere((v) => v is List, orElse: () => <dynamic>[]) as List<dynamic>;
        } else {
          throw Exception('Unexpected invoices response format');
        }
      } else if (resp is List) {
        listData = resp;
      } else {
        throw Exception('Unexpected invoices response type');
      }

      final invoices = listData.map((raw) {
        final Map<String, dynamic> json = raw as Map<String, dynamic>;
        final normalized = _normalizeInvoiceJson(json);
        return Invoice.fromJson(normalized);
      }).toList();

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
      final resp = response.data;
      if (resp is Map<String, dynamic>) {
        final normalized = _normalizeInvoiceJson(resp);
        return Invoice.fromJson(normalized);
      }
      return Invoice.fromJson(resp as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark invoice as paid
  Future<Invoice> markInvoiceAsPaid(String id) async {
    try {
      final response = await _apiClient.patch('/invoices/$id/mark-paid');

      final resp = response.data;

      // Response may be the invoice object directly, or have wrapper keys
      Map<String, dynamic>? invoiceMap;

      if (resp is Map<String, dynamic>) {
        // Common wrappers: { invoice: {...} } or { data: {...} }
        if (resp.containsKey('invoice') && resp['invoice'] is Map) {
          invoiceMap = resp['invoice'] as Map<String, dynamic>;
        } else if (resp.containsKey('data') && resp['data'] is Map) {
          invoiceMap = resp['data'] as Map<String, dynamic>;
        } else if (resp.containsKey('_id') || resp.containsKey('invoiceId')) {
          invoiceMap = resp;
        }
      }

      // If we couldn't extract a map, try fetching fresh invoice from server
      if (invoiceMap == null) {
        return getInvoiceById(id);
      }

      final normalized = _normalizeInvoiceJson(invoiceMap);
      return Invoice.fromJson(normalized);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _normalizeInvoiceJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{};

    // id/_id -> invoiceId and _id
    if (json.containsKey('_id')) {
      normalized['invoiceId'] = json['_id'];
      normalized['_id'] = json['_id'];
    }
    if (json.containsKey('invoiceId')) {
      normalized['invoiceId'] = json['invoiceId'];
    }

    // vendorId
    if (json.containsKey('vendorId')) normalized['vendorId'] = json['vendorId'];

    // customerId may be an object or a string
    if (json['customerId'] is Map) {
      normalized['customerId'] = (json['customerId'] as Map)['_id'];
    } else if (json['customerId'] is String) {
      normalized['customerId'] = json['customerId'];
    } else if (json.containsKey('customerId') && json['customerId'] == null && json.containsKey('customerName')) {
      normalized['customerId'] = json['customerName'];
    }

    // month
    if (json.containsKey('month')) normalized['month'] = json['month'];

    // year: try to parse from month
    if (json.containsKey('month') && json['month'] is String) {
      try {
        final parts = (json['month'] as String).split('-');
        normalized['year'] = int.parse(parts[0]);
      } catch (_) {}
    }

    // totalLiters
    if (json.containsKey('totalLiters')) {
      normalized['totalLiters'] = (json['totalLiters'] as num).toDouble();
    }

    // amount can be totalAmount or amount
    if (json.containsKey('totalAmount')) {
      normalized['amount'] = (json['totalAmount'] as num).toDouble();
    } else if (json.containsKey('amount')) {
      normalized['amount'] = (json['amount'] as num).toDouble();
    }

    // pdfUrl, paid, paidAt, createdAt, updatedAt, generatedAt
    if (json.containsKey('pdfUrl')) normalized['pdfUrl'] = json['pdfUrl'];
    if (json.containsKey('paid')) normalized['paid'] = json['paid'];
    if (json.containsKey('paidAt')) normalized['paidAt'] = json['paidAt'];
    if (json.containsKey('createdAt')) normalized['createdAt'] = json['createdAt'];
    if (json.containsKey('updatedAt')) normalized['updatedAt'] = json['updatedAt'];
    if (json.containsKey('generatedAt')) normalized['generatedAt'] = json['generatedAt'];

    return normalized;
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
