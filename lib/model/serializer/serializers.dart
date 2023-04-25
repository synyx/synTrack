import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:syntrack/cubit/time_tracking_state.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/common/task.dart';
import 'package:syntrack/model/common/task_search_origin.dart';
import 'package:syntrack/model/common/task_search_result.dart';
import 'package:syntrack/model/common/time_entry.dart';
import 'package:syntrack/model/work/erpnext/erpnext_activity_type_list.dart';
import 'package:syntrack/model/work/erpnext/erpnext_activity_type.dart';
import 'package:syntrack/model/work/erpnext/erpnext_config.dart';
import 'package:syntrack/model/work/erpnext/erpnext_task.dart';
import 'package:syntrack/model/work/erpnext/erpnext_task_list.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet_data.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet_list.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet_log.dart';
import 'package:syntrack/model/work/redmine/redmine_activities.dart';
import 'package:syntrack/model/work/redmine/redmine_activity.dart';
import 'package:syntrack/model/work/redmine/redmine_api_issue_result.dart';
import 'package:syntrack/model/work/redmine/redmine_config.dart';
import 'package:syntrack/model/work/redmine/redmine_issue.dart';
import 'package:syntrack/model/work/redmine/redmine_issue_results.dart';
import 'package:syntrack/model/work/redmine/redmine_search_result.dart';
import 'package:syntrack/model/work/redmine/redmine_search_results.dart';
import 'package:syntrack/model/work/redmine/redmine_time_entry.dart';
import 'package:syntrack/model/work/redmine/redmine_time_entry_wrapper.dart';
import 'package:syntrack/model/work/redmine/redmine_tracker.dart';
import 'package:syntrack/model/work/work_interface_configs.dart';

part 'serializers.g.dart';

//add all of the built value types that require serialization
@SerializersFor([
  Activity,
  TaskSearchResult,
  Task,
  TimeEntry,
  RedmineConfig,
  WorkInterfaceConfigs,
  RedmineSearchResult,
  RedmineSearchResults,
  RedmineTimeEntry,
  RedmineTimeEntryWrapper,
  RedmineActivity,
  RedmineActivities,
  RedmineIssue,
  RedmineTracker,
  RedmineApiIssueResult,
  TimeTrackingState,
  TaskSearchOrigin,
  RedmineIssueResults,
  RedmineIssue,
  ErpNextConfig,
  ErpNextActivityTypeList,
  ErpNextActivityType,
  ErpNextTaskList,
  ErpNextTask,
  ErpNextTimesheet,
  ErpNextTimesheetLog,
  ErpNextTimesheetList,
  ErpNextTimesheetData,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(Iso8601DateTimeSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
