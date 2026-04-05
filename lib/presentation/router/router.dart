import 'package:auto_route/auto_route.dart';
import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/presentation/view/pages/dashboard/dashboard_page.dart';
import 'package:family_health/presentation/view/pages/family_management/family_management_page.dart';
import 'package:family_health/presentation/view/pages/family_setup/family_setup_page.dart';
import 'package:family_health/presentation/view/pages/home/home_page.dart';
import 'package:family_health/presentation/view/pages/interface_mode_selection/interface_mode_selection_page.dart';
import 'package:family_health/presentation/view/pages/login/login_page.dart';
import 'package:family_health/presentation/view/pages/meds/add_medication/add_medication_page.dart';
import 'package:family_health/presentation/view/pages/meds/medication_detail/medication_detail_page.dart';
import 'package:family_health/presentation/view/pages/meds/meds_cubit.dart';
import 'package:family_health/presentation/view/pages/meds/meds_page.dart';
import 'package:family_health/presentation/view/pages/profile_edit/profile_edit_page.dart';
import 'package:family_health/presentation/view/pages/settings/settings_page.dart';
import 'package:family_health/presentation/view/pages/chat/chat_page.dart';
import 'package:family_health/presentation/view/pages/events/events_page.dart';
import 'package:family_health/presentation/view/pages/setup_health_profile/setup_health_profile_page.dart';
import 'package:family_health/presentation/view/pages/splash/splash_page.dart';
import 'package:flutter/material.dart';

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
    AutoRoute(page: DashboardRoute.page),
    AutoRoute(page: MedsRoute.page),
    AutoRoute(page: AddMedicationRoute.page),
    AutoRoute(page: MedicationDetailRoute.page),
    AutoRoute(page: ProfileEditRoute.page),
    AutoRoute(page: FamilyManagementRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: ChatRoute.page),
    AutoRoute(page: EventsRoute.page),
  ];
}
