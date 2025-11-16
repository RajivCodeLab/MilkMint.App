import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/notification_service.dart';
import '../../../models/user_role.dart';
import 'auth_state.dart';

/// Auth state notifier for managing authentication flow
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final NotificationService? _notificationService;
  String? _verificationId;

  AuthNotifier(
    this._repository, {
    NotificationService? notificationService,
  })  : _notificationService = notificationService,
        super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  /// Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Splash delay

    debugPrint('🔍 Checking auth status...');
    final isLoggedIn = _repository.isLoggedIn();
    debugPrint('🔍 Is logged in: $isLoggedIn');
    
    if (isLoggedIn) {
      final user = _repository.getCurrentUser();
      debugPrint('🔍 Current user: ${user?.phone}, role: ${user?.role.name}');
      if (user != null) {
        state = AuthState.authenticated(user);
        debugPrint('✅ User authenticated, navigating to home');
        return;
      }
    }

    debugPrint('❌ User not authenticated, showing language selection');
    state = const AuthState.unauthenticated();
  }

  /// Send OTP to phone number
  Future<void> sendOtp(String phoneNumber) async {
    try {
      state = const AuthState.sendingOtp();

      final verificationId = await _repository.sendOtp(phoneNumber);
      _verificationId = verificationId;

      state = AuthState.otpSent(verificationId);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Verify OTP and complete login
  Future<void> verifyOtp(String otp) async {
    if (_verificationId == null) {
      state = const AuthState.error('No verification ID found. Please resend OTP.');
      return;
    }

    try {
      state = const AuthState.verifyingOtp();

      // Verify OTP with Firebase
      final credential = await _repository.verifyOtp(_verificationId!, otp);

      state = const AuthState.authenticating();

      // Login with backend to get user role
      final user = await _repository.loginWithFirebase(credential);

      // Subscribe to notification topics based on user role
      await _subscribeToNotificationTopics(user);

      // Check if this is a new user who needs onboarding
      if (_repository.wasNewUser()) {
        state = AuthState.requiresOnboarding(user);
      } else {
        state = AuthState.authenticated(user);
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('🔴 Firebase Auth Error: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'invalid-verification-code':
          message = 'Invalid OTP. Please try again.';
          break;
        case 'session-expired':
          message = 'OTP expired. Please request a new one.';
          break;
        default:
          message = 'Verification failed: ${e.message}';
      }
      state = AuthState.error(message);
    } catch (e) {
      debugPrint('🔴 Login Error: $e');
      state = AuthState.error('Login failed: ${e.toString()}');
    }
  }

  /// Resend OTP
  Future<void> resendOtp(String phoneNumber) async {
    await sendOtp(phoneNumber);
  }

  /// Logout
  Future<void> logout() async {
    debugPrint('🔴 AuthNotifier.logout() called');
    try {
      // Unsubscribe from all notification topics
      debugPrint('🔴 Unsubscribing from notification topics...');
      await _unsubscribeFromNotificationTopics();

      debugPrint('🔴 Calling repository.logout()...');
      await _repository.logout();
      debugPrint('🔴 Setting state to unauthenticated');
      state = const AuthState.unauthenticated();
      debugPrint('✅ Logout completed successfully');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      state = AuthState.error('Logout failed: ${e.toString()}');
    }
  }

  /// Update FCM token
  Future<void> updateFcmToken(String token) async {
    try {
      await _repository.updateFcmToken(token);
    } catch (e) {
      // Silently fail - not critical for auth flow
    }
  }

  /// Reset to unauthenticated state (for navigation)
  void resetToUnauthenticated() {
    state = const AuthState.unauthenticated();
  }

  /// Complete onboarding and transition to authenticated state
  void completeOnboarding() {
    final currentState = state;
    currentState.maybeWhen(
      requiresOnboarding: (user) {
        state = AuthState.authenticated(user);
      },
      orElse: () {
        // Already authenticated or invalid state
      },
    );
  }

  /// Submit onboarding details to backend
  Future<void> submitOnboarding({
    required String firstName,
    required String lastName,
    String? email,
    String? address,
    String? city,
    String? pincode,
  }) async {
    try {
      state = const AuthState.authenticating();

      final user = await _repository.completeOnboarding(
        firstName: firstName,
        lastName: lastName,
        email: email,
        address: address,
        city: city,
        pincode: pincode,
      );

      // Subscribe to notification topics based on user role
      await _subscribeToNotificationTopics(user);

      state = AuthState.authenticated(user);
    } catch (e) {
      debugPrint('🔴 Onboarding Error: $e');
      state = AuthState.error('Failed to complete onboarding: ${e.toString()}');
    }
  }

  /// Subscribe to notification topics based on user role
  Future<void> _subscribeToNotificationTopics(User user) async {
    try {
      await _notificationService?.subscribeToUserTopics(
        userId: user.uid,
        role: user.role.name,
        vendorId: user.vendorId,
      );
    } catch (e) {
      // Silently fail - not critical for auth flow
    }
  }

  /// Unsubscribe from all notification topics
  Future<void> _unsubscribeFromNotificationTopics() async {
    try {
      final currentState = state;
      currentState.maybeWhen(
        authenticated: (user) async {
          await _notificationService?.unsubscribeFromAllTopics(
            userId: user.uid,
            role: user.role.name,
            vendorId: user.vendorId,
          );
        },
        orElse: () {},
      );
      await _notificationService?.deleteToken();
    } catch (e) {
      // Silently fail - not critical for logout
    }
  }
}
