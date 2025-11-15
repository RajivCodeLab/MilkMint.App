import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/user_role.dart';
import '../../core/auth/auth_service.dart';
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
    try {
      // Get Firebase ID token
      final idToken = await credential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Call backend to validate token and get user role
      final loginResponse = await _remoteDataSource.login(idToken);

      // Save user and token locally
      await _localDataSource.saveUser(loginResponse.user);
      await _localDataSource.saveToken(loginResponse.token);

      return loginResponse.user;
    } catch (e) {
      // If backend call fails, create default vendor user from Firebase data
      final firebaseUser = credential.user!;
      final defaultUser = User(
        uid: firebaseUser.uid,
        phone: firebaseUser.phoneNumber ?? '',
        role: UserRole.vendor, // Default role
        language: 'en',
        fcmTokens: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save locally
      await _localDataSource.saveUser(defaultUser);
      // Save Firebase ID token as auth token
      final token = await firebaseUser.getIdToken() ?? '';
      await _localDataSource.saveToken(token);

      return defaultUser;
    }
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
        await _remoteDataSource.updateFcmToken(user.uid, token);
        
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
}
