library erpnext_task_list;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/erpnext/erpnext_task.dart';

part 'erpnext_task_list.g.dart';

abstract class ErpNextTaskList implements Built<ErpNextTaskList, ErpNextTaskListBuilder> {
  BuiltList<ErpNextTask> get data;

  ErpNextTaskList._();

  factory ErpNextTaskList([void Function(ErpNextTaskListBuilder) updates]) = _$ErpNextTaskList;

  String toJson() {
    return json.encode(serializers.serializeWith(ErpNextTaskList.serializer, this));
  }

  static ErpNextTaskList fromJson(String jsonString) {
    return serializers.deserializeWith(ErpNextTaskList.serializer, json.decode(jsonString))!;
  }

  static Serializer<ErpNextTaskList> get serializer => _$erpNextTaskListSerializer;
}
