import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/widgets/app_bottom_navigation_bar.dart';

import '../dashboard/dashboard_page.dart';
import '../meds/meds_page.dart';
import '../events/events_page.dart';
import '../chat/chat_page.dart';
import '../settings/settings_page.dart';
import 'home_cubit.dart';

@RoutePage()
class HomePage extends BaseCubitPage<HomeCubit, HomeState> {
  const HomePage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<HomeCubit>().loadData();
  }

  @override
  Widget builder(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.currentTabIndex,
            children: [
              const DashboardPage().wrappedRoute(context),
              const MedsPage().wrappedRoute(context),
              const EventsPage(),
              const ChatPage(),
              const SettingsPage(),
            ],
          ),
          bottomNavigationBar: AppBottomNavigationBar(
            currentIndex: state.currentTabIndex,
            onTap: (index) => context.read<HomeCubit>().changeTab(index),
            items: [
              AppBottomNavigationItem(
                label: 'bottom_nav.home'.tr(),
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                page: const HomeRoute(),
              ),
              AppBottomNavigationItem(
                label: 'bottom_nav.meds'.tr(),
                icon: const Icon(Icons.medication_outlined),
                selectedIcon: const Icon(Icons.medication),
                page: const HomeRoute(),
              ),
              AppBottomNavigationItem(
                label: 'bottom_nav.events'.tr(),
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                page: const HomeRoute(),
              ),
              AppBottomNavigationItem(
                label: 'bottom_nav.chat'.tr(),
                icon: const Icon(Icons.forum_outlined),
                selectedIcon: const Icon(Icons.forum),
                page: const HomeRoute(),
              ),
              AppBottomNavigationItem(
                label: 'bottom_nav.settings'.tr(),
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                page: const HomeRoute(),
              ),
            ],
          ),
        );
      },
    );
  }
}
