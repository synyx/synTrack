import 'package:syntrack/cubit/time_entries_cubit.dart';
import 'package:syntrack/model/common/task.dart';
import 'package:syntrack/model/common/task_search_origin.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/work/booking_result.dart';
import 'package:syntrack/repository/data/work_data_provider.dart';

typedef BookingId = String;

class LatestBookingsDataProvider extends WorkDataProvider<void> {
  final TimeEntriesCubit timeEntriesCubit;

  LatestBookingsDataProvider({
    required this.timeEntriesCubit,
  });

  @override
  Future<BookingResult> book(config, TimeEntry timeEntry) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBooking(config, TimeEntry timeEntry) {
    throw UnimplementedError();
  }

  @override
  Future<List<Activity>> getAvailableActivities(config) {
    throw UnimplementedError();
  }

  @override
  Stream<TaskSearchResult> search(config, String query) async* {
    final tasks = <String>{};

    query = query.toLowerCase();

    yield* Stream.fromIterable(timeEntriesCubit.state).where(
      (timeEntry) {
        return timeEntry.comment.trim().toLowerCase().contains(query) ||
            (timeEntry.task != null && timeEntry.task!.name.trim().toLowerCase().contains(query));
      },
    ).where((timeEntry) {
      // filter out tasks that are already in the list
      final taskAlreadyFound = timeEntry.task?.id == null ? false : tasks.contains(timeEntry.task?.id);
      if (timeEntry.task != null) {
        tasks.add(timeEntry.task!.id);
      }
      return timeEntry.task == null || !taskAlreadyFound;
    }).map(
      (e) => TaskSearchResult(
        (b) => b
          ..displayText = e.comment
          ..origin = TaskSearchOrigin.latestBookings
          ..activity = e.activity?.toBuilder()
          ..comment = e.comment
          ..task = e.task?.toBuilder(),
      ),
    );
  }
}
