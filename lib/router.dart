import 'package:auto_route/auto_route.dart';
import 'package:syntrack/ui/redmine_edit_page.dart';
import 'package:syntrack/ui/settings_page.dart';
import 'package:syntrack/ui/track_page.dart';
import 'package:syntrack/ui/work_interface_selector_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: TrackPage, initial: true),
    AutoRoute(page: SettingsPage),
    AutoRoute(page: RedmineEditPage, fullscreenDialog: true),
    AutoRoute(page: WorkInterfaceSelectorPage, fullscreenDialog: true),
  ],
)
class $AppRouter {}
