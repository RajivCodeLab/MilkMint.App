import 'package:freezed_annotation/freezed_annotation.dart';

part 'holiday.freezed.dart';
part 'holiday.g.dart';

@freezed
class Holiday with _$Holiday {
  const factory Holiday({
    @JsonKey(name: '_id') String? id,
    required String customerId,
    required String vendorId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    @Default('pending') String status, // pending, approved, rejected
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Holiday;

  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);
}
