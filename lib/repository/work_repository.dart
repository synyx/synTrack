import 'dart:async';

import 'package:async/async.dart';
import 'package:syntrack/exception/work_interface_not_found.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/common/task.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/model/work/booking_result.dart';
import 'package:syntrack/model/work/erpnext/erpnext_config.dart';
import 'package:syntrack/model/work/redmine/redmine_config.dart';
import 'package:syntrack/model/work/work_interface_configs.dart';
import 'package:syntrack/repository/data/erpnext_data_provider.dart';
import 'package:syntrack/repository/data/latest_bookings_data_provider.dart';
import 'package:syntrack/repository/data/remine_data_provider.dart';
import 'package:syntrack/repository/data/work_data_provider.dart';

class WorkRepository {
  final redmineDataProvider = RedmineDataProvider();
  final erpNextDataProvider = ErpNextDataProvider();
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

    final erpNextStreams = _currentConfigs.erpNextConfigs.map((config) => erpNextDataProvider.search(config, query));

    final mergedStream = StreamGroup.merge([
      ...redmineStreams,
      ...erpNextStreams,
      latestBookingsStream,
    ]);

    yield* mergedStream;
  }

  Future<BookingResult> book(TimeEntry timeEntry) {
    final workInterfaceId = timeEntry.task!.workInterfaceId;
    final config = _getWorkInterfaceConfig(workInterfaceId);
    final workDataProvider = _getWorkDataProvider(config);

    return workDataProvider.book(config, timeEntry);
  }

  WorkDataProvider _getWorkDataProvider(dynamic workInterfaceConfig) {
    if (workInterfaceConfig is RedmineConfig) {
      return redmineDataProvider;
    } else if (workInterfaceConfig is ErpNextConfig) {
      return erpNextDataProvider;
    }

    throw WorkInterfaceNotFound();
  }

  Future<void> deleteBooking(TimeEntry timeEntry) {
    final workInterfaceId = timeEntry.task!.workInterfaceId;
    final config = _getWorkInterfaceConfig(workInterfaceId);
    final workDataProvider = _getWorkDataProvider(config);

    return workDataProvider.deleteBooking(config, timeEntry);
  }

  Future<List<Activity>> getAvailableActivies(Task task) {
    final workInterfaceId = task.workInterfaceId;
    final config = _getWorkInterfaceConfig(workInterfaceId);
    final workDataProvider = _getWorkDataProvider(config);

    return workDataProvider.getAvailableActivities(config);
  }

  dynamic _getWorkInterfaceConfig(String workInterfaceId) {
    try {
      return _currentConfigs.combinedConfigs.firstWhere((config) => config.id == workInterfaceId);
    } catch (e) {
      throw WorkInterfaceNotFound();
    }
  }

  Future<void> close() async {
    await _subscription?.cancel();
  }
}
