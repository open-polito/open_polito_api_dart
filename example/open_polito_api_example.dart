import 'package:open_polito_api/src/booking.dart';
import 'package:open_polito_api/src/course.dart';
import 'package:open_polito_api/src/courses.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/exam_sessions.dart';
import 'package:open_polito_api/src/material.dart';
import 'package:open_polito_api/src/notifications.dart';
import 'package:open_polito_api/src/tickets.dart';
import 'package:open_polito_api/src/timetable.dart';
import 'package:open_polito_api/src/utils.dart';
import 'package:open_polito_api/src/user.dart';

const username = "S123456";
const password = "password";

void main() async {
  final uuid = createUuidV4();
  final device = Device(uuid);

  await ping();
  await device.register();
  final res = await device.loginWithCredentials(username, password);
  print("Token: ${res.token}");
  print("Unread mail: ${await getUnreadMail(device)}");
  print("Timetable: ${(await getTimetable(device))}");

  final coursesInfo = await getCoursesInfo(device);
  print("Courses: $coursesInfo");
  final course =
      await getExtendedCourseInfo(device, coursesInfo.coursePlan!.standard[2]);
  print("Course: $course");
  print(coursesInfo.coursePlan!.standard[2]);
  print(await getDownloadURL(device, code: "33278489"));

  final bookings = await getBookings(device);
  print("Bookings: $bookings");
  final slots =
      await getSlots(device, "AULE_STUDIO", "AS_LINGOTTO_2", DateTime.now());
  print("Slots: $slots");
  final contexts = await getContexts(device);
  print("Contexts: $contexts");

  final exams = await getExamSessions(device);
  print("Exams: $exams");

  final tickets = await getTickets(device);
  print("Tickets: $tickets");
  if (tickets.isNotEmpty) {
    print("Ticket: ${await getTicket(device, tickets[0].id!)}");
  }

  final notifications = await getNotifications(device);
  print("Notifications: $notifications");

  await device.logout();
}
