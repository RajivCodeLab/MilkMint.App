// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeliveryLogImpl _$$DeliveryLogImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryLogImpl(
      id: json['_id'] as String?,
      vendorId: json['vendorId'] as String,
      customerId: _customerIdFromJson(json['customerId']),
      date: DateTime.parse(json['date'] as String),
      delivered: json['delivered'] as bool? ?? true,
      quantityDelivered: (json['quantityDelivered'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      synced: json['synced'] as bool? ?? false,
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
    );

Map<String, dynamic> _$$DeliveryLogImplToJson(_$DeliveryLogImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'vendorId': instance.vendorId,
      'customerId': instance.customerId,
      'date': instance.date.toIso8601String(),
      'delivered': instance.delivered,
      'quantityDelivered': instance.quantityDelivered,
      'notes': instance.notes,
      'timestamp': instance.timestamp.toIso8601String(),
      'synced': instance.synced,
      'syncedAt': instance.syncedAt?.toIso8601String(),
    };
