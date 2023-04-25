library erpnext_activity_type_list;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/erpnext/erpnext_activity_type.dart';

part 'erpnext_activity_type_list.g.dart';

abstract class ErpNextActivityTypeList implements Built<ErpNextActivityTypeList, ErpNextActivityTypeListBuilder> {
  BuiltList<ErpNextActivityType> get data;

  ErpNextActivityTypeList._();

  factory ErpNextActivityTypeList([void Function(ErpNextActivityTypeListBuilder) updates]) = _$ErpNextActivityTypeList;

  String toJson() {
    return json.encode(serializers.serializeWith(ErpNextActivityTypeList.serializer, this));
  }

  static ErpNextActivityTypeList fromJson(String jsonString) {
    return serializers.deserializeWith(ErpNextActivityTypeList.serializer, json.decode(jsonString))!;
  }

  static Serializer<ErpNextActivityTypeList> get serializer => _$erpNextActivityTypeListSerializer;
}
