import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    @JsonKey(name: '_id') required String customerId,
    required String vendorId,
    required String name,
    required String phone,
    required String address,
    @Default(1.0) double quantity, // Liters per day
    required double rate, // Price per liter
    @Default('daily') String frequency, // daily, alternate, custom
    @Default(true) bool active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}
