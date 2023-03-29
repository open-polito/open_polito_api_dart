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
}

/// A function that logs network requests
typedef RequestLogger = void Function(Entry entry);

void _defaultRequestLogger(Entry entry) {}

/// A class with credentials for accessing the upstream API
class Device {
  /// A unique identifier for the device
  final String uuid;

  /// A token for authorizing the user
  final String? token;

  /// The request timeout in milliseconds
  final int timeout;

  /// A callback for network requests
  final RequestLogger? requestLogger;

  /// The base URL for the API
  final String baseUrl;

  /// The device version (required for notifications)
  String? version;

  /// [requestLogger] is a callback that is called after network requests
  Device(this.uuid,
      [this.token,
      this.timeout = 3000,
      this.requestLogger = _defaultRequestLogger,
      this.baseUrl = "https://app.didattica.polito.it/"]);
}
