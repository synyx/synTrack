library activity;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'activity.g.dart';

abstract class Activity implements Built<Activity, ActivityBuilder> {
  String get name;
  String get id;

  Activity._();

  factory Activity([void Function(ActivityBuilder) updates]) = _$Activity;

  String toJson() {
    return json.encode(serializers.serializeWith(Activity.serializer, this));
  }

  static Activity? fromJson(String jsonString) {
    return serializers.deserializeWith(Activity.serializer, json.decode(jsonString));
  }

  static Serializer<Activity> get serializer => _$activitySerializer;
}
