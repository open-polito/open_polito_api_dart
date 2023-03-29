import 'dart:convert';

import 'package:http/http.dart' as http;

class Result {
  int stato;
  String? error;

  Result({required this.stato, this.error});
}

class APIResponse {
  dynamic data;
  Result esito;

  APIResponse({
    required this.data,
    required this.esito,
  });
}

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
    // body: "data=" + encodeURIComponent(JSON.stringify(data))
  );

  var decoded = json.decode(response.body);

  return APIResponse(
    data: decoded["data"],
  );
}
