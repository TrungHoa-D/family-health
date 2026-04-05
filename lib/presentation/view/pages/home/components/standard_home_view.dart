import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/widgets/app_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'package:family_health/presentation/view/pages/chat/chat_page.dart';
import 'package:family_health/presentation/view/pages/dashboard/dashboard_page.dart';
import 'package:family_health/presentation/view/pages/events/events_page.dart';
import 'package:family_health/presentation/view/pages/meds/meds_page.dart';
import 'package:family_health/presentation/view/pages/settings/settings_page.dart';

class StandardHomeView extends StatelessWidget {
  const StandardHomeView({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  final int currentIndex;
  final Function(int) onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          const DashboardPage().wrappedRoute(context),
          const MedsPage().wrappedRoute(context),
          const EventsPage().wrappedRoute(context),
          const ChatPage().wrappedRoute(context),
          const SettingsPage().wrappedRoute(context),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabChanged,
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
  }
}
