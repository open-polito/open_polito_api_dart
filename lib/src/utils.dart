import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/models/api_response.dart';
import 'package:uuid/uuid.dart';

/// Makes a POST request to an API endpoint.
/// The [baseUrl] is the API domain, with a trailing slash.
/// Will throw an error if no response is received after [timeout] milliseconds.
/// This is a "raw" function, you will likely want [Device.post] in order to pass the UUID.
Future<APIResponse> post(
    String baseUrl, String endpoint, Map<String, dynamic> data,
    [int timeout = 3000]) async {
  // TODO: AbortController-like functionality
  var response = await http.post(
    Uri.parse(baseUrl + endpoint),
    headers: {
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
    },
    body: "data=${Uri.encodeComponent(json.encode(data))}",
  );

  var decoded = json.decode(response.body);

  return APIResponse.fromJson(decoded);
}

/// Checks that the API server is up.
///
/// [baseUrl] is the API domain, with a trailing slash (default: the Polito server).
Future<void> ping([baseUrl = defaultBaseUrl]) async {
  var data = await post(baseUrl, pingRoute, {});
  checkError(data);
}

/// Checks if the API response contains an error, and throws it.
void checkError(APIResponse data) {
  // print(data.data);
  if (data.esito == null) {
    throw UpstreamException("No \"esito\" field", null);
  }
  for (var key in data.esito!.keys) {
    var context = data.esito![key];
    if (context == null) {
      throw UpstreamException("No context for key \"$key\"", null);
    }
    if (context.stato == null || context.stato! < 0) {
      throw UpstreamException(context.error, context.stato);
    }
  }
}

/// Wraps an error from the upstream API.
class UpstreamException implements Exception {
  final String? message;
  final int? code;

  const UpstreamException(this.message, this.code);

  @override
  String toString() {
    return "UpstreamException: $message ($code)";
  }
}

/// Generates a UUID v4.
String createUuidV4() {
  return Uuid().v4();
}

/// Parse a date string in the [format] format into a [DateTime].
DateTime? parseDate(String dateString, String formatString) {
  final dateFormat = DateFormat(formatString);
  try {
    return dateFormat.parse(dateString);
  } catch (e) {
    return null;
  }
}
