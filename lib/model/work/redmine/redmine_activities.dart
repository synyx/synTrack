library redmine_activities;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/redmine/redmine_activity.dart';

part 'redmine_activities.g.dart';

abstract class RedmineActivities implements Built<RedmineActivities, RedmineActivitiesBuilder> {
  @BuiltValueField(wireName: 'time_entry_activities')
  BuiltList<RedmineActivity> get activities;

  RedmineActivities._();

  factory RedmineActivities([void Function(RedmineActivitiesBuilder) updates]) = _$RedmineActivities;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineActivities.serializer, this));
  }

  static RedmineActivities? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineActivities.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineActivities> get serializer => _$redmineActivitiesSerializer;
}
