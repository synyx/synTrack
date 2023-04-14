library redmine_search_results;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/redmine/redmine_search_result.dart';

part 'redmine_search_results.g.dart';

abstract class RedmineSearchResults implements Built<RedmineSearchResults, RedmineSearchResultsBuilder> {
  @BuiltValueField(wireName: 'total_count')
  int? get totalCount;
  int get offset;
  int get limit;
  BuiltList<RedmineSearchResult> get results;

  RedmineSearchResults._();

  factory RedmineSearchResults([void Function(RedmineSearchResultsBuilder) updates]) = _$RedmineSearchResults;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineSearchResults.serializer, this));
  }

  static RedmineSearchResults? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineSearchResults.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineSearchResults> get serializer => _$redmineSearchResultsSerializer;
}
