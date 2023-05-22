library task_search_result;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/common/task.dart';
import 'package:syntrack/model/common/task_search_origin.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'task_search_result.g.dart';

abstract class TaskSearchResult implements Built<TaskSearchResult, TaskSearchResultBuilder> {
  Task? get task;
  TaskSearchOrigin get origin;
  Activity? get activity;
  String? get comment;
  String get displayText;

  TaskSearchResult._();

  factory TaskSearchResult([void Function(TaskSearchResultBuilder) updates]) = _$TaskSearchResult;

  String toJson() {
    return json.encode(serializers.serializeWith(TaskSearchResult.serializer, this));
  }

  static TaskSearchResult? fromJson(String jsonString) {
    return serializers.deserializeWith(TaskSearchResult.serializer, json.decode(jsonString));
  }

  static Serializer<TaskSearchResult> get serializer => _$taskSearchResultSerializer;
}
