import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/material.dart';
import 'package:open_polito_api/src/utils.dart';

/// A recording of a lesson (either in-class or over Zoom/BBB)
class Recording {
  final String? title;

  /// Date of recording
  final DateTime? date;

  final String? url;

  /// A link to a cover image
  final String? coverUrl;

  /// Length in minutes
  final int? length;

  const Recording({
    this.title,
    this.date,
    this.url,
    this.coverUrl,
    this.length,
  });
}

Recording parseVCRecording(Map<String, dynamic> item) {
  final durationParts = RegExp(r'^(\d+)h (\d+)m$').firstMatch(item["duration"]);

  int duration = 0;

  if (durationParts != null) {
    duration = 60 * int.parse(durationParts.group(1)!) +
        int.parse(durationParts.group(2)!);
  }
  return Recording(
    title: item["titolo"],
    date: parseDate(item["data"], "dd/MM/yyyy HH:mm"),
    url: item["video_url"],
    coverUrl: item["cover_url"],
    length: duration,
  );
}

/// A live lesson being streamed over Zoom/BBB
class LiveLesson {
  final String? title;
  final int? idIncarico;
  final String? meetingId;

  /// The starting date
  final DateTime? date;

  const LiveLesson({
    this.title,
    this.idIncarico,
    this.meetingId,
    this.date,
  });
}

class LessonURLResult {
  /// Link to the lesson interface
  final String? url;

  /// false if the meeting has been created but not started
  final String? running;

  const LessonURLResult({this.url, this.running});
}

Future<LessonURLResult> getLessonURL(Device device, LiveLesson lesson) async {
  final data = await device.post(gotoVirtualClassroomRoute, {
    "id_inc": lesson.idIncarico,
    "meetingid": lesson.meetingId,
  });
  checkError(data);
  return LessonURLResult(
    url: data.data["isrunning"],
    running: data.data["url"],
  );
}

class BasicCourseInfo {
  final String? name, code;

  final int? numCredits, idIncarico;

  final String? category;
  final bool? overbooking;

  const BasicCourseInfo({
    this.name,
    this.code,
    this.numCredits,
    this.idIncarico,
    this.category,
    this.overbooking,
  });
}

class CourseInfoParagraph {
  final String? title, text;

  const CourseInfoParagraph({
    this.title,
    this.text,
  });
}

/// A notice issued by a professor.
class Notice {
  final int? id;

  /// Date of publication
  final DateTime? date;

  /// The notice text as raw HTML
  final String? text;

  const Notice({
    this.id,
    this.date,
    this.text,
  });
}

class PersonInfo {
  final String? name, surname;

  const PersonInfo({
    this.name,
    this.surname,
  });
}

class VCRecordings {
  /// From current year
  final List<Recording> current;

  /// From past years
  final Map<int, List<Recording>> past;

  const VCRecordings({
    this.current = const [],
    this.past = const {},
  });
}

class CourseInfo {
  /// The calendar year when this course finishes
  final String? calendarYear;

  /// The year in the degree when this course takes place.
  ///
  /// The value 1 represents the first year of both BSc and MSc courses.
  final int? degreeYear;

  /// The teaching period (it: periodo didattico) when this course takes place (1 or 2, or null if this field is not relevant).
  final int? yearPeriod;

  final PersonInfo? professor;

  final List<Notice> notices;
  final List<MaterialItem> material;

  /// One or more live lessons that are being streamed
  final List<LiveLesson> liveLessons;

  /// Recordings of in-class lessons (it: videolezioni)
  final List<Recording> recordings;

  /// Recordings of BBB/Zoom lessons (it: virtual classroom)
  final VCRecordings vcRecordings;

  /// Extended, human-readable information about the course
  final List<CourseInfoParagraph> info;

  CourseInfo({
    this.calendarYear,
    this.degreeYear,
    this.yearPeriod,
    this.professor,
    this.notices = const [],
    this.material = const [],
    this.liveLessons = const [],
    this.recordings = const [],
    this.vcRecordings = const VCRecordings(),
    this.info = const [],
  });
}

/// Returns whether the course is fictitious (thesis, internship, etc.)
bool isDummy(BasicCourseInfo course) =>
    course.category == "T" || course.category == "A";

/// Fetches information about a course obtained from [getCoursesInfo].
Future<CourseInfo> getExtendedCourseInfo(
    Device device, BasicCourseInfo course) async {
  final data = await device.post(
    extendedCourseInfoRoute,
    course.idIncarico == null
        ? {
            "cod_ins": course.code,
          }
        : {
            "incarico": course.idIncarico,
          },
  );
  checkError(data);

  // The string may be either "1" (eg. year-long extra courses) or "1-1".
  final yearParts =
      data.data["info_corso"]?["periodo"]?.toString().split("-") ?? [];
  if (yearParts.length > 2 || yearParts.isEmpty) {
    throw Exception(
      "Unexpected value for info_corso.periodo: \"${data.data['info_corso']?['periodo']}\"",
    );
  }

  final ret = CourseInfo(
    degreeYear: int.tryParse(yearParts[0]),
    yearPeriod: (yearParts.length > 1) ? int.tryParse(yearParts[1]) : null,
    calendarYear: data.data["info_corso"]?["a_acc"].toString(),
    professor: PersonInfo(
      name: data.data["info_corso"]?["nome_doce"],
      surname: data.data["info_corso"]?["cognome_doce"],
    ),
    notices: (data.data["avvisi"] as List<dynamic>? ?? [])
        .map((a) => Notice(
              date: parseDate(a["data_inizio"], "dd/MM/yyyy"),
              text: a["info"],
            ))
        .toList(),
    material: (data.data["materiale"] as List<dynamic>? ?? [])
        .map(parseMaterial)
        .toList(),
    liveLessons:
        (data.data["virtualclassroom"]?["live"] as List<dynamic>? ?? [])
            .map((vc) => LiveLesson(
                  title: vc["titolo"],
                  idIncarico: vc["id_inc"],
                  meetingId: vc["meetingid"],
                  date: parseDate(vc["data"], "dd/MM/yyyy HH:mm"),
                ))
            .toList(),
    recordings:
        (data.data["videolezioni"]?["lista_videolezioni"] as List<dynamic>? ??
                [])
            .map(
      (item) {
        final durationParts =
            RegExp(r'^(\d+)h (\d+)m$').firstMatch(item["duration"]);

        int duration = 0;

        if (durationParts != null) {
          duration = 60 * int.parse(durationParts.group(1)!) +
              int.parse(durationParts.group(2)!);
        }
        return Recording(
          title: item["titolo"],
          date: parseDate(
              item["data"],
              (item["data"] as String? ?? "").contains(":")
                  ? "dd/MM/yyyy HH:mm"
                  : "dd/MM/yyyy"),
          url: item["video_url"],
          coverUrl: item["cover_url"],
          length: duration,
        );
      },
    ).toList(),
    vcRecordings: VCRecordings(
      current:
          (data.data["virtualclassroom"]?["registrazioni"] as List<dynamic>? ??
                  [])
              .map((e) => parseVCRecording(e as Map<String, dynamic>))
              .toList(),
    ),
    info: (data.data["guida"] as List<dynamic>? ?? [])
        .map(
          (p) => CourseInfoParagraph(
            title: (p["titolo"] as String? ?? "")
                .replaceAll(course.name ?? "", ""),
            text: p["testo"],
          ),
        )
        .toList(),
  );

  for (final recordings
      in (data.data["virtualclassroom"]?["vc_altri_anni"] as List<dynamic>? ??
          [])) {
    final year = int.tryParse(recordings["anno"]);
    if (year != null) {
      ret.vcRecordings.past[year] = (recordings["vc"] as List<dynamic>? ?? [])
          .map((e) => parseVCRecording(e as Map<String, dynamic>))
          .toList();
    }
  }

  return ret;
}
