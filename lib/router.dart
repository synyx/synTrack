import 'package:auto_route/auto_route.dart';

import 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: TrackRoute.page, initial: true),
        AutoRoute(page: SettingsRoute.page),
        AutoRoute(page: RedmineEditRoute.page, fullscreenDialog: true),
        AutoRoute(page: ErpNextEditRoute.page, fullscreenDialog: true),
        AutoRoute(page: WorkInterfaceSelectorRoute.page, fullscreenDialog: true),
      ];
}
