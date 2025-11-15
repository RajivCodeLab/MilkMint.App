import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_role.freezed.dart';
part 'user_role.g.dart';

/// User roles in the application
enum UserRole {
  @JsonValue('vendor')
  vendor,
  @JsonValue('customer')
  customer,
  @JsonValue('delivery_agent')
  deliveryAgent,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.vendor:
        return 'Vendor';
      case UserRole.customer:
        return 'Customer';
      case UserRole.deliveryAgent:
        return 'Delivery Agent';
    }
  }

  String get value {
    switch (this) {
      case UserRole.vendor:
        return 'vendor';
      case UserRole.customer:
        return 'customer';
      case UserRole.deliveryAgent:
        return 'delivery_agent';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'vendor':
        return UserRole.vendor;
      case 'customer':
        return UserRole.customer;
      case 'delivery_agent':
        return UserRole.deliveryAgent;
      default:
        return UserRole.vendor; // Default to vendor
    }
  }
}

/// User model
@freezed
class User with _$User {
  const factory User({
    @JsonKey(name: '_id') String? id,
    required String uid, // Firebase UID
    required String phone,
    required UserRole role,
    String? vendorId, // Reference to vendor if customer/delivery_agent
    @Default('en') String language,
    @Default([]) List<String> fcmTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
