import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/user_role.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/firebase_service.dart';
import '../data_sources/local/auth_local_ds.dart';
import '../data_sources/remote/auth_remote_ds.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Send OTP to phone number
  Future<String> sendOtp(String phoneNumber);

  /// Verify OTP and complete Firebase authentication
  Future<firebase_auth.UserCredential> verifyOtp(
    String verificationId,
    String otp,
  );

  /// Login with Firebase credentials and get user role from backend
  Future<User> loginWithFirebase(firebase_auth.UserCredential credential);

  /// Get if last login was a new user (for onboarding flow)
  bool wasNewUser();

  /// Complete user profile (onboarding)
  Future<User> completeOnboarding({
    required String firstName,
    required String lastName,
    String? email,
    String? address,
    String? city,
    String? pincode,
  });

  /// Get current user from local storage
  User? getCurrentUser();

  /// Get authentication token
  String? getAuthToken();

  /// Check if user is logged in
  bool isLoggedIn();

  /// Logout and clear all data
  Future<void> logout();

  /// Update FCM token
  Future<void> updateFcmToken(String token);
}

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  
  bool _isNewUser = false;

  AuthRepositoryImpl(
    this._authService,
    this._localDataSource,
    this._remoteDataSource,
  );

  @override
  Future<String> sendOtp(String phoneNumber) async {
    final completer = Completer<String>();

    await _authService.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        completer.complete(verificationId);
      },
      onError: (error) {
        completer.completeError(Exception(error));
      },
    );

    return completer.future;
  }

  @override
  Future<firebase_auth.UserCredential> verifyOtp(
    String verificationId,
    String otp,
  ) async {
    final user = await _authService.verifyOTP(
      verificationId: verificationId,
      otp: otp,
    );

    if (user == null) {
      throw Exception('Failed to verify OTP');
    }

    // Create UserCredential-like response
    final credential = firebase_auth.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    return await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Future<User> loginWithFirebase(
    firebase_auth.UserCredential credential,
  ) async {
    // Get Firebase ID token
    final idToken = await credential.user?.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to get Firebase ID token');
    }

    // Get phone number from Firebase user
    final phone = credential.user?.phoneNumber;
    if (phone == null) {
      throw Exception('Phone number not available from Firebase');
    }

    // Get FCM token for push notifications
    final fcmToken = await FirebaseService.getFCMToken();

    // Call backend to validate token and get user role
    final loginResponse = await _remoteDataSource.login(
      idToken,
      phone,
      fcmToken: fcmToken,
      language: 'en',
    );
    
    // Store new user flag for onboarding check
    _isNewUser = loginResponse.isNewUser;

    // Save user and token locally
    await _localDataSource.saveUser(loginResponse.user);
    await _localDataSource.saveToken(loginResponse.token);

    return loginResponse.user;
  }

  @override
  User? getCurrentUser() {
    return _localDataSource.getUser();
  }

  @override
  String? getAuthToken() {
    return _localDataSource.getToken();
  }

  @override
  bool isLoggedIn() {
    return _localDataSource.isLoggedIn();
  }

  @override
  Future<void> logout() async {
    await _authService.signOut();
    await _localDataSource.clearAuth();
  }

  @override
  Future<void> updateFcmToken(String token) async {
    final user = getCurrentUser();
    if (user != null) {
      try {
        await _remoteDataSource.addFcmToken(token);
        
        // Update local user with new FCM token
        final updatedTokens = [...user.fcmTokens];
        if (!updatedTokens.contains(token)) {
          updatedTokens.add(token);
        }
        
        final updatedUser = user.copyWith(fcmTokens: updatedTokens);
        await _localDataSource.saveUser(updatedUser);
      } catch (e) {
        // Silently fail if backend update fails
        // Token will be updated on next successful API call
      }
    }
  }
  
  @override
  bool wasNewUser() {
    return _isNewUser;
  }
  
  @override
  Future<User> completeOnboarding({
    required String firstName,
    required String lastName,
    String? email,
    String? address,
    String? city,
    String? pincode,
  }) async {
    final token = await _authService.getIdToken();
    if (token == null) throw Exception('Not authenticated');
    
    // Call backend onboarding endpoint
    final response = await _remoteDataSource.completeOnboarding(
      token: token,
      firstName: firstName,
      lastName: lastName,
      email: email,
      address: address,
      city: city,
      pincode: pincode,
    );
    
    // Save updated user to local storage
    await _localDataSource.saveUser(response.user);
    await _localDataSource.saveToken(token);
    
    _isNewUser = false;
    
    return response.user;
  }
}
