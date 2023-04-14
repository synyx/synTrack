import 'dart:async';

import 'package:async/async.dart';
import 'package:syntrack/exception/work_interface_not_found.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/common/task.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/model/work/booking_result.dart';
import 'package:syntrack/model/work/redmine/redmine_config.dart';
import 'package:syntrack/model/work/work_interface_configs.dart';
import 'package:syntrack/repository/data/latest_bookings_data_provider.dart';
import 'package:syntrack/repository/data/remine_data_provider.dart';

class WorkRepository {
  final redmineDataProvider = RedmineDataProvider();
  late final LatestBookingsDataProvider latestBookingsDataProvider;

  late WorkInterfaceConfigs _currentConfigs;
  StreamSubscription<WorkInterfaceConfigs>? _subscription;

  Future<void> init(
    WorkInterfaceConfigs initialConfigs,
    Stream<WorkInterfaceConfigs> configsStream,
    LatestBookingsDataProvider latestBookingsDataProvider,
  ) async {
    await _subscription?.cancel();
    _currentConfigs = initialConfigs;

    _subscription = configsStream.listen((event) {
      _currentConfigs = event;
    });

    this.latestBookingsDataProvider = latestBookingsDataProvider;
  }

  Stream<TaskSearchResult> search(String query) async* {
    if (query.trim().isEmpty) {
      return;
    }

    final latestBookingsStream = latestBookingsDataProvider.search(null, query);

    final redmineStreams = _currentConfigs.redmineConfigs.map((config) => redmineDataProvider.search(config, query));

    final mergedStream = StreamGroup.merge([
      ...redmineStreams,
      latestBookingsStream,
    ]);

    yield* mergedStream;
  }

  Future<BookingResult> book(TimeEntry timeEntry) async {
    final workInterfaceId = timeEntry.task!.workInterfaceId;
    final redmineConfig = _getRedmineConfig(workInterfaceId);

    return redmineDataProvider.book(redmineConfig, timeEntry);
  }

  Future<void> deleteBooking(TimeEntry timeEntry) {
    final workInterfaceId = timeEntry.task!.workInterfaceId;
    final redmineConfig = _getRedmineConfig(workInterfaceId);

    return redmineDataProvider.deleteBooking(redmineConfig, timeEntry);
  }

  Future<List<Activity>> getAvailableActivies(Task task) {
    final workInterfaceId = task.workInterfaceId;
    final redmineConfig = _getRedmineConfig(workInterfaceId);

    return redmineDataProvider.getAvailableActivities(redmineConfig);
  }

  RedmineConfig _getRedmineConfig(String workInterfaceId) {
    try {
      return _currentConfigs.redmineConfigs.firstWhere((config) => config.id == workInterfaceId);
    } catch (e) {
      throw WorkInterfaceNotFound();
    }
  }

  Future<void> close() async {
    await _subscription?.cancel();
  }
}
