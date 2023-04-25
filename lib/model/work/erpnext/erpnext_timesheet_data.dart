library erpnext_timesheet_data;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet.dart';

part 'erpnext_timesheet_data.g.dart';

abstract class ErpNextTimesheetData implements Built<ErpNextTimesheetData, ErpNextTimesheetDataBuilder> {
  ErpNextTimesheet get data;

  ErpNextTimesheetData._();

  factory ErpNextTimesheetData([void Function(ErpNextTimesheetDataBuilder) updates]) = _$ErpNextTimesheetData;

  String toJson() {
    return json.encode(serializers.serializeWith(ErpNextTimesheetData.serializer, this));
  }

  static ErpNextTimesheetData fromJson(String jsonString) {
    return serializers.deserializeWith(ErpNextTimesheetData.serializer, json.decode(jsonString))!;
  }

  static Serializer<ErpNextTimesheetData> get serializer => _$erpNextTimesheetDataSerializer;
}
