import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication service for Firebase Phone OTP authentication
class AuthService {
  AuthService(this._auth);

  final auth.FirebaseAuth _auth;

  int? _resendToken;

  /// Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (auth.PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          debugPrint('Auto-verification completed');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (auth.FirebaseAuthException e) {
          debugPrint('Verification failed: ${e.message}');
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('OTP sent to $phoneNumber');
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Auto retrieval timeout');
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      debugPrint('Send OTP error: $e');
      onError(e.toString());
    }
  }

  /// Verify OTP and sign in
  Future<auth.User?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('User signed in: ${userCredential.user?.uid}');
      return userCredential.user;
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('OTP verification error: ${e.message}');
      throw Exception(e.message ?? 'Invalid OTP');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to verify OTP');
    }
  }

  /// Get current Firebase ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      debugPrint('Get token error: $e');
      return null;
    }
  }

  /// Get current user
  auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('User signed out');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Auth state changes stream
  Stream<auth.User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}

/// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<auth.FirebaseAuth>((ref) {
  return auth.FirebaseAuth.instance;
});

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return AuthService(firebaseAuth);
});

/// Provider for current Firebase user
final firebaseUserProvider = StreamProvider<auth.User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

/// Provider for authentication state
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(firebaseUserProvider);
  return user.value != null;
});

/// Provider for Firebase ID token
final firebaseIdTokenProvider = FutureProvider.autoDispose<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getIdToken();
});
