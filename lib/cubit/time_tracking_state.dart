library time_tracking_state;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/common/activity.dart';
import 'package:syntrack/model/common/task.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'time_tracking_state.g.dart';

abstract class TimeTrackingState implements Built<TimeTrackingState, TimeTrackingStateBuilder> {
  Task? get task;
  Activity? get activity;
  String get comment;
  DateTime? get start;

  TimeTrackingState._();

  factory TimeTrackingState([void Function(TimeTrackingStateBuilder) updates]) = _$TimeTrackingState;
  factory TimeTrackingState.idle() {
    return TimeTrackingState((b) => b..comment = '');
  }

  String toJson() {
    return json.encode(serializers.serializeWith(TimeTrackingState.serializer, this));
  }

  static TimeTrackingState? fromJson(String jsonString) {
    return serializers.deserializeWith(TimeTrackingState.serializer, json.decode(jsonString));
  }

  static Serializer<TimeTrackingState> get serializer => _$timeTrackingStateSerializer;

  bool get isTracking => start != null;
}
