library redmine_issue;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/redmine/redmine_tracker.dart';

part 'redmine_issue.g.dart';

abstract class RedmineIssue implements Built<RedmineIssue, RedmineIssueBuilder> {
  int get id;
  String get subject;
  String get description;
  @BuiltValueField(wireName: 'created_on')
  DateTime get createdOn;
  RedmineTracker get tracker;

  RedmineIssue._();

  factory RedmineIssue([void Function(RedmineIssueBuilder) updates]) = _$RedmineIssue;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineIssue.serializer, this));
  }

  static RedmineIssue? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineIssue.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineIssue> get serializer => _$redmineIssueSerializer;
}
