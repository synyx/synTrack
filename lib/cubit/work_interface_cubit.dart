import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:syntrack/model/common/task_search_origin.dart';
import 'package:syntrack/model/work/erpnext/erpnext_config.dart';
import 'package:syntrack/model/work/redmine/redmine_config.dart';
import 'package:syntrack/model/work/work_interface_configs.dart';

class WorkInterfaceCubit extends HydratedCubit<WorkInterfaceConfigs> {
  WorkInterfaceCubit()
      : super(WorkInterfaceConfigs(
          (b) => b
            ..redmineConfigs = ListBuilder([])
            ..erpNextConfigs = ListBuilder([]),
        ));

  void deleteConfig(String id) {
    final newConfigs = state.rebuild((b) => b
      ..redmineConfigs.removeWhere((config) => config.id == id)
      ..erpNextConfigs.removeWhere((config) => config.id == id));
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

  void addOrUpdateErpNextConfig(ErpNextConfig erpNextConfig) {
    if (getErpNextConfig(erpNextConfig.id) != null) {
      _updateErpNextConfig(erpNextConfig);
    } else {
      _addErpNextConfig(erpNextConfig);
    }
  }

  void _updateErpNextConfig(ErpNextConfig erpNextConfig) {
    final index = state.erpNextConfigs.indexWhere((config) => config.id == erpNextConfig.id);

    final newConfigs = state.rebuild((b) => b..erpNextConfigs.replaceRange(index, index + 1, [erpNextConfig]));
    emit(newConfigs);
  }

  void _addErpNextConfig(ErpNextConfig erpNextConfig) {
    final newConfigs = state.rebuild((b) => b..erpNextConfigs.add(erpNextConfig));
    emit(newConfigs);
  }

  ErpNextConfig? getErpNextConfig(String id) {
    try {
      return state.erpNextConfigs.firstWhere((config) => config.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  WorkInterfaceConfigs? fromJson(Map<String, dynamic> json) {
    final version = json['version'] ?? 1;
    try {
      if (version <= 2) {
        return WorkInterfaceConfigs.fromJson(jsonEncode(json['data']));
      }
    } catch (e) {
      // TODO: error log
    }

    return null;
  }

  @override
  Map<String, dynamic>? toJson(WorkInterfaceConfigs state) {
    return {
      'version': 2,
      'data': jsonDecode(state.toJson()),
    };
  }

  TaskSearchOrigin? getOriginFor(String workInterfaceId) {
    return state.combinedConfigs
        .map((element) => switch (element) {
              ErpNextConfig() => element.id == workInterfaceId ? TaskSearchOrigin.erpNext : null,
              RedmineConfig() => element.id == workInterfaceId ? TaskSearchOrigin.redmine : null,
              _ => null,
            })
        .firstWhereOrNull((element) => element != null);
  }

  String getNameFor(dynamic workInterface) => switch (workInterface) {
        ErpNextConfig() => workInterface.name,
        RedmineConfig() => workInterface.name,
        _ => '',
      };

  String getIdFor(dynamic workInterface) => switch (workInterface) {
        ErpNextConfig() => workInterface.id,
        RedmineConfig() => workInterface.id,
        _ => '',
      };
}
