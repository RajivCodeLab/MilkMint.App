import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    @JsonKey(name: '_id') String? id,
    required String paymentId,
    required String vendorId,
    required String customerId,
    String? invoiceId, // Optional: link to specific invoice
    required double amount,
    @Default('cash') String mode, // cash, upi, bank_transfer, other
    String? transactionId, // For digital payments
    String? notes,
    required DateTime timestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
