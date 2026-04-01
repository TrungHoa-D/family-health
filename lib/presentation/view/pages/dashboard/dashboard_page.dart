import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';

import 'components/dashboard_alert_section.dart';
import 'components/dashboard_header.dart';
import 'components/dashboard_members_section.dart';
import 'components/dashboard_overview_card.dart';
import 'components/dashboard_schedule_section.dart';
import 'dashboard_cubit.dart';

@RoutePage()
class DashboardPage extends BaseCubitPage<DashboardCubit, DashboardState> {
  const DashboardPage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<DashboardCubit>().loadData();
  }

  @override
  Widget builder(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Spacing for bottom nav
              child: Column(
                children: [
                  DashboardHeader(
                    userName: state.user?.displayName,
                    userPhotoUrl: state.user?.photoUrl,
                    onNotificationTap: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  DashboardOverviewCard(
                    progress: state.progress,
                    takenCount: state.takenCount,
                    totalCount: state.totalCount,
                    waitingCount: state.waitingCount,
                    missedCount: state.missedCount,
                  ),
                  DashboardAlertSection(
                    alerts: [
                      DashboardAlertItem(
                        personName: 'home.father'.tr(),
                        actionName: 'home.blood_pressure'.tr(),
                        minutesLate: 23,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DashboardMembersSection(
                    members: [
                      DashboardMemberModel(
                        name: 'home.father'.tr(),
                        progress: '4/6',
                        statusColor: AppColors.secondary,
                      ),
                      DashboardMemberModel(
                        name: 'home.mother'.tr(),
                        progress: '5/5',
                        statusColor: AppColors.secondary,
                      ),
                      DashboardMemberModel(
                        name: 'home.wife'.tr(),
                        progress: '2/4',
                        statusColor: AppColors.primary,
                      ),
                    ],
                    onViewAll: () {},
                  ),
                  DashboardScheduleSection(
                    schedules: [
                      DashboardScheduleModel(
                        title: '${'home.checkup'.tr()} - ${'home.father'.tr()}',
                        month: 'OCT',
                        day: '24',
                        time: '14:30 PM',
                        location: 'home.hospital_fv'.tr(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
