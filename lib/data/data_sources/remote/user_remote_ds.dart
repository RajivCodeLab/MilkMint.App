import '../../../core/api/api_client.dart';

class UserRemoteDataSource {
  final ApiClient _apiClient;

  UserRemoteDataSource(this._apiClient);

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _apiClient.get('/users/me');
    return response.data as Map<String, dynamic>;
  }

  /// Update user language preference
  Future<Map<String, dynamic>> updateLanguage(String language) async {
    final response = await _apiClient.put('/auth/language', data: {'language': language});
    return response.data as Map<String, dynamic>;
  }

  /// Update user profile (onboarding endpoint)
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? address,
    String? city,
    String? pincode,
  }) async {
    final response = await _apiClient.post('/auth/onboarding', data: {
      'firstName': firstName,
      'lastName': lastName,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
    });
    return response.data as Map<String, dynamic>;
  }

  /// Search user by phone
  Future<Map<String, dynamic>?> searchByPhone(String phone) async {
    try {
      final response = await _apiClient.post('/users/search-by-phone', data: {'phone': phone});
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
