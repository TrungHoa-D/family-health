import 'package:auto_route/auto_route.dart';
import 'package:family_health/presentation/view/pages/home/home_page.dart';
import 'package:family_health/presentation/view/pages/login/login_page.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page|Dialog|Screen,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  final List<AutoRoute> routes = [
    AutoRoute(page: LoginRoute.page, initial: true),
    AutoRoute(page: HomeRoute.page),
  ];
}
