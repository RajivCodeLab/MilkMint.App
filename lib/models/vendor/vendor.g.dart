// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VendorImpl _$$VendorImplFromJson(Map<String, dynamic> json) => _$VendorImpl(
  id: json['_id'] as String?,
  vendorId: json['vendorId'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  subscriptionPlan: json['subscriptionPlan'] as String,
  trialEnd: json['trialEnd'] == null
      ? null
      : DateTime.parse(json['trialEnd'] as String),
  active: json['active'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$VendorImplToJson(_$VendorImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'vendorId': instance.vendorId,
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'subscriptionPlan': instance.subscriptionPlan,
      'trialEnd': instance.trialEnd?.toIso8601String(),
      'active': instance.active,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
