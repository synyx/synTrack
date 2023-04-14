library redmine_search_results;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/redmine/redmine_issue.dart';

part 'redmine_issue_results.g.dart';

abstract class RedmineIssueResults implements Built<RedmineIssueResults, RedmineIssueResultsBuilder> {
  @BuiltValueField(wireName: 'total_count')
  int? get totalCount;
  int get offset;
  int get limit;
  BuiltList<RedmineIssue> get issues;

  RedmineIssueResults._();

  factory RedmineIssueResults([void Function(RedmineIssueResultsBuilder) updates]) = _$RedmineIssueResults;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineIssueResults.serializer, this));
  }

  static RedmineIssueResults? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineIssueResults.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineIssueResults> get serializer => _$redmineIssueResultsSerializer;
}
