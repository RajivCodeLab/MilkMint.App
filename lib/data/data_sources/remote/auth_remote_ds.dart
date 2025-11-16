import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../models/user_role.dart';
import '../../dto/auth_dto.dart';

/// Remote data source for authentication API calls
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  /// Login with Firebase ID token
  /// Backend validates token and returns user with role
  Future<LoginResponseDto> login(
    String firebaseIdToken,
    String phone, {
    String? fcmToken,
    String language = 'en',
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/resolve',
        data: {
          'phone': phone,
          'language': language,
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );

      return LoginResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/users/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user profile by UID (vendor only)
  Future<User> getUserByUid(String uid) async {
    try {
      final response = await _apiClient.get('/users/$uid');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Search user by phone number (vendor only)
  Future<User?> searchUserByPhone(String phone) async {
    try {
      final response = await _apiClient.post(
        '/users/search-by-phone',
        data: {'phone': phone},
      );
      return response.data != null ? User.fromJson(response.data) : null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add FCM token
  Future<void> addFcmToken(String token) async {
    try {
      await _apiClient.post(
        '/auth/fcm-token',
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remove FCM token
  Future<void> removeFcmToken(String token) async {
    try {
      await _apiClient.delete(
        '/auth/fcm-token',
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update language preference
  Future<void> updateLanguage(String language) async {
    try {
      await _apiClient.put(
        '/auth/language',
        data: {'language': language},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Complete user onboarding with profile details
  Future<LoginResponseDto> completeOnboarding({
    required String token,
    required String firstName,
    required String lastName,
    String? email,
    String? address,
    String? city,
    String? pincode,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/onboarding',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          if (email != null && email.isNotEmpty) 'email': email,
          if (address != null && address.isNotEmpty) 'address': address,
          if (city != null && city.isNotEmpty) 'city': city,
          if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
        },
      );

      // Extract user from response
      return LoginResponseDto.fromJson({
        'user': response.data['user'],
        'isNewUser': false,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'Authentication failed';
      return Exception(message);
    }
    return Exception('Network error: ${e.message}');
  }
}
