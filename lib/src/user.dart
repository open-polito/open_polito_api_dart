import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/utils.dart';

class PersonalData {
  /// The current student ID (it: matricola). Example: 123456
  final String? currentId;

  /// Past and present student IDs.
  final List<dynamic>? ids;

  final String? name, surname;

  /// The type of degree (BSc or MSc), in Italian.
  /// Example: "Corso di Laurea in"
  final String? degreeType;

  /// The name of the degree, in Italian.
  /// Example: "INGEGNERIA INFORMATICA"
  final String? degreeName;

  const PersonalData({
    this.currentId,
    this.ids,
    this.name,
    this.surname,
    this.degreeType,
    this.degreeName,
  });
}

class UnreadMailResult {
  final int total;
  final String unread;

  const UnreadMailResult({
    required this.total,
    required this.unread,
  });
}

Future<UnreadMailResult> getUnreadMail(Device device) async {
  var data = await device.post(mailRoute, {});
  checkError(data);

  var mailData = data.data?["mail"];

  var unread = mailData?["unread"];

  if (unread is int) {
    unread = unread.toString();
  }

  return UnreadMailResult(
    total: mailData?["messages"],
    unread: unread,
  );
}

/// Returns an URL to open the Web email client (different for each user).
Future<String?> emailUrl(Device device) async {
  var data = await device.post(gotoWebmailRoute, {});
  checkError(data);
  return data.data?["url"];
}
