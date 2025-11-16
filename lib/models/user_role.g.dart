// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['_id'] as String?,
  uid: json['uid'] as String,
  phone: json['phone'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  vendorId: json['vendorId'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  pincode: json['pincode'] as String?,
  language: json['language'] as String? ?? 'en',
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'uid': instance.uid,
      'phone': instance.phone,
      'role': _$UserRoleEnumMap[instance.role]!,
      'vendorId': instance.vendorId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'address': instance.address,
      'city': instance.city,
      'pincode': instance.pincode,
      'language': instance.language,
      'fcmTokens': instance.fcmTokens,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.vendor: 'vendor',
  UserRole.customer: 'customer',
  UserRole.deliveryAgent: 'delivery_agent',
};
