import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/utils.dart';

enum NotificationType {
  /// A test notification
  test,

  /// A direct notification (eg. JCT/CPD, reminder to cancel bookings, etc.)
  direct,

  /// A professor's notice from a course
  notice,

  /// A file upload from a course
  material,

  other,
}

NotificationType _parseNotificationType(String type) {
  switch (type) {
    case 'test':
      return NotificationType.test;
    case 'individuale':
      return NotificationType.direct;
    case 'avvisidoc':
      return NotificationType.notice;
    case 'matdid':
      return NotificationType.material;
    default:
      return NotificationType.other;
  }
}

class Notification {
  final int? id;
  final String? title, body;

  /// The category of this notification
  /// (eg. official reminder, professor notice, etc).
  final NotificationType topic;

  /// The time when this notification was created.
  final DateTime? time;

  /// Whether the user read this notification from the official app
  /// or via [markNotificationRead].
  final bool isRead;

  /// Used only for [NotificationType.notice] and [NotificationType.material].
  final int? course;

  const Notification({
    this.id,
    this.title,
    this.body,
    required this.topic,
    this.time,
    this.isRead = false,
    this.course,
  });
}

Future<List<Notification>> getNotifications(Device device) async {
  final data = await device.post(notificationsRoute, {"operazione": "list"});
  checkError(data);

  return (data.data["messaggi"] as List<dynamic>? ?? []).map((m) {
    final topic = _parseNotificationType(m["transazione"] ?? '');
    final ret = Notification(
      id: m["id"],
      title: m["title"],
      body: m["msg"],
      topic: topic,
      time: parseDate(m["time_proc"], "yyyy/MM/dd HH:mm:ss"),
      isRead: m["is_read"] is bool ? m["is_read"] : false,
      course:
          topic == NotificationType.notice || topic == NotificationType.material
              ? (m["attr_notifica"]?["inc"])
              : null,
    );
    return ret;
  }).toList();
}

Future<void> markNotificationRead(Device device, int id) async {
  final data = await device
      .post(notificationsRoute, {"operazione": "read", "msgid": id});
  checkError(data);
}

Future<void> deleteNotification(Device device, int id) async {
  final data =
      await device.post(notificationsRoute, {"operazione": "del", "msgid": id});
  checkError(data);
}

/// Registers the FCM ID with the server to start receiving notifications.
///
/// [token] is the FCM token received after registering.
///
/// [project_id] is the FCM project ID (default: the project ID
/// for the Polito app).
Future<void> registerPushNotifications(Device device, String token,
    [String projectId = "700615026996"]) async {
  final data = await device.post(registerNotificationsRoute, {
    "rid": token,
    "operazione": "subscribe",
    "sender": projectId,
    "app_version": "2.2.8",
    "app_build": 202089,
    "device_version": device.version,
  });
  checkError(data);
}

class PushNotification {
  final int? id;

  /// The category of this notification (eg. official reminder, professor notice, etc).
  final NotificationType topic;
  final String? title, text;

  /// The time when this notification was sent.
  final DateTime? time;

  const PushNotification({
    this.id,
    required this.topic,
    this.title,
    this.text,
    this.time,
  });
}

/// Parses a FCM message.
///
/// Returns a [PushNotification] to be displayed.
PushNotification parsePushNotification(dynamic data) {
  final topic = _parseNotificationType(data["polito_transazione"] ?? '');
  return PushNotification(
    id: int.parse(data["polito_id_notifica"]),
    topic: topic,
    title: data["title"],
    text: data["message"],
    time: parseDate(data["polito_time_accod"], "yyyy-MM-dd HH:mm:ss"),
  );
}

/// Asks the server to send a push notification with sample text.
Future<void> sendTestPushNotification(Device device) async {
  final data = await device.post(testNotificationRoute, {});
  checkError(data);
}
