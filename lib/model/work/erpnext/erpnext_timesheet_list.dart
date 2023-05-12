library erpnext_timesheet_list;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/erpnext/erpnext_timesheet.dart';

part 'erpnext_timesheet_list.g.dart';

abstract class ErpNextTimesheetList implements Built<ErpNextTimesheetList, ErpNextTimesheetListBuilder> {
  BuiltList<ErpNextTimesheet> get data;

  ErpNextTimesheetList._();

  factory ErpNextTimesheetList([void Function(ErpNextTimesheetListBuilder) updates]) = _$ErpNextTimesheetList;

  String toJson() {
    return json.encode(serializers.serializeWith(ErpNextTimesheetList.serializer, this));
  }

  static ErpNextTimesheetList fromJson(String jsonString) {
    return serializers.deserializeWith(ErpNextTimesheetList.serializer, json.decode(jsonString))!;
  }

  static Serializer<ErpNextTimesheetList> get serializer => _$erpNextTimesheetListSerializer;
}
