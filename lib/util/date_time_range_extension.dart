import 'package:flutter/material.dart';
import 'package:syntrack/util/date_time_extension.dart';

extension DateTimeExtension on DateTimeRange {
  List<DateTime> getAllDays() {
    List<DateTime> days = [];
    DateTime currentDate = start.startOfDay;

    final endEndOfDay = end.endOfDay;

    while (currentDate.isBefore(endEndOfDay)) {
      days.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return days;
  }
}
