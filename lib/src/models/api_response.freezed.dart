// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

APIResponse _$APIResponseFromJson(Map<String, dynamic> json) {
  return _APIResponse.fromJson(json);
}

/// @nodoc
mixin _$APIResponse {
  dynamic get data => throw _privateConstructorUsedError;
  Result? get esito => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $APIResponseCopyWith<APIResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $APIResponseCopyWith<$Res> {
  factory $APIResponseCopyWith(
          APIResponse value, $Res Function(APIResponse) then) =
      _$APIResponseCopyWithImpl<$Res, APIResponse>;
  @useResult
  $Res call({dynamic data, Result? esito});

  $ResultCopyWith<$Res>? get esito;
}

/// @nodoc
class _$APIResponseCopyWithImpl<$Res, $Val extends APIResponse>
    implements $APIResponseCopyWith<$Res> {
  _$APIResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? esito = freezed,
  }) {
    return _then(_value.copyWith(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
      esito: freezed == esito
          ? _value.esito
          : esito // ignore: cast_nullable_to_non_nullable
              as Result?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ResultCopyWith<$Res>? get esito {
    if (_value.esito == null) {
      return null;
    }

    return $ResultCopyWith<$Res>(_value.esito!, (value) {
      return _then(_value.copyWith(esito: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_APIResponseCopyWith<$Res>
    implements $APIResponseCopyWith<$Res> {
  factory _$$_APIResponseCopyWith(
          _$_APIResponse value, $Res Function(_$_APIResponse) then) =
      __$$_APIResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({dynamic data, Result? esito});

  @override
  $ResultCopyWith<$Res>? get esito;
}

/// @nodoc
class __$$_APIResponseCopyWithImpl<$Res>
    extends _$APIResponseCopyWithImpl<$Res, _$_APIResponse>
    implements _$$_APIResponseCopyWith<$Res> {
  __$$_APIResponseCopyWithImpl(
      _$_APIResponse _value, $Res Function(_$_APIResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? esito = freezed,
  }) {
    return _then(_$_APIResponse(
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
      esito: freezed == esito
          ? _value.esito
          : esito // ignore: cast_nullable_to_non_nullable
              as Result?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_APIResponse implements _APIResponse {
  const _$_APIResponse({this.data, this.esito});

  factory _$_APIResponse.fromJson(Map<String, dynamic> json) =>
      _$$_APIResponseFromJson(json);

  @override
  final dynamic data;
  @override
  final Result? esito;

  @override
  String toString() {
    return 'APIResponse(data: $data, esito: $esito)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_APIResponse &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.esito, esito) || other.esito == esito));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(data), esito);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_APIResponseCopyWith<_$_APIResponse> get copyWith =>
      __$$_APIResponseCopyWithImpl<_$_APIResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_APIResponseToJson(
      this,
    );
  }
}

abstract class _APIResponse implements APIResponse {
  const factory _APIResponse({final dynamic data, final Result? esito}) =
      _$_APIResponse;

  factory _APIResponse.fromJson(Map<String, dynamic> json) =
      _$_APIResponse.fromJson;

  @override
  dynamic get data;
  @override
  Result? get esito;
  @override
  @JsonKey(ignore: true)
  _$$_APIResponseCopyWith<_$_APIResponse> get copyWith =>
      throw _privateConstructorUsedError;
}
