// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offline_sync_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SyncStatus {
  bool get isSyncing => throw _privateConstructorUsedError;
  int get pendingCount => throw _privateConstructorUsedError;
  int get syncedCount => throw _privateConstructorUsedError;
  int get failedCount => throw _privateConstructorUsedError;
  DateTime? get lastSyncTime => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncStatusCopyWith<SyncStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncStatusCopyWith<$Res> {
  factory $SyncStatusCopyWith(
    SyncStatus value,
    $Res Function(SyncStatus) then,
  ) = _$SyncStatusCopyWithImpl<$Res, SyncStatus>;
  @useResult
  $Res call({
    bool isSyncing,
    int pendingCount,
    int syncedCount,
    int failedCount,
    DateTime? lastSyncTime,
    String? error,
  });
}

/// @nodoc
class _$SyncStatusCopyWithImpl<$Res, $Val extends SyncStatus>
    implements $SyncStatusCopyWith<$Res> {
  _$SyncStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSyncing = null,
    Object? pendingCount = null,
    Object? syncedCount = null,
    Object? failedCount = null,
    Object? lastSyncTime = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            isSyncing: null == isSyncing
                ? _value.isSyncing
                : isSyncing // ignore: cast_nullable_to_non_nullable
                      as bool,
            pendingCount: null == pendingCount
                ? _value.pendingCount
                : pendingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            syncedCount: null == syncedCount
                ? _value.syncedCount
                : syncedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            failedCount: null == failedCount
                ? _value.failedCount
                : failedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastSyncTime: freezed == lastSyncTime
                ? _value.lastSyncTime
                : lastSyncTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncStatusImplCopyWith<$Res>
    implements $SyncStatusCopyWith<$Res> {
  factory _$$SyncStatusImplCopyWith(
    _$SyncStatusImpl value,
    $Res Function(_$SyncStatusImpl) then,
  ) = __$$SyncStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isSyncing,
    int pendingCount,
    int syncedCount,
    int failedCount,
    DateTime? lastSyncTime,
    String? error,
  });
}

/// @nodoc
class __$$SyncStatusImplCopyWithImpl<$Res>
    extends _$SyncStatusCopyWithImpl<$Res, _$SyncStatusImpl>
    implements _$$SyncStatusImplCopyWith<$Res> {
  __$$SyncStatusImplCopyWithImpl(
    _$SyncStatusImpl _value,
    $Res Function(_$SyncStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSyncing = null,
    Object? pendingCount = null,
    Object? syncedCount = null,
    Object? failedCount = null,
    Object? lastSyncTime = freezed,
    Object? error = freezed,
  }) {
    return _then(
      _$SyncStatusImpl(
        isSyncing: null == isSyncing
            ? _value.isSyncing
            : isSyncing // ignore: cast_nullable_to_non_nullable
                  as bool,
        pendingCount: null == pendingCount
            ? _value.pendingCount
            : pendingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        syncedCount: null == syncedCount
            ? _value.syncedCount
            : syncedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        failedCount: null == failedCount
            ? _value.failedCount
            : failedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastSyncTime: freezed == lastSyncTime
            ? _value.lastSyncTime
            : lastSyncTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SyncStatusImpl with DiagnosticableTreeMixin implements _SyncStatus {
  const _$SyncStatusImpl({
    this.isSyncing = false,
    this.pendingCount = 0,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.lastSyncTime,
    this.error,
  });

  @override
  @JsonKey()
  final bool isSyncing;
  @override
  @JsonKey()
  final int pendingCount;
  @override
  @JsonKey()
  final int syncedCount;
  @override
  @JsonKey()
  final int failedCount;
  @override
  final DateTime? lastSyncTime;
  @override
  final String? error;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncStatus(isSyncing: $isSyncing, pendingCount: $pendingCount, syncedCount: $syncedCount, failedCount: $failedCount, lastSyncTime: $lastSyncTime, error: $error)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SyncStatus'))
      ..add(DiagnosticsProperty('isSyncing', isSyncing))
      ..add(DiagnosticsProperty('pendingCount', pendingCount))
      ..add(DiagnosticsProperty('syncedCount', syncedCount))
      ..add(DiagnosticsProperty('failedCount', failedCount))
      ..add(DiagnosticsProperty('lastSyncTime', lastSyncTime))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncStatusImpl &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            (identical(other.pendingCount, pendingCount) ||
                other.pendingCount == pendingCount) &&
            (identical(other.syncedCount, syncedCount) ||
                other.syncedCount == syncedCount) &&
            (identical(other.failedCount, failedCount) ||
                other.failedCount == failedCount) &&
            (identical(other.lastSyncTime, lastSyncTime) ||
                other.lastSyncTime == lastSyncTime) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isSyncing,
    pendingCount,
    syncedCount,
    failedCount,
    lastSyncTime,
    error,
  );

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncStatusImplCopyWith<_$SyncStatusImpl> get copyWith =>
      __$$SyncStatusImplCopyWithImpl<_$SyncStatusImpl>(this, _$identity);
}

abstract class _SyncStatus implements SyncStatus {
  const factory _SyncStatus({
    final bool isSyncing,
    final int pendingCount,
    final int syncedCount,
    final int failedCount,
    final DateTime? lastSyncTime,
    final String? error,
  }) = _$SyncStatusImpl;

  @override
  bool get isSyncing;
  @override
  int get pendingCount;
  @override
  int get syncedCount;
  @override
  int get failedCount;
  @override
  DateTime? get lastSyncTime;
  @override
  String? get error;

  /// Create a copy of SyncStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncStatusImplCopyWith<_$SyncStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
