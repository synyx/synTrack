library redmine_search_result;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'redmine_search_result.g.dart';

abstract class RedmineSearchResult implements Built<RedmineSearchResult, RedmineSearchResultBuilder> {
  int get id;
  String get title;
  String get type;
  String get url;
  String get description;
  DateTime get datetime;

  RedmineSearchResult._();

  factory RedmineSearchResult([void Function(RedmineSearchResultBuilder) updates]) = _$RedmineSearchResult;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineSearchResult.serializer, this));
  }

  static RedmineSearchResult? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineSearchResult.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineSearchResult> get serializer => _$redmineSearchResultSerializer;
}
