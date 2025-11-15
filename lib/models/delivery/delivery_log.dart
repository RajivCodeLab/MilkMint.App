import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_log.freezed.dart';
part 'delivery_log.g.dart';

@freezed
class DeliveryLog with _$DeliveryLog {
  const factory DeliveryLog({
    @JsonKey(name: '_id') String? id,
    required String vendorId,
    required String customerId,
    required DateTime date,
    @Default(true) bool delivered,
    double? quantityDelivered, // Actual quantity delivered
    String? notes,
    required DateTime timestamp, // When log was created
    @Default(false) bool synced, // For offline tracking
    DateTime? syncedAt,
  }) = _DeliveryLog;

  factory DeliveryLog.fromJson(Map<String, dynamic> json) =>
      _$DeliveryLogFromJson(json);
}
