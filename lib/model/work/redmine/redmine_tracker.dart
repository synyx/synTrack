library redmine_search_result;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'redmine_tracker.g.dart';

abstract class RedmineTracker implements Built<RedmineTracker, RedmineTrackerBuilder> {
  int get id;
  String get name;

  RedmineTracker._();

  factory RedmineTracker([void Function(RedmineTrackerBuilder) updates]) = _$RedmineTracker;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineTracker.serializer, this));
  }

  static RedmineTracker? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineTracker.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineTracker> get serializer => _$redmineTrackerSerializer;
}
