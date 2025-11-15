import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor.freezed.dart';
part 'vendor.g.dart';

@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    @JsonKey(name: '_id') String? id,
    required String vendorId,
    required String name,
    required String phone,
    required String address,
    required String subscriptionPlan,
    DateTime? trialEnd,
    @Default(true) bool active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
}
