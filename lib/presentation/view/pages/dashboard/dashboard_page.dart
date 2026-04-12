import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'components/dashboard_alert_section.dart';
import 'components/dashboard_header.dart';
import 'components/dashboard_members_section.dart';
import 'components/dashboard_overview_card.dart';
import 'components/dashboard_schedule_section.dart';
import 'dashboard_cubit.dart';
import 'package:family_health/presentation/router/router.dart';

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
              padding:
                  const EdgeInsets.only(bottom: 100), // Spacing for bottom nav
              child: Column(
                children: [
                  DashboardHeader(
                    userName: state.user?.displayName?.isNotEmpty == true
                        ? state.user?.displayName
                        : null,
                    userPhotoUrl: state.user?.avatarUrl,
                    onNotificationTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chưa có thông báo nào')),
                      );
                    },
                  ),
                  if (state.totalCount == 0)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wb_sunny, color: AppColors.primary, size: 36),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chào ngày mới 👋',
                                  style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hôm nay gia đình không có sự kiện gì.',
                                  style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DashboardOverviewCard(
                      progress: state.progress,
                      takenCount: state.takenCount,
                      totalCount: state.totalCount,
                      waitingCount: state.waitingCount,
                      missedCount: state.missedCount,
                    ),
                  DashboardAlertSection(
                    alerts: state.alerts
                        .map((a) => DashboardAlertItem(
                              personName: a.userName,
                              actionName: a.medName,
                              minutesLate: a.delayMinutes,
                              onRemind: () {
                                // TODO: Logic gửi notification nhắc nhở
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã gửi nhắc nhở cho ${a.userName}'.tr())),
                                );
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Members section — real data từ Firebase
                  DashboardMembersSection(
                    members: state.memberStats
                        .map((m) => DashboardMemberModel(
                              name: m.displayName,
                              photoUrl: m.avatarUrl,
                              takenCount: m.takenDoses,
                              totalCount: m.totalDoses,
                              statusColor: m.takenDoses == m.totalDoses &&
                                      m.totalDoses > 0
                                  ? AppColors.success
                                  : m.takenDoses == 0
                                      ? AppColors.error
                                      : AppColors.warning,
                            ))
                        .toList(),
                    onViewAll: () {
                      context.router.push(const FamilyManagementRoute());
                    },
                  ),
                  // Schedule section — upcoming events từ Firebase
                  if (state.upcomingEvents.isNotEmpty) ...
                    [
                      DashboardScheduleSection(
                        schedules: state.upcomingEvents
                            .map((e) => DashboardScheduleModel(
                                  title: e.title,
                                  dateTime: e.startTime,
                                  location: e.location,
                                ))
                            .toList(),
                      ),
                    ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
