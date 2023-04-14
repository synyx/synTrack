import 'package:flutter/material.dart';
import 'package:syntrack/util/date_time_extension.dart';

extension DateTimeExtension on DateTimeRange {
  List<DateTime> getAllDays() {
    List<DateTime> days = [];
    DateTime currentDate = this.start.startOfDay;

    final endEndOfDay = this.end.endOfDay;

    while (currentDate.isBefore(endEndOfDay)) {
      days.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }

    return days;
  }
}
