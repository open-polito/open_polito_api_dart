// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_APIResponse _$$_APIResponseFromJson(Map<String, dynamic> json) =>
    _$_APIResponse(
      data: json['data'],
      esito: json['esito'] == null
          ? null
          : Result.fromJson(json['esito'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_APIResponseToJson(_$_APIResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'esito': instance.esito,
    };
