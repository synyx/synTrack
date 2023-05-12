library erpnext_timesheet;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet_log.dart';

part 'erpnext_timesheet.g.dart';

abstract class ErpNextTimesheet implements Built<ErpNextTimesheet, ErpNextTimesheetBuilder> {
  String get name;
  String get title;
  int get docstatus;
  String get status;
  @BuiltValueField(wireName: 'time_logs')
  BuiltList<ErpNextTimesheetLog> get timeLogs;

  ErpNextTimesheet._();

  factory ErpNextTimesheet([void Function(ErpNextTimesheetBuilder) updates]) = _$ErpNextTimesheet;

  String toJson() {
    return json.encode(serializers.serializeWith(ErpNextTimesheet.serializer, this));
  }

  static ErpNextTimesheet fromJson(String jsonString) {
    return serializers.deserializeWith(ErpNextTimesheet.serializer, json.decode(jsonString))!;
  }

  static Serializer<ErpNextTimesheet> get serializer => _$erpNextTimesheetSerializer;
}
