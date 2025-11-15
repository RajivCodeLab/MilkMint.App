// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvoiceImpl _$$InvoiceImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceImpl(
      id: json['_id'] as String?,
      invoiceId: json['invoiceId'] as String,
      vendorId: json['vendorId'] as String,
      customerId: json['customerId'] as String,
      month: json['month'] as String,
      year: (json['year'] as num).toInt(),
      totalLiters: (json['totalLiters'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      pdfUrl: json['pdfUrl'] as String?,
      paid: json['paid'] as bool? ?? false,
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$InvoiceImplToJson(_$InvoiceImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'invoiceId': instance.invoiceId,
      'vendorId': instance.vendorId,
      'customerId': instance.customerId,
      'month': instance.month,
      'year': instance.year,
      'totalLiters': instance.totalLiters,
      'amount': instance.amount,
      'pdfUrl': instance.pdfUrl,
      'paid': instance.paid,
      'paidAt': instance.paidAt?.toIso8601String(),
      'generatedAt': instance.generatedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
