import 'package:built_collection/built_collection.dart';
import 'package:intl/intl.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/common/task.dart';
import 'package:syntrack/model/common/task_search_origin.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/model/work/booking_result.dart';
import 'package:syntrack/model/work/redmine/redmine_activities.dart';
import 'package:syntrack/model/work/redmine/redmine_api_issue_result.dart';
import 'package:syntrack/model/work/redmine/redmine_config.dart';
import 'package:syntrack/model/work/redmine/redmine_issue.dart';
import 'package:syntrack/model/work/redmine/redmine_issue_results.dart';
import 'package:syntrack/model/work/redmine/redmine_search_result.dart';
import 'package:syntrack/model/work/redmine/redmine_search_results.dart';
import 'package:syntrack/model/work/redmine/redmine_time_entry.dart';
import 'package:syntrack/model/work/redmine/redmine_time_entry_wrapper.dart';
import 'package:syntrack/repository/data/work_data_provider.dart';
import 'package:http/http.dart' as http;
import 'package:syntrack/util/duration_extension.dart';

typedef BookingId = String;

final _formatter = DateFormat('yyyy-MM-dd');
const pageLimit = 10;
const maxPages = 10;

class RedmineDataProvider extends WorkDataProvider<RedmineConfig> {
  static const _searchPath = 'search.json?q=';
  static const _issuesPath = 'issues.json';
  // this is needed for getting a specific issue
  static const _issuesJsonPath = 'issues'; // /$id.json
  static const _issuesWatchedByMePath =
      '$_issuesPath?utf8=%E2%9C%93&set_filter=1&sort=updated_on%3Adesc&f%5B%5D=status_id&op%5Bstatus_id%5D=o&f%5B%5D=watcher_id&op%5Bwatcher_id%5D=%3D&v%5Bwatcher_id%5D%5B%5D=me&f%5B%5D=&c%5B%5D=project&c%5B%5D=tracker&c%5B%5D=status&c%5B%5D=subject&group_by=&t%5B%5D=';
  static const _activitiesPath = '/enumerations/time_entry_activities.json';

  static final _issueIdRegex = RegExp(r'#(\d+)');
  static final _ticketIdSearchStartWith = '#';

  @override
  Stream<TaskSearchResult> search(RedmineConfig config, String query) async* {
    final availableActivities = await getAvailableActivities(config);

    if (query.startsWith(_ticketIdSearchStartWith)) {
      final issueIdRegexResult = _issueIdRegex.firstMatch(query.trim());
      if (issueIdRegexResult != null) {
        yield* _searchByTicketId(issueIdRegexResult, config, availableActivities);
      }
    } else if (query.toLowerCase() == '\$me') {
      yield* _searchByAssignedToMe(config, availableActivities);
      yield* _searchByWatchedByMe(config, availableActivities);
    } else {
      yield* _searchBySearchQuery(config, query, availableActivities);
    }
  }

  Stream<TaskSearchResult> _searchByTicketId(
      RegExpMatch issueIdRegexResult, RedmineConfig config, List<Activity> availableActivities) async* {
    final id = issueIdRegexResult.group(1)!;
    final response = await _get(
      '$_issuesJsonPath/${Uri.encodeComponent(id)}.json',
      config: config,
    );

    if (_isResponse2XX(response)) {
      final result = RedmineApiIssueResult.fromJson(response.body)!;
      final task = _createTaskFromIssue(result.issue, config, availableActivities);
      if (task != null) {
        yield task;
      }
    }
  }

  Stream<TaskSearchResult> _searchByAssignedToMe(
    RedmineConfig config,
    List<Activity> availableActivities,
  ) async* {
    final response = await _get(
      '$_issuesPath?status_id=open&assigned_to_id=me',
      config: config,
    );

    if (_isResponse2XX(response)) {
      final results = RedmineIssueResults.fromJson(response.body)!;
      yield* Stream.fromIterable(results.issues)
          .map((result) {
            return _createTaskFromIssue(
              result,
              config,
              availableActivities,
              displayText: '[A] - ${result.tracker.name} #${result.id}: ${result.subject}',
            );
          })
          .where((event) => event != null)
          .map((event) => event!);
    } else {
      throw Exception('search failed: ${response.body}');
    }
  }

  Stream<TaskSearchResult> _searchByWatchedByMe(
    RedmineConfig config,
    List<Activity> availableActivities,
  ) async* {
    final response = await _get(_issuesWatchedByMePath, config: config);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final results = RedmineIssueResults.fromJson(response.body)!;
      yield* Stream.fromIterable(results.issues)
          .map((result) {
            return _createTaskFromIssue(
              result,
              config,
              availableActivities,
              displayText: '\u2B50 - ${result.tracker.name} #${result.id}: ${result.subject}',
            );
          })
          .where((event) => event != null)
          .map((event) => event!);
    } else {
      throw Exception('search failed: ${response.body}');
    }
  }

  Stream<TaskSearchResult> _searchBySearchQuery(
      RedmineConfig config, String query, List<Activity> availableActivities) async* {
    if (config.projectFilters != null && config.projectFilters!.trim().isNotEmpty) {
      final projects = config.projectFilters!.trim().split(',').map((e) => e.trim());
      for (var project in projects) {
        yield* _paginatedSearch(config, query, availableActivities, project).map((result) => result.rebuild(
              (r) => r.displayText = '${r.displayText} (Project: $project)',
            ));
      }
    } else {
      yield* _paginatedSearch(config, query, availableActivities);
    }
  }

  Stream<TaskSearchResult> _paginatedSearch(RedmineConfig config, String query, List<Activity> availableActivities,
      [String? project]) async* {
    final baseUrl = project == null
        ? '${config.baseUrl}/$_searchPath${Uri.encodeComponent(query)}'
        : '${config.baseUrl}/projects/$project/$_searchPath${Uri.encodeComponent(query)}&scope=subprojects';

    for (var page = 0; page < maxPages; page++) {
      final offset = page * pageLimit;
      final results =
          await _searchByUrl(config, query, availableActivities, '$baseUrl&offset=$offset&limit=$pageLimit');

      yield* Stream.fromIterable(results.results).where((result) => result.type == 'issue').map((result) {
        return _createTaskFromSearchResult(result, config, availableActivities);
      });

      if (offset >= (results.totalCount ?? 0)) {
        break;
      }
    }
  }

  Future<RedmineSearchResults> _searchByUrl(
    RedmineConfig config,
    String query,
    List<Activity> availableActivities,
    String url,
  ) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-Redmine-API-Key': config.apiKey,
      },
    );

    if (_isResponse2XX(response)) {
      return RedmineSearchResults.fromJson(response.body)!;
    } else {
      throw Exception('search failed ${response.body}');
    }
  }

  Future<http.Response> _get(
    String path, {
    required RedmineConfig config,
  }) {
    return http.get(
      Uri.parse('${config.baseUrl}/$path'),
      headers: {'X-Redmine-API-Key': config.apiKey, 'Accept': 'application/json'},
    );
  }

  bool _isResponse2XX(http.Response response) => response.statusCode >= 200 && response.statusCode < 300;

  TaskSearchResult _createTaskFromSearchResult(
    RedmineSearchResult result,
    RedmineConfig config,
    List<Activity> availableActivities,
  ) {
    final tsrBuilder = TaskSearchResult(
      (b) => b
        ..displayText = result.title
        ..origin = TaskSearchOrigin.redmine
        ..task = Task(
          (b) => b
            ..id = '${result.id}'
            ..name = result.title
            ..workInterfaceId = config.id
            ..availableActivities = ListBuilder(availableActivities),
        ).toBuilder(),
    );

    return tsrBuilder;
  }

  TaskSearchResult _createTaskFromIssue(
    RedmineIssue issue,
    RedmineConfig config,
    List<Activity> availableActivities, {
    String? displayText,
  }) {
    final tsrBuilder = TaskSearchResult(
      (b) => b
        ..displayText = displayText ?? '${issue.tracker.name} #${issue.id}: ${issue.subject}'
        ..origin = TaskSearchOrigin.redmine
        ..task = Task(
          (b) => b
            ..id = '${issue.id}'
            ..name = '${issue.tracker.name} #${issue.id}: ${issue.subject}'
            ..workInterfaceId = config.id
            ..availableActivities = ListBuilder(availableActivities),
        ).toBuilder(),
    );

    return tsrBuilder;
  }

  @override
  Future<List<Activity>> getAvailableActivities(RedmineConfig config) async {
    final response = await http.get(
      Uri.parse('${config.baseUrl}/$_activitiesPath'),
      headers: {
        'X-Redmine-API-Key': config.apiKey,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final activities = RedmineActivities.fromJson(response.body)!;
      return activities.activities
          .map((redmineActivity) => Activity(
                (b) => b
                  ..id = '${redmineActivity.id}'
                  ..name = redmineActivity.name,
              ))
          .toList();
    } else {
      throw Exception('get available activities failed: ${response.body}');
    }
  }

  @override
  Future<BookingResult> book(RedmineConfig config, TimeEntry timeEntry) async {
    final duration = timeEntry.end.difference(timeEntry.start);
    final effectiveDuration = _getEffectiveDuration(
      duration,
      roundUp: config.roundUp,
    );

    final minutes = _toMinutes(effectiveDuration);

    final redmineTimeEntry = RedmineTimeEntry(
      (b) => b
        ..issueId = timeEntry.task!.id
        ..spentOn = _formatter.format(timeEntry.start)
        ..hours = minutes / 60
        ..activityId = int.parse(timeEntry.activity!.id)
        ..comments = timeEntry.comment,
    );

    final response = await http
        .post(
          Uri.parse('${config.baseUrl}/time_entries.json?issue_id=${timeEntry.task!.id}'),
          headers: {
            'Content-Type': 'application/json',
            'X-Redmine-API-Key': config.apiKey,
          },
          body: RedmineTimeEntryWrapper((b) => b..timeEntry = redmineTimeEntry.toBuilder()).toJson(),
        )
        .timeout(Duration(seconds: 5));

    if (response.statusCode < 200 || response.statusCode > 299) {
      final message = [
        '[${response.statusCode} ${response.reasonPhrase != null ? response.reasonPhrase : ''}]',
        if (response.body.trim().isNotEmpty) response.body,
      ].join(" ");
      throw Exception('booking failed: $message');
    }

    final createdTimeEntry = RedmineTimeEntryWrapper.fromJson(response.body)!;
    return BookingResult(bookingId: '${createdTimeEntry.timeEntry.id!}', duration: effectiveDuration);
  }

  @override
  Future<void> deleteBooking(RedmineConfig config, TimeEntry timeEntry) async {
    final response = await http.delete(
      Uri.parse('${config.baseUrl}/time_entries/${timeEntry.bookingId}.json'),
      headers: {
        'Content-Type': 'application/json',
        'X-Redmine-API-Key': config.apiKey,
      },
    );

    if (response.statusCode < 200 || response.statusCode > 299) {
      throw Exception('delete booking failed: ${response.body}');
    }
  }

  Duration _getEffectiveDuration(Duration duration, {required bool roundUp}) {
    if (roundUp) {
      final durationRoundUp = duration.roundUp(delta: Duration(minutes: 15));
      return durationRoundUp;
    }

    return duration;
  }

  double _toMinutes(Duration duration) {
    return duration.inMinutes.toDouble();
  }
}
