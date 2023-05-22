library erpnext_timesheet_log;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'erpnext_timesheet_log.g.dart';

abstract class ErpNextTimesheetLog implements Built<ErpNextTimesheetLog, ErpNextTimesheetLogBuilder> {
  String? get name;
  String? get description;
  double? get hours;
  @BuiltValueField(wireName: 'activity_type')
  String? get activityType;
  String? get task;
  @BuiltValueField(wireName: 'from_time')
  String? get fromTime;
  @BuiltValueField(wireName: 'to_time')
  String? get toTime;

  ErpNextTimesheetLog._();

  factory ErpNextTimesheetLog([void Function(ErpNextTimesheetLogBuilder) updates]) = _$ErpNextTimesheetLog;

  String toJson() {
    return json.encode(serializers.serializeWith(ErpNextTimesheetLog.serializer, this));
  }

  static ErpNextTimesheetLog fromJson(String jsonString) {
    return serializers.deserializeWith(ErpNextTimesheetLog.serializer, json.decode(jsonString))!;
  }

  static Serializer<ErpNextTimesheetLog> get serializer => _$erpNextTimesheetLogSerializer;
}
