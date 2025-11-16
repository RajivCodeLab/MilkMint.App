import '../../models/user_role.dart';

/// Data Transfer Object for authentication requests/responses
class LoginRequestDto {
  final String firebaseIdToken;

  LoginRequestDto({required this.firebaseIdToken});

  Map<String, dynamic> toJson() => {
        'firebaseIdToken': firebaseIdToken,
      };
}

class LoginResponseDto {
  final User user;
  final String token;
  final bool isNewUser;

  LoginResponseDto({
    required this.user,
    required this.token,
    this.isNewUser = false,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String? ?? '', // Token might not be in response
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }
}

class SendOtpRequestDto {
  final String phoneNumber;

  SendOtpRequestDto({required this.phoneNumber});

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
      };
}

class VerifyOtpRequestDto {
  final String verificationId;
  final String otp;

  VerifyOtpRequestDto({
    required this.verificationId,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'verificationId': verificationId,
        'otp': otp,
      };
}
