import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/user_role.dart';

part 'auth_state.freezed.dart';

/// Authentication state
@freezed
class AuthState with _$AuthState {
  /// Initial state - checking auth status
  const factory AuthState.initial() = _Initial;

  /// User is not authenticated
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// Sending OTP to phone number
  const factory AuthState.sendingOtp() = _SendingOtp;

  /// OTP sent successfully, waiting for verification
  const factory AuthState.otpSent(String verificationId) = _OtpSent;

  /// Verifying OTP code
  const factory AuthState.verifyingOtp() = _VerifyingOtp;

  /// Authenticating with backend
  const factory AuthState.authenticating() = _Authenticating;

  /// User is authenticated
  const factory AuthState.authenticated(User user) = _Authenticated;

  /// New user requires onboarding (profile completion)
  const factory AuthState.requiresOnboarding(User user) = _RequiresOnboarding;

  /// Authentication error
  const factory AuthState.error(String message) = _Error;
}
