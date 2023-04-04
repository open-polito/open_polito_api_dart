import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/course.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/utils.dart';

class PermanentMark {
  final String? name;
  final int? numCredits;
  final String? mark;

  /// The date of the exam
  final DateTime? date;

  const PermanentMark({
    this.name,
    this.numCredits,
    this.mark,
    this.date,
  });
}

enum ExamStatus { unknown, p, c, r, v }

ExamStatus parseExamStatus(String? status) {
  switch (status) {
    case "P":
      return ExamStatus.p;
    case "C":
      return ExamStatus.c;
    case "R":
      return ExamStatus.r;
    case "V":
      return ExamStatus.v;
    default:
      return ExamStatus.unknown;
  }
}

class ProvisionalMark {
  final String? name, mark;

  /// The date of the exam
  final DateTime? date;
  final bool? failed, absent;

  /// Refer to https://didattica.polito.it/img/RE_stati.jpg
  /// for information about the statuses.
  final ExamStatus? status;

  final String? professorId, message;

  const ProvisionalMark({
    this.name,
    this.mark,
    this.date,
    this.failed,
    this.absent,
    this.status,
    this.professorId,
    this.message,
  });
}

class CourseMarks {
  final List<PermanentMark> permanent;
  final List<ProvisionalMark> provisional;

  const CourseMarks({
    this.permanent = const [],
    this.provisional = const [],
  });
}

class CoursePlans {
  final List<BasicCourseInfo> standard;
  final List<BasicCourseInfo> extra;

  const CoursePlans({
    this.standard = const [],
    this.extra = const [],
  });
}

class CoursesInfo {
  final CourseMarks? marks;
  final CoursePlans? coursePlan;

  const CoursesInfo({
    this.marks,
    this.coursePlan,
  });
}

Future<CoursesInfo> getCoursesInfo(Device device) async {
  final voteData = await device.post(studentRoute, {});
  checkError(voteData);
  final provisionalData = await device.post(marksRoute, {});
  checkError(provisionalData);

  return CoursesInfo(
    marks: CourseMarks(
      permanent: (voteData.data["libretto"] as List<dynamic>? ?? [])
          .map((s) => PermanentMark(
                name: s["nome_ins"],
                numCredits: s["n_cfe"],
                mark: s["desc_voto"],
                date: parseDate(s["d_esame"], "dd/MM/yyyy"),
              ))
          .toList(),
      provisional:
          (provisionalData.data["valutazioni_provvisorie"] as List<dynamic>? ??
                  [])
              .map((v) => ProvisionalMark(
                    name: v["NOME_INS"],
                    mark: v["VOTO_ESAME"],
                    date: parseDate(v["DATA_ESAME"], "dd-MM-yyyy"),
                    failed: v["FALLITO"] == "S",
                    absent: v["ASSENTE"] == "S",
                    status: parseExamStatus(v["STATO"]),
                    professorId: v["MAT_DOCENTE"].toString(),
                    message: v["T_MESSAGGIO"],
                  ))
              .toList(),
    ),
    coursePlan: CoursePlans(
      standard: (voteData.data["carico_didattico"] as List<dynamic>? ?? [])
          .map((c) => BasicCourseInfo(
                name: c["nome_ins"],
                code: c["cod_ins"],
                numCredits: c["n_cfe"],
                idIncarico: c["id_inc_1"],
                category: c["categoria"],
                overbooking: c["overbooking"] != "N",
              ))
          .toList(),
      extra: (voteData.data["altri_corsi"] as Map<String, dynamic>? ?? {})
          .entries
          .expand((element) => element.value ?? [])
          .map((c) => BasicCourseInfo(
                name: c["nome_ins_1"],
                code: c["cod_ins"],
                numCredits: c["n_cfe"],
                idIncarico: c["id_inc_1"],
                overbooking: false,
              ))
          .toList(),
    ),
  );
}
