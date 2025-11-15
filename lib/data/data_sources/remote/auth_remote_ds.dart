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
  Future<LoginResponseDto> login(String firebaseIdToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: LoginRequestDto(firebaseIdToken: firebaseIdToken).toJson(),
      );

      return LoginResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify phone exists in system (optional check before OTP)
  Future<bool> checkPhoneExists(String phone) async {
    try {
      final response = await _apiClient.get(
        '/auth/check-phone',
        queryParameters: {'phone': phone},
      );

      return response.data['exists'] as bool;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user profile from backend
  Future<User> getUserProfile(String uid) async {
    try {
      final response = await _apiClient.get('/auth/profile/$uid');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update FCM token on backend
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _apiClient.post(
        '/auth/fcm-token',
        data: {
          'uid': uid,
          'fcmToken': token,
        },
      );
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
