library redmine_time_entry;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'redmine_time_entry.g.dart';

abstract class RedmineTimeEntry implements Built<RedmineTimeEntry, RedmineTimeEntryBuilder> {
  int? get id;
  @BuiltValueField(wireName: 'issue_id')
  String? get issueId;
  @BuiltValueField(wireName: 'spent_on')
  String get spentOn;
  double get hours;
  @BuiltValueField(wireName: 'activity_id')
  int? get activityId;
  String get comments;

  RedmineTimeEntry._();

  factory RedmineTimeEntry([void Function(RedmineTimeEntryBuilder) updates]) = _$RedmineTimeEntry;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineTimeEntry.serializer, this));
  }

  static RedmineTimeEntry? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineTimeEntry.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineTimeEntry> get serializer => _$redmineTimeEntrySerializer;
}
