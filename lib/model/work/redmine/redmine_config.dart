library redmine_config;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:uuid/uuid.dart';

part 'redmine_config.g.dart';

const uuid = Uuid();

abstract class RedmineConfig implements Built<RedmineConfig, RedmineConfigBuilder> {
  String get id;
  String get name;
  String get baseUrl;
  String get apiKey;
  String? get projectFilters;
  bool get roundUp;

  @BuiltValueHook(initializeBuilder: true)
  static void _setDefaults(RedmineConfigBuilder b) => b..id ??= uuid.v4();

  RedmineConfig._();

  factory RedmineConfig([void Function(RedmineConfigBuilder) updates]) = _$RedmineConfig;

  String toJson() {
    return json.encode(serializers.serializeWith(RedmineConfig.serializer, this));
  }

  static RedmineConfig? fromJson(String jsonString) {
    return serializers.deserializeWith(RedmineConfig.serializer, json.decode(jsonString));
  }

  static Serializer<RedmineConfig> get serializer => _$redmineConfigSerializer;
}
