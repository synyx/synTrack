library task;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'task.g.dart';

abstract class Task implements Built<Task, TaskBuilder> {
  static const noWorkInterfaceId = '<Work Interface ID Missing>';

  String get workInterfaceId;
  String get id;
  String get name;
  BuiltList<Activity> get availableActivities;

  Task._();

  factory Task([void Function(TaskBuilder) updates]) = _$Task;

  String toJson() {
    return json.encode(serializers.serializeWith(Task.serializer, this));
  }

  static Task? fromJson(String jsonString) {
    return serializers.deserializeWith(Task.serializer, json.decode(jsonString));
  }

  static Serializer<Task> get serializer => _$taskSerializer;
}
