library work_interface_configs;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:syntrack/model/serializer/serializers.dart';
import 'package:syntrack/model/work/redmine/redmine_config.dart';

part 'work_interface_configs.g.dart';

abstract class WorkInterfaceConfigs implements Built<WorkInterfaceConfigs, WorkInterfaceConfigsBuilder> {
  BuiltList<RedmineConfig> get redmineConfigs;

  WorkInterfaceConfigs._();

  factory WorkInterfaceConfigs([void Function(WorkInterfaceConfigsBuilder) updates]) = _$WorkInterfaceConfigs;

  String toJson() {
    return json.encode(serializers.serializeWith(WorkInterfaceConfigs.serializer, this));
  }

  static WorkInterfaceConfigs? fromJson(String jsonString) {
    return serializers.deserializeWith(WorkInterfaceConfigs.serializer, json.decode(jsonString));
  }

  static Serializer<WorkInterfaceConfigs> get serializer => _$workInterfaceConfigsSerializer;
}
