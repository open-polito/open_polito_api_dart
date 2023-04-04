import 'package:open_polito_api/src/course.dart';
import 'package:open_polito_api/src/courses.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/material.dart';
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
  // TODO print("Timetable: ${await getUnreadMail(device)}");

  final coursesInfo = await getCoursesInfo(device);
  print("Courses: $coursesInfo");
  final course =
      await getExtendedCourseInfo(device, coursesInfo.coursePlan!.standard[2]);
  print("Course: $course");
  print(coursesInfo.coursePlan!.standard[2]);
  print(await getDownloadURL(device, code: "33278489"));
  // TODO final bookings = await getBookings(device);

  // TODO slots, tickets, ticket

  await device.logout();
}
