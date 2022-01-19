import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeAgo;

extension DateTimeExtension on DateTime {
  String timeAgoExt() {
    final currentDate = DateTime.now();
    if (currentDate.difference(this).inDays > 1) {
      return DateFormat.yMMMd().format(this);
    }
    return timeAgo.format(this);
  }

  int calculateAgeExt() {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - this.year;
    int month1 = currentDate.month;
    int month2 = this.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = this.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
}
