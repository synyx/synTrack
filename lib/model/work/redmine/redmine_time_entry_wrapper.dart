library redmine_time_entry_wrapper;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/redmine/redmine_time_entry.dart';

part 'redmine_time_entry_wrapper.g.dart';

abstract class RedmineTimeEntryWrapper implements Built<RedmineTimeEntryWrapper, RedmineTimeEntryWrapperBuilder> {
  @BuiltValueField(wireName: 'time_entry')
  RedmineTimeEntry get timeEntry;

  RedmineTimeEntryWrapper._();

  factory RedmineTimeEntryWrapper([void Function(RedmineTimeEntryWrapperBuilder) updates]) = _$RedmineTimeEntryWrapper;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineTimeEntryWrapper.serializer, this));
  }

  static RedmineTimeEntryWrapper? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineTimeEntryWrapper.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineTimeEntryWrapper> get serializer => _$redmineTimeEntryWrapperSerializer;
}
