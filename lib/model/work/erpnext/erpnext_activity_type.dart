library erpnext_activity_type;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';

part 'erpnext_activity_type.g.dart';

abstract class ErpNextActivityType implements Built<ErpNextActivityType, ErpNextActivityTypeBuilder> {
  String get name;

  ErpNextActivityType._();

  factory ErpNextActivityType([void Function(ErpNextActivityTypeBuilder) updates]) = _$ErpNextActivityType;

  String toJson() {
    return json.encode(serializers.serializeWith(ErpNextActivityType.serializer, this));
  }

  static ErpNextActivityType fromJson(String jsonString) {
    return serializers.deserializeWith(ErpNextActivityType.serializer, json.decode(jsonString))!;
  }

  static Serializer<ErpNextActivityType> get serializer => _$erpNextActivityTypeSerializer;
}
