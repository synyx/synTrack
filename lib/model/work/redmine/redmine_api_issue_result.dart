library redmine_search_result;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/redmine/redmine_issue.dart';

part 'redmine_api_issue_result.g.dart';

abstract class RedmineApiIssueResult implements Built<RedmineApiIssueResult, RedmineApiIssueResultBuilder> {
  RedmineIssue get issue;

  RedmineApiIssueResult._();

  factory RedmineApiIssueResult([void Function(RedmineApiIssueResultBuilder) updates]) = _$RedmineApiIssueResult;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineApiIssueResult.serializer, this));
  }

  static RedmineApiIssueResult? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineApiIssueResult.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineApiIssueResult> get serializer => _$redmineApiIssueResultSerializer;
}
