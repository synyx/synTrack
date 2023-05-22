
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeModeCubit extends HydratedCubit<ThemeMode> {
  ThemeModeCubit() : super(ThemeMode.system);

  bool? get isDark => switch (state) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system => null,
      };

  set dark(bool? dark) => emit(switch (dark) {
        true => ThemeMode.dark,
        false => ThemeMode.light,
        null => ThemeMode.system,
      });

  @override
  ThemeMode fromJson(Map<String, dynamic> json) => switch (json['version']) {
        <= 1 => switch (json['themeMode']) {
            'dark' => ThemeMode.dark,
            'light' => ThemeMode.light,
            _ => ThemeMode.system,
          },
        _ => ThemeMode.system,
      };

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    final themeMode = switch (state) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      _ => 'system',
    };

    return {
      'version': 1,
      'themeMode': themeMode,
    };
  }
}
