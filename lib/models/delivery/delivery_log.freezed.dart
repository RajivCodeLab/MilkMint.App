// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DeliveryLog _$DeliveryLogFromJson(Map<String, dynamic> json) {
  return _DeliveryLog.fromJson(json);
}

/// @nodoc
mixin _$DeliveryLog {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  String get vendorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'customerId', fromJson: _customerIdFromJson)
  String get customerId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  bool get delivered => throw _privateConstructorUsedError;
  double? get quantityDelivered =>
      throw _privateConstructorUsedError; // Actual quantity delivered
  String? get notes => throw _privateConstructorUsedError;
  DateTime get timestamp =>
      throw _privateConstructorUsedError; // When log was created
  bool get synced => throw _privateConstructorUsedError; // For offline tracking
  DateTime? get syncedAt => throw _privateConstructorUsedError;

  /// Serializes this DeliveryLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryLogCopyWith<DeliveryLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryLogCopyWith<$Res> {
  factory $DeliveryLogCopyWith(
    DeliveryLog value,
    $Res Function(DeliveryLog) then,
  ) = _$DeliveryLogCopyWithImpl<$Res, DeliveryLog>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String vendorId,
    @JsonKey(name: 'customerId', fromJson: _customerIdFromJson)
    String customerId,
    DateTime date,
    bool delivered,
    double? quantityDelivered,
    String? notes,
    DateTime timestamp,
    bool synced,
    DateTime? syncedAt,
  });
}

/// @nodoc
class _$DeliveryLogCopyWithImpl<$Res, $Val extends DeliveryLog>
    implements $DeliveryLogCopyWith<$Res> {
  _$DeliveryLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? vendorId = null,
    Object? customerId = null,
    Object? date = null,
    Object? delivered = null,
    Object? quantityDelivered = freezed,
    Object? notes = freezed,
    Object? timestamp = null,
    Object? synced = null,
    Object? syncedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            vendorId: null == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            delivered: null == delivered
                ? _value.delivered
                : delivered // ignore: cast_nullable_to_non_nullable
                      as bool,
            quantityDelivered: freezed == quantityDelivered
                ? _value.quantityDelivered
                : quantityDelivered // ignore: cast_nullable_to_non_nullable
                      as double?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            synced: null == synced
                ? _value.synced
                : synced // ignore: cast_nullable_to_non_nullable
                      as bool,
            syncedAt: freezed == syncedAt
                ? _value.syncedAt
                : syncedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeliveryLogImplCopyWith<$Res>
    implements $DeliveryLogCopyWith<$Res> {
  factory _$$DeliveryLogImplCopyWith(
    _$DeliveryLogImpl value,
    $Res Function(_$DeliveryLogImpl) then,
  ) = __$$DeliveryLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String vendorId,
    @JsonKey(name: 'customerId', fromJson: _customerIdFromJson)
    String customerId,
    DateTime date,
    bool delivered,
    double? quantityDelivered,
    String? notes,
    DateTime timestamp,
    bool synced,
    DateTime? syncedAt,
  });
}

/// @nodoc
class __$$DeliveryLogImplCopyWithImpl<$Res>
    extends _$DeliveryLogCopyWithImpl<$Res, _$DeliveryLogImpl>
    implements _$$DeliveryLogImplCopyWith<$Res> {
  __$$DeliveryLogImplCopyWithImpl(
    _$DeliveryLogImpl _value,
    $Res Function(_$DeliveryLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeliveryLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? vendorId = null,
    Object? customerId = null,
    Object? date = null,
    Object? delivered = null,
    Object? quantityDelivered = freezed,
    Object? notes = freezed,
    Object? timestamp = null,
    Object? synced = null,
    Object? syncedAt = freezed,
  }) {
    return _then(
      _$DeliveryLogImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        vendorId: null == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        delivered: null == delivered
            ? _value.delivered
            : delivered // ignore: cast_nullable_to_non_nullable
                  as bool,
        quantityDelivered: freezed == quantityDelivered
            ? _value.quantityDelivered
            : quantityDelivered // ignore: cast_nullable_to_non_nullable
                  as double?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        synced: null == synced
            ? _value.synced
            : synced // ignore: cast_nullable_to_non_nullable
                  as bool,
        syncedAt: freezed == syncedAt
            ? _value.syncedAt
            : syncedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeliveryLogImpl implements _DeliveryLog {
  const _$DeliveryLogImpl({
    @JsonKey(name: '_id') this.id,
    required this.vendorId,
    @JsonKey(name: 'customerId', fromJson: _customerIdFromJson)
    required this.customerId,
    required this.date,
    this.delivered = true,
    this.quantityDelivered,
    this.notes,
    required this.timestamp,
    this.synced = false,
    this.syncedAt,
  });

  factory _$DeliveryLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryLogImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String vendorId;
  @override
  @JsonKey(name: 'customerId', fromJson: _customerIdFromJson)
  final String customerId;
  @override
  final DateTime date;
  @override
  @JsonKey()
  final bool delivered;
  @override
  final double? quantityDelivered;
  // Actual quantity delivered
  @override
  final String? notes;
  @override
  final DateTime timestamp;
  // When log was created
  @override
  @JsonKey()
  final bool synced;
  // For offline tracking
  @override
  final DateTime? syncedAt;

  @override
  String toString() {
    return 'DeliveryLog(id: $id, vendorId: $vendorId, customerId: $customerId, date: $date, delivered: $delivered, quantityDelivered: $quantityDelivered, notes: $notes, timestamp: $timestamp, synced: $synced, syncedAt: $syncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.delivered, delivered) ||
                other.delivered == delivered) &&
            (identical(other.quantityDelivered, quantityDelivered) ||
                other.quantityDelivered == quantityDelivered) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.synced, synced) || other.synced == synced) &&
            (identical(other.syncedAt, syncedAt) ||
                other.syncedAt == syncedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    vendorId,
    customerId,
    date,
    delivered,
    quantityDelivered,
    notes,
    timestamp,
    synced,
    syncedAt,
  );

  /// Create a copy of DeliveryLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryLogImplCopyWith<_$DeliveryLogImpl> get copyWith =>
      __$$DeliveryLogImplCopyWithImpl<_$DeliveryLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryLogImplToJson(this);
  }
}

abstract class _DeliveryLog implements DeliveryLog {
  const factory _DeliveryLog({
    @JsonKey(name: '_id') final String? id,
    required final String vendorId,
    @JsonKey(name: 'customerId', fromJson: _customerIdFromJson)
    required final String customerId,
    required final DateTime date,
    final bool delivered,
    final double? quantityDelivered,
    final String? notes,
    required final DateTime timestamp,
    final bool synced,
    final DateTime? syncedAt,
  }) = _$DeliveryLogImpl;

  factory _DeliveryLog.fromJson(Map<String, dynamic> json) =
      _$DeliveryLogImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  String get vendorId;
  @override
  @JsonKey(name: 'customerId', fromJson: _customerIdFromJson)
  String get customerId;
  @override
  DateTime get date;
  @override
  bool get delivered;
  @override
  double? get quantityDelivered; // Actual quantity delivered
  @override
  String? get notes;
  @override
  DateTime get timestamp; // When log was created
  @override
  bool get synced; // For offline tracking
  @override
  DateTime? get syncedAt;

  /// Create a copy of DeliveryLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryLogImplCopyWith<_$DeliveryLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
