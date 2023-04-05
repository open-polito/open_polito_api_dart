import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/utils.dart';

class BookingSubcontextExtra {
  final String? name;

  /// Example: "Gentile Utente, per potersi prenotare è necessario [...] Dichiaro di aver preso visione dell’informativa sopra riportata".
  final String? privacyNotice;

  /// Example: "L'accesso in Ateneo è consentito soltanto se in possesso di [...]".
  final String? greenPassNotice;

  const BookingSubcontextExtra({
    this.name,
    this.privacyNotice,
    this.greenPassNotice,
  });
}

/// A sub-category of things that can be booked
class BookingSubcontext {
  /// Example: "AULE_STUDIO", "LEZIONI"
  final String? id;

  final BookingSubcontextExtra? ita, eng;

  /// The duration of a slot in minutes
  final int? slotDuration;

  /// The time of day when this subcontext opens
  /// (eg. "8" for "Help desk" means the help desk opens at 8 am)
  /// in 24-hour format.
  final int? openingTime;

  /// The time of day when this subcontext opens in 24-hour format.
  final int? closingTime;

  /// How many slots can be booked per day
  final int? maxBookingsPerDay;

  final bool? hasSeatSelection;

  const BookingSubcontext({
    this.id,
    this.ita,
    this.eng,
    this.slotDuration,
    this.openingTime,
    this.closingTime,
    this.maxBookingsPerDay,
    this.hasSeatSelection,
  });
}

class BookingContextExtra {
  final String? name, description;

  const BookingContextExtra({
    this.name,
    this.description,
  });
}

/// A category of things that can be booked
class BookingContext {
  final String? id;
  final BookingContextExtra? ita, eng;

  /// A list of sub-categories (possibly null, eg. for lessons).
  final List<BookingSubcontext> subcontexts;

  const BookingContext({
    this.id,
    this.ita,
    this.eng,
    this.subcontexts = const [],
  });
}

/// A slot of time when a room may be booked (all times as Unix timestamps).
class BookingSlot {
  final DateTime? slotStart, slotEnd, bookableFrom, bookableUntil;
  final bool? bookable;
  final int? seatsTotal, seatsTaken;

  const BookingSlot({
    this.slotStart,
    this.slotEnd,
    this.bookableFrom,
    this.bookableUntil,
    this.bookable,
    this.seatsTotal,
    this.seatsTaken,
  });
}

class Booking {
  // Example values are reported for a booking for a study room.
  /// Example: "AULE_STUDIO".
  final String? contextId;

  /// Example: "Prenotazione posti in sale studio".
  final String? contextName;

  /// Example: "AS_LINGOTTO_2".
  final String? subcontextId;

  /// Example: "Lingotto - Sala studio Le Corbusier".
  final String? subcontextName;

  final DateTime? startTime, endTime;

  /// Example: "01PECQW" (only for lessons).
  final String? courseId;

  final String? courseName;

  const Booking({
    this.contextId,
    this.contextName,
    this.subcontextId,
    this.subcontextName,
    this.startTime,
    this.endTime,
    this.courseId,
    this.courseName,
  });
}

/// Returns a link to a barcode that may be scanned by Polito employees to access bookings.
String barcodeUrl(String username) =>
    "https://didattica.polito.it/bc/barcode.php?barcode=$username&width=500&height=200&format=gif";

DateTime? _millisToDateTime(dynamic millis) {
  if (millis == null) return null;
  if (millis is int) {
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }
}

/// Returns a list of bookings made by this user.
Future<List<Booking>> getBookings(Device device) async {
  final data = await device.post(bookingsRoute, {"operazione": "getBookings"});
  checkError(data);
  return (data.data["booking_api"]?["data"] as List<dynamic>? ?? []).map((b) {
    final matches =
        RegExp(r"<h3><b>([^<]+)<\/h3><\/b>").firstMatch(b["lezione"]);
    String? courseId, courseName;

    if (matches != null) {
      final lesson = matches.group(1);
      final parts = lesson?.split(" ");
      courseId = parts?.last;
      courseName = lesson?.replaceAll(courseId ?? "", "").trim();
    }

    final ret = Booking(
      contextId: b["id_ambito"],
      contextName: b["descr_ambito"],
      subcontextId: b["id_subambito"],
      subcontextName: b["nome_subambito"],
      startTime: _millisToDateTime(b["d_ini_turno_ts"]),
      endTime: _millisToDateTime(b["d_fin_turno_ts"]),
      courseId: courseId,
      courseName: courseName,
    );

    return ret;
  }).toList();
}

/// Returns a list of booking contexts.
Future<List<BookingContext>> getContexts(Device device) async {
  final data = await device.post(bookingsRoute, {
    "operazione": "getAmbiti",
  });
  checkError(data);
  return (data.data["booking_api"]?["ambiti"] as List<dynamic>? ?? [])
      .map((c) => BookingContext(
            id: c["id"],
            ita: BookingContextExtra(
              name: c["titolo_ita"]?.trim(),
              description: c["descr_ita"]?.trim(),
            ),
            eng: BookingContextExtra(
              name: c["titolo_eng"]?.trim(),
              description: c["descr_eng"]?.trim(),
            ),
            subcontexts: (c["subambiti"]?["subambiti"] as List<dynamic>? ?? [])
                .map((s) => BookingSubcontext(
                      id: s["id"],
                      ita: BookingSubcontextExtra(
                        name: s["titolo_ita"]?.trim(),
                        privacyNotice: s["opt_tpl_privacy"],
                        greenPassNotice: s["opt_tpl_gp"],
                      ),
                      eng: BookingSubcontextExtra(
                        name: s["titolo_eng"]?.trim(),
                        privacyNotice: s["opt_tpl_privacy"],
                        greenPassNotice: s["opt_tpl_gp"],
                      ),
                    ))
                .toList(),
          ))
      .toList();
}

Future<List<BookingSlot>> getSlots(
    Device device, String contextId, String? subcontextId,
    [DateTime? date]) async {
  date ??= DateTime.now();
  final input = {
    "operazione": "getTurni",
    "ambito": contextId,
    "from": date.millisecondsSinceEpoch,
    "to": date.millisecondsSinceEpoch + 1000 * 3600 * 24,
  };
  if (subcontextId != null) input["subambito"] = subcontextId;

  final data = await device.post(bookingsRoute, input);
  checkError(data);
  return (data.data["booking_api"]?["turni"] as List<dynamic>? ?? [])
      .map((t) => BookingSlot(
            slotStart: parseDate(t["d_ini"], "DD/MM/YYYY hh:mm"),
            slotEnd: parseDate(t["d_fin"], "DD/MM/YYYY hh:mm"),
            bookableFrom: _millisToDateTime(t["d_ini_preno_ts"]),
            bookableUntil: _millisToDateTime(t["d_fin_preno_ts"]),
            bookable: t["bookable"],
            seatsTotal: t["posti"],
            seatsTaken: t["postiOccupati"],
          ))
      .toList();
}
