import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/utils.dart';

class ExamError {
  /// 0 = ok; -237 = the user already booked this exam.
  final int? id;
  final String? ita;
  final String? eng;

  const ExamError({this.id, this.ita, this.eng});
}

/// A session on which an exam can be sat
class ExamSession {
  /// A unique ID for this session
  final int? sessionId;

  /// Example: "01URPOV"
  final String? courseId;

  /// Unknown
  final int? signupId;

  /// Example: "Machine learning for vision and multimedia (AA-ZZ)"
  final String? examName;

  final bool? userIsSignedUp;

  /// The date when this session will take place
  final DateTime? date;

  final List<String> rooms;

  /// Example: "Scritto e Orale"
  final String? type;

  final ExamError? error;

  /// An error message if the user can't sign up for the session. Empty otherwise.
  final String? errorMsg;

  /// The deadline for signing up for this session
  final DateTime? signupDeadline;

  const ExamSession({
    this.sessionId,
    this.courseId,
    this.signupId,
    this.examName,
    this.userIsSignedUp,
    this.date,
    this.rooms = const [],
    this.type,
    this.error,
    this.errorMsg,
    this.signupDeadline,
  });
}

/// Returns exam sessions starting with the closest one.
Future<List<ExamSession>> getExamSessions(Device device) async {
  final data = await device.post(examsRoute, {"operazione": "LISTA"});
  checkError(data);

  final res = (data.data["esami"]?["data"] as List<dynamic>? ?? [])
      .map((e) => ExamSession(
          sessionId: e["ID_VERBALE"],
          courseId: e["COD_INS_STUDENTE"],
          signupId: e["ID"],
          examName: e["NOME_INS"],
          userIsSignedUp: e["ID"] != -1,
          date: parseDate(
              "${e['DATA_APPELLO']} ${e['ORA_APPELLO']}", "dd/MM/yyyy HH:mm"),
          rooms: (e["AULA"] as String? ?? "").split("; "),
          type: e["DESC_TIPO"],
          error: ExamError(
            id: e["ID_MSG"],
            ita: (e["ID_MSG"] == 0 || e["ID"] != -1) ? "" : e["DESCR_MSG"],
            eng: (e["ID_MSG"] == 0 || e["ID"] != -1) ? "" : e["DESCR_MSG_ENG"],
          ),
          signupDeadline: parseDate(e["SCADENZA"], "dd/MM/yyyy HH:mm")))
      .toList();

  res.sort(((a, b) {
    final dateA = a.date, dateB = b.date;
    if (dateA == null || dateB == null) return 0;
    return dateA.compareTo(dateB);
  }));

  return res;
}

/// Book an exam session.
///
/// Returns an exam session ID that is currently unused.
Future<int?> bookExamSession(
    Device device, int sessionId, String examId) async {
  final data = await device.post(examsRoute, {
    "operazione": "PRENOTA",
    "cod_ins": examId,
    "id_verbale": sessionId,
  });
  checkError(data);
  return data.data["esami"]?["id"];
}

/// Cancel a booking for an exam session.
Future<void> cancelExamSession(
    Device device, int sessionId, String examId) async {
  final data = await device.post(examsRoute, {
    "operazione": "ANNULLA",
    "cod_ins": examId,
    "id_verbale": sessionId,
  });
  checkError(data);
}
