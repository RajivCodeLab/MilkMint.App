// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['_id'] as String?,
      paymentId: json['paymentId'] as String,
      vendorId: json['vendorId'] as String,
      customerId: json['customerId'] as String,
      invoiceId: json['invoiceId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      mode: json['mode'] as String? ?? 'cash',
      transactionId: json['transactionId'] as String?,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'paymentId': instance.paymentId,
      'vendorId': instance.vendorId,
      'customerId': instance.customerId,
      'invoiceId': instance.invoiceId,
      'amount': instance.amount,
      'mode': instance.mode,
      'transactionId': instance.transactionId,
      'notes': instance.notes,
      'timestamp': instance.timestamp.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
