library redmine_activity;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'redmine_activity.g.dart';

abstract class RedmineActivity implements Built<RedmineActivity, RedmineActivityBuilder> {
  int get id;
  String get name;
  @BuiltValueField(wireName: 'is_default')
  bool get isDefault;

  RedmineActivity._();

  factory RedmineActivity([void Function(RedmineActivityBuilder) updates]) = _$RedmineActivity;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineActivity.serializer, this));
  }

  static RedmineActivity? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineActivity.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineActivity> get serializer => _$redmineActivitySerializer;
}
