import 'package:auto_route/auto_route.dart';
import 'package:family_health/presentation/view/pages/home/home_page.dart';
import 'package:family_health/presentation/view/pages/login/login_page.dart';
import 'package:family_health/presentation/view/pages/setup_health_profile/setup_health_profile_page.dart';
import 'package:family_health/presentation/view/pages/splash/splash_page.dart';
import 'package:family_health/presentation/view/pages/family_setup/family_setup_page.dart';
import 'package:family_health/presentation/view/pages/interface_mode_selection/interface_mode_selection_page.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page|Dialog|Screen,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  final List<AutoRoute> routes = [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: HomeRoute.page),
    AutoRoute(page: SetupHealthProfileRoute.page),
    AutoRoute(page: FamilySetupRoute.page),
    AutoRoute(page: InterfaceModeSelectionRoute.page),
  ];
}
