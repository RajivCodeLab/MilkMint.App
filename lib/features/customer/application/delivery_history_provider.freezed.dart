// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_history_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DeliveryHistoryState {
  List<DeliveryLog> get deliveries => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  DateTime? get selectedMonth => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryHistoryStateCopyWith<DeliveryHistoryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryHistoryStateCopyWith<$Res> {
  factory $DeliveryHistoryStateCopyWith(
    DeliveryHistoryState value,
    $Res Function(DeliveryHistoryState) then,
  ) = _$DeliveryHistoryStateCopyWithImpl<$Res, DeliveryHistoryState>;
  @useResult
  $Res call({
    List<DeliveryLog> deliveries,
    bool isLoading,
    String? error,
    DateTime? selectedMonth,
  });
}

/// @nodoc
class _$DeliveryHistoryStateCopyWithImpl<
  $Res,
  $Val extends DeliveryHistoryState
>
    implements $DeliveryHistoryStateCopyWith<$Res> {
  _$DeliveryHistoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deliveries = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedMonth = freezed,
  }) {
    return _then(
      _value.copyWith(
            deliveries: null == deliveries
                ? _value.deliveries
                : deliveries // ignore: cast_nullable_to_non_nullable
                      as List<DeliveryLog>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedMonth: freezed == selectedMonth
                ? _value.selectedMonth
                : selectedMonth // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeliveryHistoryStateImplCopyWith<$Res>
    implements $DeliveryHistoryStateCopyWith<$Res> {
  factory _$$DeliveryHistoryStateImplCopyWith(
    _$DeliveryHistoryStateImpl value,
    $Res Function(_$DeliveryHistoryStateImpl) then,
  ) = __$$DeliveryHistoryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<DeliveryLog> deliveries,
    bool isLoading,
    String? error,
    DateTime? selectedMonth,
  });
}

/// @nodoc
class __$$DeliveryHistoryStateImplCopyWithImpl<$Res>
    extends _$DeliveryHistoryStateCopyWithImpl<$Res, _$DeliveryHistoryStateImpl>
    implements _$$DeliveryHistoryStateImplCopyWith<$Res> {
  __$$DeliveryHistoryStateImplCopyWithImpl(
    _$DeliveryHistoryStateImpl _value,
    $Res Function(_$DeliveryHistoryStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeliveryHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deliveries = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedMonth = freezed,
  }) {
    return _then(
      _$DeliveryHistoryStateImpl(
        deliveries: null == deliveries
            ? _value._deliveries
            : deliveries // ignore: cast_nullable_to_non_nullable
                  as List<DeliveryLog>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedMonth: freezed == selectedMonth
            ? _value.selectedMonth
            : selectedMonth // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$DeliveryHistoryStateImpl implements _DeliveryHistoryState {
  const _$DeliveryHistoryStateImpl({
    final List<DeliveryLog> deliveries = const [],
    this.isLoading = false,
    this.error,
    this.selectedMonth,
  }) : _deliveries = deliveries;

  final List<DeliveryLog> _deliveries;
  @override
  @JsonKey()
  List<DeliveryLog> get deliveries {
    if (_deliveries is EqualUnmodifiableListView) return _deliveries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deliveries);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final DateTime? selectedMonth;

  @override
  String toString() {
    return 'DeliveryHistoryState(deliveries: $deliveries, isLoading: $isLoading, error: $error, selectedMonth: $selectedMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryHistoryStateImpl &&
            const DeepCollectionEquality().equals(
              other._deliveries,
              _deliveries,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedMonth, selectedMonth) ||
                other.selectedMonth == selectedMonth));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_deliveries),
    isLoading,
    error,
    selectedMonth,
  );

  /// Create a copy of DeliveryHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryHistoryStateImplCopyWith<_$DeliveryHistoryStateImpl>
  get copyWith =>
      __$$DeliveryHistoryStateImplCopyWithImpl<_$DeliveryHistoryStateImpl>(
        this,
        _$identity,
      );
}

abstract class _DeliveryHistoryState implements DeliveryHistoryState {
  const factory _DeliveryHistoryState({
    final List<DeliveryLog> deliveries,
    final bool isLoading,
    final String? error,
    final DateTime? selectedMonth,
  }) = _$DeliveryHistoryStateImpl;

  @override
  List<DeliveryLog> get deliveries;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  DateTime? get selectedMonth;

  /// Create a copy of DeliveryHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryHistoryStateImplCopyWith<_$DeliveryHistoryStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
