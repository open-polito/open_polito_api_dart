import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_polito_api/src/models/result.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@freezed
class APIResponse with _$APIResponse {
  const factory APIResponse({
    dynamic data,
    Result? esito,
  }) = _APIResponse;

  factory APIResponse.fromJson(Map<String, dynamic> json) =>
      _$APIResponseFromJson(json);
}
