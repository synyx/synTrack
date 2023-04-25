library erpnext_task;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'erpnext_task.g.dart';

abstract class ErpNextTask implements Built<ErpNextTask, ErpNextTaskBuilder> {
  String get name;
  String? get subject;
  String? get project;

  ErpNextTask._();

  factory ErpNextTask([void Function(ErpNextTaskBuilder) updates]) = _$ErpNextTask;

  String toJson() {
    return json.encode(serializers.serializeWith(ErpNextTask.serializer, this));
  }

  static ErpNextTask fromJson(String jsonString) {
    return serializers.deserializeWith(ErpNextTask.serializer, json.decode(jsonString))!;
  }

  static Serializer<ErpNextTask> get serializer => _$erpNextTaskSerializer;
}
