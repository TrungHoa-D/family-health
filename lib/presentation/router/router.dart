import 'package:auto_route/auto_route.dart';
import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/presentation/router/auth_guard.dart';
import 'package:family_health/presentation/router/family_guard.dart';
import 'package:family_health/presentation/view/pages/ai_support/ai_chat_page.dart';
import 'package:family_health/presentation/view/pages/chat/chat_page.dart';
import 'package:family_health/presentation/view/pages/dashboard/dashboard_page.dart';
import 'package:family_health/presentation/view/pages/events/add_event/add_event_page.dart';
import 'package:family_health/presentation/view/pages/events/events_page.dart';
import 'package:family_health/presentation/view/pages/family_group/family_group_page.dart';
import 'package:family_health/presentation/view/pages/family_management/family_management_page.dart';
import 'package:family_health/presentation/view/pages/family_setup/family_setup_page.dart';
import 'package:family_health/presentation/view/pages/home/home_page.dart';
import 'package:family_health/presentation/view/pages/interface_mode_selection/interface_mode_selection_page.dart';
import 'package:family_health/presentation/view/pages/login/login_page.dart';
import 'package:family_health/presentation/view/pages/meds/add_medication/add_medication_page.dart';
import 'package:family_health/presentation/view/pages/meds/category_list/category_list_page.dart';
import 'package:family_health/presentation/view/pages/meds/category_meds/category_meds_page.dart';
import 'package:family_health/presentation/view/pages/meds/medication_detail/medication_detail_page.dart';
import 'package:family_health/presentation/view/pages/meds/meds_cubit.dart';
import 'package:family_health/presentation/view/pages/meds/meds_page.dart';
import 'package:family_health/presentation/view/pages/profile_edit/profile_edit_page.dart';
import 'package:family_health/presentation/view/pages/settings/routines/edit_routines_page.dart';
import 'package:family_health/presentation/view/pages/settings/settings_page.dart';
import 'package:family_health/presentation/view/pages/settings/settings_state.dart';
import 'package:family_health/presentation/view/pages/setup_health_profile/setup_health_profile_page.dart';
import 'package:family_health/presentation/view/pages/splash/splash_page.dart';
import 'package:flutter/material.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page|Dialog|Screen,Route')
class AppRouter extends RootStackRouter {
  AppRouter(this.authGuard, this.familyGuard);
  final AuthGuard authGuard;
  final FamilyGuard familyGuard;

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: HomeRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(page: SetupHealthProfileRoute.page),
        AutoRoute(page: FamilySetupRoute.page),
        AutoRoute(page: InterfaceModeSelectionRoute.page),
        AutoRoute(page: DashboardRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(page: MedsRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(
            page: AddMedicationRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(
            page: MedicationDetailRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(
            page: CategoryListRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(
            page: CategoryMedsRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(
            page: ProfileEditRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(
            page: FamilyManagementRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(page: SettingsRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(page: ChatRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(page: EventsRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(
            page: EditRoutinesRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(page: AddEventRoute.page, guards: [authGuard, familyGuard]),
        AutoRoute(page: FamilyGroupRoute.page),
        AutoRoute(
            page: AIChatSupportRoute.page,
            guards: [authGuard, familyGuard]),
      ];
}
