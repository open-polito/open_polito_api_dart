import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/models/api_response.dart';
import 'package:open_polito_api/src/user.dart';
import 'package:open_polito_api/src/utils.dart' as utils;

class DeviceData {
  final String platform;
  final String version;
  final String model;
  final String manufacturer;

  const DeviceData({
    required this.platform,
    required this.version,
    required this.model,
    required this.manufacturer,
  });
}

const defaultDeviceData = DeviceData(
  platform: 'Open Polito',
  version: '1',
  model: 'Potato',
  manufacturer: 'Apple',
);

/// A network request
class Entry {
  final String endpoint;
  final Map<String, dynamic> request;
  final Map<String, dynamic> response;

  Entry({
    required this.endpoint,
    required this.request,
    required this.response,
  });

  @override
  String toString() {
    return "Entry: $endpoint\nRequest: $request\nResponse: $response";
  }
}

/// A function that logs network requests
typedef RequestLogger = void Function(Entry entry);

void _defaultRequestLogger(Entry entry) {}

class LoginResult {
  final PersonalData data;
  final String token;

  LoginResult({
    required this.data,
    required this.token,
  });
}

/// A class with credentials for accessing the upstream API
class Device {
  /// A unique identifier for the device
  final String uuid;

  /// A token for authorizing the user
  String? token;

  /// The request timeout in milliseconds
  final int timeout;

  /// A callback for network requests
  final RequestLogger requestLogger;

  /// The base URL for the API
  final String baseUrl;

  /// The device version (required for notifications)
  String? version;

  /// [requestLogger] is a callback that is called after network requests.
  Device(
    this.uuid, [
    this.token,
    this.timeout = 3000,
    this.requestLogger = _defaultRequestLogger,
    this.baseUrl = defaultBaseUrl,
  ]);

  PersonalData _personalDataFromJson(Map<String, dynamic>? data) {
    var personalData = data?["anagrafica"];
    return PersonalData(
      currentId: personalData?["matricola"],
      ids: personalData?["all_matricolas"],
      name: personalData?["nome"],
      surname: personalData?["cognome"],
      degreeType: personalData?["tipo_corso_laurea"],
      degreeName: personalData?["nome_corso_laurea"],
    );
  }

  /// Registers the device with the API (may be required to access notifications).
  Future<void> register([DeviceData deviceData = defaultDeviceData]) async {
    Map<String, String> data = {
      "regID": uuid,
      "uuid": uuid,
      "device_platform": deviceData.platform,
      "device_version": deviceData.version,
      "device_model": deviceData.model,
      "device_manufacturer": deviceData.manufacturer,
    };

    var registerData = await utils.post(baseUrl, registerRoute, data);
    requestLogger(Entry(
      endpoint: registerRoute,
      request: data,
      response: registerData.toJson(),
    ));
    utils.checkError(registerData);
    version = deviceData.version;
  }

  /// Logs in with username and password
  Future<LoginResult> loginWithCredentials(
      String username, String password) async {
    Map<String, String> data = {
      "regID": uuid,
      "username": username,
      "password": password,
    };

    var userData = await utils.post(baseUrl, loginRoute, data);
    requestLogger(Entry(
      endpoint: loginRoute,
      request: data,
      response: userData.toJson(),
    ));
    utils.checkError(userData);

    var newToken = userData.data?["login"]?["token"];

    if (newToken == null) {
      throw utils.UpstreamException("No token in response", null);
    }

    token = newToken;

    return LoginResult(
      data: _personalDataFromJson(userData.data),
      token: newToken,
    );
  }

  /// Refreshes an authorization token by returning a new one
  Future<LoginResult> loginWithToken(String username, String loginToken) async {
    Map<String, String> data = {
      "regID": uuid,
      "username": username,
      "token": loginToken,
    };

    var userData = await utils.post(baseUrl, loginRoute, data);
    requestLogger(Entry(
      endpoint: loginRoute,
      request: data,
      response: userData.toJson(),
    ));
    utils.checkError(userData);

    var newToken = userData.data?["login"]?["token"];

    if (newToken == null) {
      throw utils.UpstreamException("No token in response", null);
    }

    token = newToken;

    return LoginResult(
      data: _personalDataFromJson(userData.data),
      token: newToken,
    );
  }

  /// Invalidates the token
  Future<void> logout() async {
    await post(logoutRoute, {});
  }

  /// Sends a raw API request, appending the device credentials
  Future<APIResponse> post(String endpoint, Map<String, dynamic> data) async {
    if (token == null) {
      throw Exception("No token configured: you must login first");
    }

    var newData = {
      ...data,
      "regID": uuid,
      "token": token,
    };
    var response = await utils.post(baseUrl, endpoint, newData, timeout);
    requestLogger(Entry(
      endpoint: endpoint,
      request: newData,
      response: response.toJson(),
    ));
    return response;
  }
}
