import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../models/customer/customer.dart';

/// Remote data source for customer API calls
class CustomerRemoteDataSource {
  final ApiClient _apiClient;

  CustomerRemoteDataSource(this._apiClient);

  /// Get all customers for vendor (paginated)
  Future<List<Customer>> getCustomers({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        '/customers',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final customers = (data['customers'] as List)
          .map((json) => Customer.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return customers;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get customer by ID
  Future<Customer> getCustomerById(String id) async {
    try {
      final response = await _apiClient.get('/customers/$id');
      return Customer.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new customer
  Future<Customer> createCustomer({
    required String name,
    required String phone,
    String? address,
    required double quantity,
    required double rate,
    required String frequency,
  }) async {
    try {
      final response = await _apiClient.post(
        '/customers',
        data: {
          'name': name,
          'phone': phone,
          if (address != null) 'address': address,
          'quantity': quantity,
          'rate': rate,
          'frequency': frequency,
        },
      );

      return Customer.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update customer
  Future<Customer> updateCustomer(
    String id, {
    String? name,
    String? phone,
    String? address,
    double? quantity,
    double? rate,
    String? frequency,
    bool? active,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (quantity != null) data['quantity'] = quantity;
      if (rate != null) data['rate'] = rate;
      if (frequency != null) data['frequency'] = frequency;
      if (active != null) data['active'] = active;

      final response = await _apiClient.patch(
        '/customers/$id',
        data: data,
      );

      return Customer.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete customer (soft delete)
  Future<void> deleteCustomer(String id) async {
    try {
      await _apiClient.delete('/customers/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'Customer operation failed';
      return Exception(message);
    }
    return Exception('Network error: ${e.message}');
  }
}
