import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    @JsonKey(name: '_id') String? id,
    required String invoiceId,
    required String vendorId,
    required String customerId,
    required String month, // Format: "YYYY-MM" (e.g., "2025-01")
    required int year,
    required double totalLiters,
    required double amount,
    String? pdfUrl, // Cloud storage URL
    @Default(false) bool paid,
    DateTime? paidAt,
    DateTime? generatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}
