import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/model/work/booking_result.dart';

typedef BookingId = String;

abstract class WorkDataProvider<Config> {
  Future<BookingResult> book(Config config, TimeEntry timeEntry);
  Future<void> deleteBooking(Config config, TimeEntry timeEntry);
  Stream<TaskSearchResult> search(Config config, String query);
  Future<List<Activity>> getAvailableActivities(Config config);
}
