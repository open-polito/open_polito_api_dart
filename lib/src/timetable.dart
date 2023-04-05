import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/course.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/utils.dart';

/// A slot for a lesson
class TimetableSlot {
  /// The start time for the slot
  final DateTime? startTime;

  /// The end time for the slot
  final DateTime? endTime;

  /// Example: "Lezione/Esercitazione"
  final String? type;

  final String? courseName;
  final PersonInfo? professor;

  /// Example: "R1b"
  final String? room;

  /// Example: "https://www.polito.it/ateneo/sedi/?bl_id=TO_CIT06&fl_id=XP01&rm_id=006"
  final String? roomUrl;

  const TimetableSlot({
    this.startTime,
    this.endTime,
    this.type,
    this.courseName,
    this.professor,
    this.room,
    this.roomUrl,
  });
}

Future<List<TimetableSlot>> getTimetable(Device device,
    [DateTime? date]) async {
  date ??= DateTime.now();
  final data = await device.post(timetableRoute, {
    //
    "data_rif":
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
  });
  checkError(data);
  if (data.data["orari"] == "") {
    // the API returns "" when there are no lessons
    return [];
  }

  return (data.data["orari"] as List<dynamic>? ?? [])
      .map((o) => TimetableSlot(
          startTime: parseDate(o["ORA_INIZIO"], "dd/MM/yyyy HH:mm:ss"),
          endTime: parseDate(o["ORA_FINE"], "dd/MM/yyyy HH:mm:ss"),
          type: o["TIPOLOGIA_EVENTO"],
          courseName: o["TITOLO_MATERIA"],
          professor: PersonInfo(
            name: o["NOME"],
            surname: o["COGNOME"],
          ),
          room: o["AULA"],
          roomUrl: o["URL_MAPPA_AULA"]))
      .toList();
}
