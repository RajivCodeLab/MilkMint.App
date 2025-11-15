// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerImpl _$$CustomerImplFromJson(Map<String, dynamic> json) =>
    _$CustomerImpl(
      id: json['_id'] as String?,
      customerId: json['customerId'] as String,
      vendorId: json['vendorId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      rate: (json['rate'] as num).toDouble(),
      frequency: json['frequency'] as String? ?? 'daily',
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CustomerImplToJson(_$CustomerImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'customerId': instance.customerId,
      'vendorId': instance.vendorId,
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'quantity': instance.quantity,
      'rate': instance.rate,
      'frequency': instance.frequency,
      'active': instance.active,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
