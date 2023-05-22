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
    final tasks = <Task>{};

    yield* Stream.fromIterable(timeEntriesCubit.state).where(
      (timeEntry) {
        return timeEntry.comment.toLowerCase().contains(query) ||
            (timeEntry.task != null && timeEntry.task!.name.toLowerCase().contains(query));
      },
    ).where((event) {
      // filter out tasks that are already in the list
      final contains = !tasks.contains(event.task);
      if (event.task != null) {
        tasks.add(event.task!);
      }
      return event.task == null || contains;
    }).map(
      (e) => TaskSearchResult(
        (b) => b
          ..displayText = '${e.comment}${e.task != null ? ' - ' : ''}${e.task?.name}'
          ..origin = TaskSearchOrigin.latestBookings
          ..activity = e.activity?.toBuilder()
          ..comment = e.comment
          ..task = e.task?.toBuilder(),
      ),
    );
  }
}
