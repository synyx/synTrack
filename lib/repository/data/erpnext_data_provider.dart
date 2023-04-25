import 'dart:convert';
import 'dart:math' as math;

import 'package:built_collection/built_collection.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syntrack/exception/delete_booking_impossible.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/common/task.dart';
import 'package:syntrack/model/common/task_search_origin.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/model/work/booking_result.dart';
import 'package:syntrack/model/work/erpnext/erpnext_activity_type_list.dart';
import 'package:syntrack/model/work/erpnext/erpnext_config.dart';
import 'package:syntrack/model/work/erpnext/erpnext_task_list.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet_data.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet_list.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet_log.dart';
import 'package:syntrack/repository/data/work_data_provider.dart';

final _erpNextDateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

const _apiResourcePath = 'api/resource';
const _apiMethodPath = 'api/method';

const _activityTypeResourcePath = '${_apiResourcePath}/Activity%20Type?filters=[["disabled", "=", 0]]';
const _timesheetResourcePath = '${_apiResourcePath}/Timesheet';
final _loggedInUserMethodPath = '${_apiMethodPath}/frappe.auth.get_logged_user';

const _timesheetPrefix = 'syntrack_';
const _mandatoryFirstTimeLogDescription = 'syntrack_temp_mandatory_time_log';
final _timesheetRegex = RegExp(r'^syntrack_(.*)_(\d+)$');
final _timesheetLogRegex = RegExp(r'^(.*)_(\w+)$');

/// how many items should be retrieved by a taskSearch
const _limitPageLength = 10;
const _maxPages = 3;

class ErpNextDataProvider extends WorkDataProvider<ErpNextConfig> {
  String _taskSearchPath(
    String query,
    int pageNumber,
  ) =>
      '${_apiResourcePath}/Task' +
      '?or_filters=[["description", "like", "%$query%"],["subject", "like", "%$query%"],["name", "like", "%$query%"]]' +
      '&fields=["name","subject","project"]' +
      '&limit_page_length=$_limitPageLength&limit_start=${pageNumber * _limitPageLength}';

  String _timesheetSearchPath(
    String owner,
    String taskId,
  ) =>
      '${_apiResourcePath}/Timesheet' +
      '?fields=["title", "name","docstatus","status"]' +
      '&filters=[["owner","=","$owner"],["title","like","$_timesheetPrefix${taskId}_%"]]' +
      '&order_by=name%20asc';

  String _timesheetGetPath(
    String timesheetName,
  ) =>
      '${_apiResourcePath}/Timesheet/${timesheetName}';

  @override
  Future<BookingResult> book(ErpNextConfig config, TimeEntry timeEntry) async {
    final owner = await _getLoggedInUser(config);
    final timesheets = await _getTimesheets(config, owner, timeEntry.task!.id);
    final highestSuffix = _getHighestTimesheetSuffixNumber(timesheets);

    final timesheet = await _getOrCreateTimesheet(
      config,
      timeEntry.task!,
      timesheets,
      highestSuffix,
    );

    final timeLogName = await _createTimeLog(config, timesheet, timeEntry);

    return BookingResult(
      bookingId: '${timesheet.name}_${timeLogName}',
      duration: timeEntry.duration,
    );
  }

  Future<String> _createTimeLog(ErpNextConfig config, ErpNextTimesheet timesheet, TimeEntry timeEntry) async {
    final path = '${_timesheetResourcePath}/${timesheet.name}';
    final tempUuidForMapping = uuid.v4();
    final tempTimeLog = ErpNextTimesheetLog(
      (log) => log..description = tempUuidForMapping,
    );
    final tempTimesheet = timesheet.rebuild((t) => t..timeLogs.add(tempTimeLog));

    final timesheetWithTempTimeLog = await _putOrFailAndDeserialize(
      path,
      config: config,
      body: tempTimesheet.toJson(),
      fromJson: ErpNextTimesheetData.fromJson,
    ).then((value) => value.data);

    final createdTempTimeLog =
        timesheetWithTempTimeLog.timeLogs.firstWhere((log) => log.description == tempUuidForMapping);

    final newTimeLog = ErpNextTimesheetLog(
      (log) => log
        ..name = createdTempTimeLog.name
        ..activityType = timeEntry.activity?.id
        ..description = timeEntry.comment
        ..hours = timeEntry.duration.inMinutes / 60
        ..task = timeEntry.task?.id
        ..fromTime = _erpNextDateTimeFormatter.format(timeEntry.start)
        ..toTime = _erpNextDateTimeFormatter.format(timeEntry.end),
    );

    final newTimesheet = timesheetWithTempTimeLog.rebuild(
      (t) => t.timeLogs
        ..removeWhere((log) => log.name == tempUuidForMapping)
        ..removeWhere((log) => log.description == _mandatoryFirstTimeLogDescription)
        ..add(newTimeLog),
    );

    await _putOrFail(
      path,
      config: config,
      body: newTimesheet.toJson(),
    );

    return createdTempTimeLog.name!;
  }

  int _getHighestTimesheetSuffixNumber(Iterable<ErpNextTimesheet> timesheets) {
    return [
      0,
      ...timesheets.map((timesheet) => _getSuffixFromTimesheet(timesheet)),
    ].reduce(math.max);
  }

  int _getSuffixFromTimesheet(ErpNextTimesheet timesheet) {
    final match = _timesheetRegex.firstMatch(timesheet.title);
    return int.parse(match![2]!);
  }

  Future<Iterable<ErpNextTimesheet>> _getTimesheets(ErpNextConfig config, String owner, String taskId) =>
      _getOrFailAndDeserialize(
        _timesheetSearchPath(owner, taskId),
        config: config,
        fromJson: ErpNextTimesheetList.fromJson,
      ).then((value) => value.data);

  Future<ErpNextTimesheet> _getTimesheet(ErpNextConfig config, String timesheetName) => _getOrFailAndDeserialize(
        _timesheetGetPath(timesheetName),
        config: config,
        fromJson: ErpNextTimesheetData.fromJson,
      ).then((value) => value.data);

  Future<ErpNextTimesheet> _getOrCreateTimesheet(
      ErpNextConfig config, Task task, Iterable<ErpNextTimesheet> timesheets, int highestExistingSuffix) async {
    try {
      final timesheet = timesheets.firstWhere((timesheet) => timesheet.docstatus == 0);
      return _getTimesheet(config, timesheet.name);
    } on StateError {
      // ignore
    }

    return _createTimesheet(config, task, highestExistingSuffix + 1);
  }

  Future<ErpNextTimesheet> _createTimesheet(ErpNextConfig config, Task task, int suffix) {
    final timesheetTitle = _getTimesheetTitle(task, suffix);

    return _postOrFailAndDeserialize(
      _timesheetResourcePath,
      config: config,
      body:
          '{ "title": "${timesheetTitle}", "time_logs": [{ "description": "${_mandatoryFirstTimeLogDescription}" }] }',
      fromJson: ErpNextTimesheetData.fromJson,
    ).then((value) => value.data);
  }

  String _getTimesheetTitle(Task task, int suffix) => '${_timesheetPrefix}${task.id}_${suffix}';

  @override
  Future<void> deleteBooking(ErpNextConfig config, TimeEntry timeEntry) async {
    // get the number prefix using regex and the synTrack_[Task Id]. Search for the
    // time entry and remove the time entry list

    final parsedBookingId = _parseTimesheetLogBookingId(timeEntry.bookingId!);
    final timesheet = await _getTimesheet(config, parsedBookingId.timesheetName);
    final path = '${_timesheetResourcePath}/${timesheet.name}';

    if (timesheet.docstatus == 1) {
      // submitted
      throw DeleteBookingFailedException('Timesheet ${timesheet.title} (${timesheet.name}) is already submitted');
    }

    final newTimesheet = timesheet.rebuild(
      (t) => t.timeLogs.removeWhere((log) => log.name == parsedBookingId.timesheetLogName),
    );

    if (newTimesheet.timeLogs.length == timesheet.timeLogs.length) {
      // length didn't change -> log not found
      throw DeleteBookingFailedException('Could not find Timesheet Log ${parsedBookingId.timesheetLogName}');
    }

    if (newTimesheet.timeLogs.length <= 0) {
      final response = await _deleteOrFail(path, config: config);
      final responseJson = jsonDecode(response.body);
      if (responseJson['message'] == null || responseJson['message'] != 'ok') {
        throw DeleteBookingFailedException('Could not delete empty timesheet ${timesheet.name}: response.body');
      }
    } else {
      await _putOrFail(
        path,
        config: config,
        body: newTimesheet.toJson(),
      );
    }
  }

  ParsedTimesheetLogBookingId _parseTimesheetLogBookingId(String bookingId) {
    final match = _timesheetLogRegex.firstMatch(bookingId);

    return ParsedTimesheetLogBookingId(match![1]!, match[2]!);
  }

  @override
  Future<List<Activity>> getAvailableActivities(ErpNextConfig config) async {
    return (await _getOrFailAndDeserialize(
      _activityTypeResourcePath,
      config: config,
      fromJson: ErpNextActivityTypeList.fromJson,
    ))
        .data
        .map((erpNextActivityType) => Activity(
              (activity) => activity
                ..id = erpNextActivityType.name
                ..name = erpNextActivityType.name,
            ))
        .toList();
  }

  @override
  Stream<TaskSearchResult> search(ErpNextConfig config, String query) async* {
    query = Uri.encodeComponent(query.toLowerCase().trim());

    final availableActivities = await getAvailableActivities(config);

    for (var page = 0; page < _maxPages; page++) {
      final taskSearchResultIterable = (await _getOrFailAndDeserialize(
        _taskSearchPath(query, page),
        config: config,
        fromJson: ErpNextTaskList.fromJson,
      ))
          .data
          .map((erpNextTask) => TaskSearchResult(
                (taskSearchResult) {
                  final projectPrefix = (erpNextTask.project?.isNotEmpty ?? false) ? '[${erpNextTask.project}] - ' : '';

                  taskSearchResult
                    ..origin = TaskSearchOrigin.erpNext
                    ..displayText = '$projectPrefix${erpNextTask.subject ?? erpNextTask.name}'
                    ..comment = erpNextTask.subject ?? erpNextTask.name
                    ..task = Task(
                      (task) => task
                        ..id = erpNextTask.name
                        ..name = erpNextTask.subject ?? erpNextTask.name
                        ..workInterfaceId = config.id
                        ..availableActivities = ListBuilder(availableActivities),
                    ).toBuilder();
                },
              ));

      if (taskSearchResultIterable.isEmpty) {
        break;
      }

      yield* Stream.fromIterable(taskSearchResultIterable);
    }
  }

  Future<String> _getLoggedInUser(ErpNextConfig config) async {
    final response = await _getOrFail(_loggedInUserMethodPath, config: config);
    final json = jsonDecode(response.body);

    if (json['message'] != null) {
      return json['message'];
    }

    throw Exception('could not find logged in user');
  }

  Future<T> _getOrFailAndDeserialize<T>(
    String path, {
    required ErpNextConfig config,
    required T Function(String json) fromJson,
  }) async {
    final response = await _getOrFail(path, config: config);
    return fromJson(response.body);
  }

  Future<http.Response> _getOrFail(
    String path, {
    required ErpNextConfig config,
  }) async {
    final response = await http.get(
      Uri.parse('${config.baseUrl}/$path'),
      headers: {'Authorization': 'token ${config.apiKey}:${config.apiSecret}', 'Accept': 'application/json'},
    );

    if (!_isResponse2XX(response)) {
      final message = [
        'GET - ',
        '[${response.statusCode} ${response.reasonPhrase != null ? response.reasonPhrase : ''}]',
        if (response.body.trim().isNotEmpty) response.body,
      ].join(" ");
      throw Exception('request failed: $message');
    }

    return response;
  }

  Future<T> _postOrFailAndDeserialize<T>(
    String path, {
    required ErpNextConfig config,
    required T Function(String json) fromJson,
    Object? body,
  }) async {
    final response = await _postOrFail(path, config: config, body: body);
    return fromJson(response.body);
  }

  Future<http.Response> _postOrFail(
    String path, {
    required ErpNextConfig config,
    Object? body,
  }) async {
    final response = await http.post(
      Uri.parse('${config.baseUrl}/$path'),
      headers: {'Authorization': 'token ${config.apiKey}:${config.apiSecret}', 'Accept': 'application/json'},
      body: body,
    );

    if (!_isResponse2XX(response)) {
      final message = [
        'POST - ',
        '[${response.statusCode} ${response.reasonPhrase != null ? response.reasonPhrase : ''}]',
        if (response.body.trim().isNotEmpty) response.body,
      ].join(" ");
      throw Exception('request failed: $message');
    }

    return response;
  }

  Future<T> _putOrFailAndDeserialize<T>(
    String path, {
    required ErpNextConfig config,
    required T Function(String json) fromJson,
    Object? body,
  }) async {
    final response = await _putOrFail(path, config: config, body: body);
    return fromJson(response.body);
  }

  Future<http.Response> _putOrFail(
    String path, {
    required ErpNextConfig config,
    Object? body,
  }) async {
    final response = await http.put(
      Uri.parse('${config.baseUrl}/$path'),
      headers: {'Authorization': 'token ${config.apiKey}:${config.apiSecret}', 'Accept': 'application/json'},
      body: body,
    );

    if (!_isResponse2XX(response)) {
      final message = [
        'PUT - ',
        '[${response.statusCode} ${response.reasonPhrase != null ? response.reasonPhrase : ''}]',
        if (response.body.trim().isNotEmpty) response.body,
      ].join(" ");
      throw Exception('request failed: $message');
    }

    return response;
  }

  Future<http.Response> _deleteOrFail(
    String path, {
    required ErpNextConfig config,
    Object? body,
  }) async {
    final response = await http.delete(
      Uri.parse('${config.baseUrl}/$path'),
      headers: {'Authorization': 'token ${config.apiKey}:${config.apiSecret}', 'Accept': 'application/json'},
      body: body,
    );

    if (!_isResponse2XX(response)) {
      final message = [
        'DELETE - ',
        '[${response.statusCode} ${response.reasonPhrase != null ? response.reasonPhrase : ''}]',
        if (response.body.trim().isNotEmpty) response.body,
      ].join(" ");
      throw Exception('request failed: $message');
    }

    return response;
  }

  bool _isResponse2XX(http.Response response) => response.statusCode >= 200 && response.statusCode < 300;
}

class ParsedTimesheetLogBookingId {
  final String timesheetName;
  final String timesheetLogName;

  ParsedTimesheetLogBookingId(this.timesheetName, this.timesheetLogName);
}
