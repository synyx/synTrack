import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:syntrack/model/work/redmine/redmine_config.dart';
import 'package:syntrack/model/work/work_interface_configs.dart';

class WorkInterfaceCubit extends HydratedCubit<WorkInterfaceConfigs> {
  WorkInterfaceCubit() : super(WorkInterfaceConfigs((b) => b..redmineConfigs = ListBuilder([])));

  void deleteRedmineConfig(RedmineConfig redmineConfig) {
    final newConfigs = state.rebuild((b) => b..redmineConfigs.remove(redmineConfig));
    emit(newConfigs);
  }

  void addOrUpdateRedmineConfig(RedmineConfig redmineConfig) {
    if (getRedmineConfig(redmineConfig.id) != null) {
      _updateRedmineConfig(redmineConfig);
    } else {
      _addRedmineConfig(redmineConfig);
    }
  }

  void _updateRedmineConfig(RedmineConfig redmineConfig) {
    final index = state.redmineConfigs.indexWhere((config) => config.id == redmineConfig.id);

    final newConfigs = state.rebuild((b) => b..redmineConfigs.replaceRange(index, index + 1, [redmineConfig]));
    emit(newConfigs);
  }

  void _addRedmineConfig(RedmineConfig redmineConfig) {
    final newConfigs = state.rebuild((b) => b..redmineConfigs.add(redmineConfig));
    emit(newConfigs);
  }

  RedmineConfig? getRedmineConfig(String id) {
    try {
      return state.redmineConfigs.firstWhere((config) => config.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  WorkInterfaceConfigs? fromJson(Map<String, dynamic> json) {
    try {
      return WorkInterfaceConfigs.fromJson(jsonEncode(json['data']));
    } catch (e) {
      // TODO: error log
    }
  }

  @override
  Map<String, dynamic>? toJson(WorkInterfaceConfigs state) {
    return {'data': jsonDecode(state.toJson())};
  }
}
