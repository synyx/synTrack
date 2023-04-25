library task_origin;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'task_search_origin.g.dart';

class TaskSearchOrigin extends EnumClass {

  static const TaskSearchOrigin redmine = _$redmine;
  static const TaskSearchOrigin latestBookings = _$latestBookings;
  static const TaskSearchOrigin erpNext = _$erpNext;

  const TaskSearchOrigin._(String name) : super(name);

  static BuiltSet<TaskSearchOrigin> get values => _$values;
  static TaskSearchOrigin valueOf(String name) => _$valueOf(name);
  static Serializer<TaskSearchOrigin> get serializer => _$taskSearchOriginSerializer;
}