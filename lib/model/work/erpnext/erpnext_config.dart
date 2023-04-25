library erpnext_config;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:uuid/uuid.dart';

part 'erpnext_config.g.dart';

const uuid = Uuid();

abstract class ErpNextConfig implements Built<ErpNextConfig, ErpNextConfigBuilder> {
  String get id;
  String get name;
  String get baseUrl;
  String get apiKey;
  String get apiSecret;

  @BuiltValueHook(initializeBuilder: true)
  static void _setDefaults(ErpNextConfigBuilder b) => b..id ??= uuid.v4();

  ErpNextConfig._();

  factory ErpNextConfig([void Function(ErpNextConfigBuilder) updates]) = _$ErpNextConfig;

  String toJson() {
    return json.encode(serializers.serializeWith(ErpNextConfig.serializer, this));
  }

  static ErpNextConfig? fromJson(String jsonString) {
    return serializers.deserializeWith(ErpNextConfig.serializer, json.decode(jsonString));
  }

  static Serializer<ErpNextConfig> get serializer => _$erpNextConfigSerializer;
}
